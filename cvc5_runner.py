import subprocess
import logging
import time
import os
import signal
import psutil
from env_config import setup_environment

# Load the configuration
config = setup_environment()

def run_cvc_solver_with_timeout(smt2_path, timeout=60):
    """
    Verify an SMT2 file using multiple CVC5/CVC4 configurations in parallel and return the first successful result.
    
    Args:
        smt2_path (str): path to the SMT2 file
        timeout (int): timeout in seconds, default 60
        
    Returns:
        bool: True if verification succeeds; False on failure or timeout
    """
    # Read the CVC5 and CVC4 executable paths from the configuration
    cvc4_binary = config['CVC4_BINARY']
    cvc5_binary = config['CVC5_BINARY']
    
    # Define the configurations for all verification strategies, including the strategy type and options
    strategies = {
        # CVC5 strategies
        'cvc5_simple': {
            'binary': cvc5_binary,
            'options': ["--full-saturate-quant"],
            'type': 'CVC5'
        },
        'cvc5_inductive': {
            'binary': cvc5_binary,
            'options': ["--full-saturate-quant", "--quant-ind", "--conjecture-gen"],
            'type': 'CVC5'
        },
        'cvc5_inductive_no_ematching': {
            'binary': cvc5_binary,
            'options': ["--full-saturate-quant", "--quant-ind", "--conjecture-gen", "--no-e-matching"],
            'type': 'CVC5'
        },
        # CVC4 strategies
        'cvc4_default': {
            'binary': cvc4_binary,
            'options': ["--quant-ind", "--quant-cf", "--conjecture-gen", "--full-saturate-quant", "--lang=smt2.6"],
            'type': 'CVC4'
        }
    }
    
    # Start parallel processes for all strategies
    processes = {}
    try:
        for strategy_name, strategy_config in strategies.items():
            binary = strategy_config['binary']
            options = strategy_config['options']
            strategy_type = strategy_config['type']
            
            command = [binary] + options + [smt2_path]
            try:
                # Use a process group to manage the child process for easy cleanup
                proc = subprocess.Popen(
                    command, 
                    stdout=subprocess.PIPE, 
                    stderr=subprocess.PIPE, 
                    text=True,
                    preexec_fn=os.setsid  # create a new process group
                )
                processes[strategy_name] = proc
                logging.debug(f"Started {strategy_type} process: {strategy_name} (PID: {proc.pid})")
            except FileNotFoundError:
                logging.error(f"{strategy_type} executable not found: {binary}")
                continue
            except Exception as e:
                logging.error(f"Failed to start {strategy_name} process: {e}")
                continue
        
        if not processes:
            logging.error("Failed to start any CVC5/CVC4 process")
            return False
        
        # Monitor process execution
        start_time = time.time()
        completed_processes = set()
        
        while time.time() - start_time < timeout:
            # Check the status of each process
            for strategy_name, proc in processes.items():
                if strategy_name in completed_processes:
                    continue
                    
                if proc.poll() is not None:  # process has finished
                    completed_processes.add(strategy_name)
                    
                    try:
                        stdout, stderr = proc.communicate(timeout=1)
                        
                        if proc.returncode == 0 and 'unsat' in stdout:
                            # Get the strategy type for logging
                            strategy_type = strategies[strategy_name]['type']
                            logging.info(f"{strategy_type} verification succeeded: unsat (strategy: {strategy_name})")
                            # Clean up the other processes and return success
                            _cleanup_processes(processes, exclude=strategy_name)
                            return True
                        else:
                            # Log the failure information but keep waiting for other processes
                            if stderr.strip():
                                logging.debug(f"Strategy {strategy_name} failed: {stderr.strip()}")
                            else:
                                logging.debug(f"Strategy {strategy_name} did not return an unsat result")
                                
                    except subprocess.TimeoutExpired:
                        logging.warning(f"Timed out getting output from {strategy_name} process")
                        proc.kill()
                        completed_processes.add(strategy_name)
                    except Exception as e:
                        logging.error(f"Error processing the result of {strategy_name}: {e}")
                        completed_processes.add(strategy_name)
            
            # Exit the loop if all processes have completed
            if len(completed_processes) == len(processes):
                break
                
            time.sleep(0.05)  # polling interval to reduce CPU usage
        
        # Timeout, or all processes failed
        logging.warning(f"CVC5/CVC4 verification timed out or failed (elapsed: {time.time() - start_time:.2f}s)")
        return False
        
    finally:
        # Make sure all processes are cleaned up
        _cleanup_processes(processes)


def _cleanup_processes(processes, exclude=None):
    """
    Clean up all processes in the process dictionary, including their child processes.
    
    Args:
        processes (dict): process dictionary
        exclude (str): name of the process to exclude
    """
    for strategy_name, proc in processes.items():
        if exclude and strategy_name == exclude:
            continue
            
        if proc.poll() is None:  # the process is still running
            try:
                # First, try to gracefully terminate the process group
                try:
                    os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
                    logging.debug(f"Sent SIGTERM to {strategy_name} process group (PGID: {os.getpgid(proc.pid)})")
                except (OSError, ProcessLookupError):
                    # If the process group does not exist, terminate the process directly
                    proc.terminate()
                    logging.debug(f"Terminated {strategy_name} process directly (PID: {proc.pid})")
                
                # Give the process some time to exit gracefully
                try:
                    proc.wait(timeout=3)
                    logging.debug(f"{strategy_name} process terminated gracefully")
                except subprocess.TimeoutExpired:
                    # Forcefully kill the process group
                    try:
                        os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
                        logging.debug(f"Forcefully killed {strategy_name} process group")
                    except (OSError, ProcessLookupError):
                        # If the process group does not exist, kill the process directly
                        proc.kill()
                        logging.debug(f"Forcefully killed {strategy_name} process")
                    proc.wait()
                    
            except Exception as e:
                logging.error(f"Error terminating {strategy_name} process: {e}")
                # Last-resort cleanup attempt: forcefully clean up with psutil
                try:
                    if psutil.pid_exists(proc.pid):
                        parent = psutil.Process(proc.pid)
                        children = parent.children(recursive=True)
                        for child in children:
                            try:
                                child.kill()
                            except psutil.NoSuchProcess:
                                pass
                        parent.kill()
                        logging.debug(f"Forcefully cleaned up {strategy_name} process and its children via psutil")
                except Exception as cleanup_error:
                    logging.error(f"Failed to clean up {strategy_name} process via psutil: {cleanup_error}")