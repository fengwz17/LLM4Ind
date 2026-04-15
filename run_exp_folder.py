#!/usr/bin/env python3
import os
import sys
import logging
import time
import csv
import signal
import multiprocessing
import shutil
import psutil
import argparse
from datetime import datetime
from tempfile import template
from tqdm import tqdm
import contextlib
import io
from concurrent.futures import ProcessPoolExecutor, as_completed
import Mate_new as mate_solver
from env_config import setup_environment
prove_run = mate_solver.prove_run

# Load the configuration
config = setup_environment()

# The setup_task_logger function has been removed since each process handles logging independently in a multi-process environment

class TaskTimeoutError(Exception):
    """Task timeout exception"""
    pass

def timeout_handler(signum, frame):
    """Timeout signal handler"""
    raise TaskTimeoutError("Task execution timed out")

def cleanup_process_tree(pid):
    """Clean up a process and all of its child processes"""
    try:
        if psutil.pid_exists(pid):
            parent = psutil.Process(pid)
            children = parent.children(recursive=True)
            
            # First, try to gracefully terminate all child processes
            for child in children:
                try:
                    child.terminate()
                except psutil.NoSuchProcess:
                    pass
            
            # Wait a while to allow processes to exit gracefully
            gone, alive = psutil.wait_procs(children, timeout=3)
            
            # Forcefully kill any still-alive processes
            for proc in alive:
                try:
                    proc.kill()
                except psutil.NoSuchProcess:
                    pass
            
            # Finally, terminate the parent process
            try:
                parent.terminate()
                parent.wait(timeout=3)
            except (psutil.NoSuchProcess, psutil.TimeoutExpired):
                try:
                    parent.kill()
                except psutil.NoSuchProcess:
                    pass
                    
            logging.debug(f"Cleaned up process tree PID: {pid}")
    except Exception as e:
        logging.error(f"Failed to clean up process tree PID: {pid}, error: {e}")

def run_task_with_timeout(folder, template_name, task_timeout, result_queue, strategy_mode, baseline_mode=None):
    """Function that runs a task in a separate process"""
    try:
        # Generate the log filename (named after the start time)
        start_datetime = datetime.now()
        log_filename = start_datetime.strftime("%Y%m%d_%H%M%S.log")
        log_filepath = os.path.join(folder, log_filename)
        
        # Configure the logger: output to both console and file
        import logging
        
        # Configure the root logger because Mate_new.py uses the root logger
        root_logger = logging.getLogger()
        root_logger.handlers.clear()  # clear existing handlers
        root_logger.setLevel(logging.INFO)
        
        # Add a file handler to the root logger
        file_handler = logging.FileHandler(log_filepath, mode='w', encoding='utf-8')
        file_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s',
                                         datefmt='%Y-%m-%d %H:%M:%S')
        file_handler.setFormatter(file_formatter)
        root_logger.addHandler(file_handler)
        
        # Add a console handler to the root logger
        console_handler = logging.StreamHandler()
        console_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s',
                                            datefmt='%Y-%m-%d %H:%M:%S')
        console_handler.setFormatter(console_formatter)
        root_logger.addHandler(console_handler)
        
        # Execute prove_run
        start_time = time.time()
        # Only use the command-line argument to control baseline mode
        actual_baseline_mode = baseline_mode if baseline_mode is not None else False
        
        if actual_baseline_mode:
            logging.info(f"🎯 Baseline mode: starting task: {os.path.basename(folder)}, timeout: {task_timeout}s")
        else:
            logging.info(f"Starting task: {os.path.basename(folder)}, strategy mode: {strategy_mode}, timeout: {task_timeout}s")
        final_status = prove_run(folder, template_name, 0, strategy_mode=strategy_mode, baseline_only=actual_baseline_mode)
        end_time = time.time()
        
        # Close the handlers
        file_handler.close()
        root_logger.removeHandler(file_handler)
        root_logger.removeHandler(console_handler)
        
        # Put the result into the queue
        result_queue.put((folder, final_status, end_time - start_time, None))
        
    except Exception as e:
        elapsed_time = time.time() - start_time if 'start_time' in locals() else 0
        # Put the error result into the queue
        result_queue.put((folder, False, elapsed_time, str(e)))

def process_single_task(task_info):
    """Function for processing a single task (for multi-process execution) with process-level timeout control"""
    folder, template_name, strategy_mode, baseline_mode = task_info
    task_timeout = config['TASK_TIMEOUT']
    
    # Create an inter-process communication queue
    result_queue = multiprocessing.Queue()
    
    # Create a child process to execute the task
    process = multiprocessing.Process(
        target=run_task_with_timeout,
        args=(folder, template_name, task_timeout, result_queue, strategy_mode, baseline_mode)
    )
    
    start_time = time.time()
    process.start()
    
    try:
        # Wait for the process to finish, or until timeout
        process.join(timeout=task_timeout)
        
        if process.is_alive():
            # Process timed out; forcibly terminate the entire process tree
            logging.warning(f"Task timed out; forcibly terminating the process tree: {os.path.basename(folder)}")
            cleanup_process_tree(process.pid)
            process.join(timeout=5)  # give the process 5 seconds to exit gracefully
            
            if process.is_alive():
                # If it still has not exited, kill it forcibly
                process.kill()
                process.join()
            
            elapsed_time = time.time() - start_time
            return folder, False, elapsed_time, f"Task timed out ({task_timeout}s)"
        
        # The process finished normally; get the result
        if not result_queue.empty():
            return result_queue.get()
        else:
            # The process finished but produced no result — likely abnormal exit
            elapsed_time = time.time() - start_time
            return folder, False, elapsed_time, "Process exited abnormally, no return value"
            
    except Exception as e:
        # Handle exceptions
        if process.is_alive():
            cleanup_process_tree(process.pid)
            process.join(timeout=5)
            if process.is_alive():
                process.kill()
                process.join()
        
        elapsed_time = time.time() - start_time
        return folder, False, elapsed_time, f"Process-management exception: {str(e)}"

def find_template_folders(root_path, template_name="template.smt2"):
    """Recursively find folders containing the template.smt2 file"""
    template_folders = []
    
    for root, dirs, files in os.walk(root_path):
        if template_name in files:
            template_folders.append(root)
    
    return sorted(template_folders)

def copy_folder_for_experiment(original_path):
    """
    Copy the original folder to a timestamp-named subfolder under the result_files directory.
    Returns the path to the new folder.
    """
    # Get the root directory where this script lives
    script_dir = os.path.dirname(os.path.abspath(__file__))
    result_files_dir = os.path.join(script_dir, "result_files")
    
    # Create the result_files directory if it does not exist
    os.makedirs(result_files_dir, exist_ok=True)
    
    # Get the final component of the original folder
    original_folder_name = os.path.basename(original_path.rstrip(os.sep))
    
    # Generate a timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Build the new folder name: timestamp_originalFolderName
    new_folder_name = f"{timestamp}_{original_folder_name}"
    new_folder_path = os.path.join(result_files_dir, new_folder_name)
    
    # Copy the folder
    print(f"Copying folder: {original_path} -> {new_folder_path}")
    shutil.copytree(original_path, new_folder_path)
    print(f"Folder copy complete: {new_folder_path}")
    
    return new_folder_path

def save_results_to_csv(results, output_path, original_root_path):
    """Save results to a CSV file"""
    # Sort by folder name (alphabetical)
    sorted_results = sorted(results, key=lambda x: os.path.basename(x[0]))
    
    with open(output_path, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)
        for folder, status, duration in sorted_results:
            result_str = "unsat" if status else ""
            # Use the last two path components as the task name
            path_parts = folder.rstrip(os.sep).split(os.sep)
            if len(path_parts) >= 2:
                folder_name = os.path.join(path_parts[-2], path_parts[-1])
            else:
                folder_name = os.path.basename(folder)  # fall back to the old behavior if the path is too shallow
            
            # Compute the path relative to the original root directory
            try:
                relative_path = os.path.relpath(folder, original_root_path)
            except ValueError:
                # If a relative path cannot be computed (e.g. on a different drive), use the absolute path
                relative_path = folder
            
            writer.writerow([folder_name, result_str, f"{duration:.2f}", relative_path])

if __name__ == "__main__":
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description='ProofMate experiment runner')
    parser.add_argument('--baseline', action='store_true',
                       help='Enable baseline mode (run the initial verification only)')
    parser.add_argument('--root-path', type=str,
                       default="/home/ssdllm/ProofMate/preprocessed/all-int",
                       help='Path to the original folder')
    parser.add_argument('--strategy-mode', type=str,
                       choices=['default', 'zero_shot', 'naive'],
                       default='default',
                       help='Select the prompt strategy mode: default, zero_shot, naive')
    args = parser.parse_args()
    
    # Set the multiprocessing start method (required on some systems)
    multiprocessing.set_start_method('spawn', force=True)
    # Use the command-line argument for the original folder path
    # original_root_path = "/home/ssdllm/ProofMate/int-ben-llm/0911-10mins-llm-vmcai15dt/vmcai15-dt/hipspec/nosg"
    # original_root_path = "/home/ssdllm/ProofMate/int-ben-llm/0911-10mins-llm-vmcai15dt/vmcai15-dt/"
    # original_root_path = "/home/ssdllm/ProofMate/int-ben-llm/0911-10mins-llm-vmcai15dt/ssd_debug_test2"
    # original_root_path = "/home/ssdllm/ProofMate/preprocessed/autoproof"
    # original_root_path = "/home/ssdllm/ProofMate/preprocessed/dtt"
    # original_root_path = "/home/ssdllm/ProofMate/preprocessed/ind-ben"
    # original_root_path = "/home/ssdllm/ProofMate/preprocessed/vmcai15-dt"
    # Original folder path
    # original_root_path = "/home/ssdllm/ProofMate/int-ben-llm/0922dtt/dtt_quick"
    # original_root_path = "/home/ssdllm/ProofMate/int-ben-llm/0911-10mins-llm-vmcai15dt/ssd_debug_test2"
    # original_root_path = "/home/ssdllm/ProofMate/preprocessed/autoproof"
    # original_root_path = "/home/ssdllm/ProofMate/preprocessed/debug_test"
    original_root_path = args.root_path
    
    # Copy the folder to the result_files directory to avoid contaminating the original files
    root_path = copy_folder_for_experiment(original_root_path)

    template_name = "template"
    folders = find_template_folders(root_path, template_name + ".smt2")
    
    print(f"Found {len(folders)} tasks to solve")
    
    # Show the running mode
    if args.baseline:
        print("🎯 Running mode: Baseline mode (initial verification only)")
    else:
        print(f"🚀 Running mode: Full mode (with LLM lemma generation)")
        print(f"📝 Strategy mode: {args.strategy_mode}")
    
    # Storage for all results
    results = []
    total_start_time = time.time()
    
    # Build the task list with the baseline-mode and strategy-mode arguments
    task_list = [(folder, template_name, args.strategy_mode, args.baseline) for folder in folders]
    
    # Run in parallel with a process pool, up to MAX_PARALLEL_TASKS processes
    max_parallel_tasks = config['MAX_PARALLEL_TASKS']
    max_workers = min(max_parallel_tasks, len(folders), multiprocessing.cpu_count())
    print(f"Using {max_workers} parallel processes to process {len(folders)} tasks")
    
    # Counter for unsat tasks
    unsat_count = 0
    total_tasks = len(folders)
    
    # Use a progress bar together with the process pool
    with tqdm(total=len(folders), desc=f"Processing tasks (unsat: {unsat_count}/{total_tasks})", unit="task") as pbar:
        with ProcessPoolExecutor(max_workers=max_workers) as executor:
            # Submit all tasks
            future_to_folder = {executor.submit(process_single_task, task): task[0]
                              for task in task_list}
            
            # Collect results
            for future in as_completed(future_to_folder):
                folder_path = future_to_folder[future]
                try:
                    folder, final_status, duration, error = future.result()
                    
                    if error:
                        print(f"\nTask execution error: {os.path.basename(folder)} - error: {error}")
                        # Use the actual elapsed time instead of hardcoding 0.0
                        results.append((folder, False, duration))
                    else:
                        # Record the result
                        results.append((folder, final_status, duration))
                        
                        # If unsat, bump the counter
                        if final_status:
                            unsat_count += 1
                        
                        # Show task-completion feedback
                        result_text = "unsat" if final_status else "failed"
                        print(f"\nTask completed: {os.path.basename(folder)} - {result_text} - elapsed: {duration:.2f}s")
                        
                except Exception as e:
                    print(f"\nTask execution error: {os.path.basename(folder_path)} - error: {str(e)}")
                    # For exceptions where the result cannot be obtained, record -1 as the time
                    results.append((folder_path, False, -1))
                
                # Update the progress-bar description and progress
                pbar.set_description(f"Processing tasks (unsat: {unsat_count}/{total_tasks})")
                pbar.update(1)
    
    total_end_time = time.time()
    total_duration = total_end_time - total_start_time
    
    # Generate the CSV report
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    # Extract the dataset name (last component of root-path)
    dataset_name = os.path.basename(os.path.normpath(original_root_path))
    if args.baseline:
        csv_filename = f"results_{timestamp}_{dataset_name}_baseline.csv"
    else:
        csv_filename = f"results_{timestamp}_{dataset_name}_{args.strategy_mode}.csv"
    
    # Create the result_csv directory if it does not exist
    result_csv_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "result_csv")
    os.makedirs(result_csv_dir, exist_ok=True)
    
    csv_filepath = os.path.join(result_csv_dir, csv_filename)
    save_results_to_csv(results, csv_filepath, original_root_path)
    
    # Aggregate statistics
    successful_count = sum(1 for _, status, _ in results if status)
    total_count = len(results)
    
    print(f"\n=== Execution complete ===")
    print(f"Total tasks: {total_count}")
    print(f"Successfully solved: {successful_count}")
    print(f"Failed tasks: {total_count - successful_count}")
    print(f"Total elapsed time: {total_duration:.2f}s")
    print(f"Average time per task: {total_duration/total_count:.2f}s")
    print(f"Results saved to: {csv_filepath}")