import subprocess
import logging
import time
import os
import signal
from pathlib import Path
from env_config import setup_environment

# Load the configuration
config = setup_environment()

def run_vampire_with_timeout(smt2_path, timeout=60):
    """
    Verify an SMT2 file with Vampire.
    
    Args:
        smt2_path (str or Path): path to the SMT2 file
        timeout (int): timeout in seconds, defaults to 60
        
    Returns:
        bool: True if the verification succeeds (unsatisfiable); False on failure or timeout.
    """
    # Get the path to the Vampire executable from the configuration
    vampire_binary = config.get('VAMPIRE_BINARY')
    if not vampire_binary:
        logging.error("VAMPIRE_BINARY not found in the configuration")
        return False
    
    # Ensure smt2_path is a Path object
    if isinstance(smt2_path, str):
        smt2_path = Path(smt2_path)
    
    # Build the command; the timeout value needs an 's' suffix.
    # --input_syntax specifies the input-syntax type as smtlib2; the file path is the last argument.
    command = [
        vampire_binary,
        '-t', f'{timeout}s',
        '--mode', 'portfolio',
        '--schedule', 'induction',
        '--output_mode', 'smtcomp',
        '--input_syntax', 'smtlib2',
        str(smt2_path)
    ]
    
    try:
        logging.debug(f"Starting Vampire process: {' '.join(command)}")
        
        # Use a process group to manage the child process, making cleanup easier
        proc = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            preexec_fn=os.setsid  # create a new process group
        )
        
        start_time = time.time()
        
        try:
            # Wait for the process to finish, but apply a timeout
            stdout, stderr = proc.communicate(timeout=timeout + 5)  # add 5s of buffer
            
            elapsed_time = time.time() - start_time
            
            # Only inspect stdout for the result; ignore warnings on stderr.
            # When Vampire proves unsatisfiability, its output contains "unsatisfiable" or "unsat".
            output = stdout.lower().strip()
            
            # Check whether the output contains an unsat result (usually at the end)
            if 'unsatisfiable' in output or 'unsat' in output:
                logging.info(f"Vampire verification succeeded: unsatisfiable (elapsed: {elapsed_time:.2f}s, return code: {proc.returncode})")
                return True
            else:
                # Even if the return code is 0, treat it as failure when no unsat is found
                logging.debug(f"Vampire did not produce an unsatisfiable result (return code: {proc.returncode}, elapsed: {elapsed_time:.2f}s)")
                if stdout.strip():
                    logging.debug(f"Vampire stdout (last 100 chars): {stdout.strip()[-100:]}")
                if stderr.strip():
                    logging.debug(f"Vampire stderr (first 200 chars): {stderr.strip()[:200]}")
                return False
                
        except subprocess.TimeoutExpired:
            # Timeout: terminate the process
            elapsed_time = time.time() - start_time
            logging.warning(f"Vampire verification timed out (elapsed: {elapsed_time:.2f}s)")
            _cleanup_process(proc)
            return False
            
    except FileNotFoundError:
        logging.error(f"Vampire executable not found: {vampire_binary}")
        return False
    except Exception as e:
        logging.error(f"Failed to start the Vampire process: {e}")
        return False


def _cleanup_process(proc):
    """
    Clean up a process together with its child processes.
    
    Args:
        proc: a subprocess.Popen object
    """
    if proc.poll() is None:  # process is still running
        try:
            # First, try to gracefully terminate the process group
            try:
                os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
                logging.debug(f"Sent SIGTERM to the Vampire process group (PGID: {os.getpgid(proc.pid)})")
            except (OSError, ProcessLookupError):
                # If the process group no longer exists, terminate the process directly
                proc.terminate()
                logging.debug(f"Terminated the Vampire process directly (PID: {proc.pid})")
            
            # Give the process some time to exit gracefully
            try:
                proc.wait(timeout=3)
                logging.debug(f"Vampire process terminated gracefully")
            except subprocess.TimeoutExpired:
                # Force-terminate the process group
                try:
                    os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
                    logging.debug(f"Force-terminated the Vampire process group")
                except (OSError, ProcessLookupError):
                    # If the process group no longer exists, kill the process directly
                    proc.kill()
                    logging.debug(f"Force-terminated the Vampire process")
                proc.wait()
                
        except Exception as e:
            logging.error(f"Error while terminating the Vampire process: {e}")
