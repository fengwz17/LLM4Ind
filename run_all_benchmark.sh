#!/bin/bash

# Configure the log directory path (change as needed)
# LOG_DIR="logs_ours_prompt1x6_depth3"
LOG_DIR="logs_ours_qwen3"

# Create the logs directory if it does not exist
mkdir -p "$LOG_DIR"

echo "Starting all benchmarks - $(date)"
echo "Log files will be saved under $LOG_DIR/"

# Directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define the datasets
# declare -a datasets=("autoproof" "dtt")
declare -a datasets=("ind-ben" "vmcai15-dt")

# Run each command sequentially
for dataset in "${datasets[@]}"; do
    # Build the path from the dataset name
    path="$SCRIPT_DIR/benchmarks/preprocessed/$dataset"
    # Generate a fresh timestamp for each dataset
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    logfile="$LOG_DIR/${TIMESTAMP}_${dataset}.log"
    
    echo "=========================================="
    echo "Running dataset: $dataset"
    echo "Log file: $logfile"
    echo "Start time: $(date)"
    echo "=========================================="
    
    # Run the command and redirect output to the log file
    # kill all unuse processes
    sleep 10
    python3 run_exp_folder.py --root-path "$path" 2>&1 | tee "$logfile"
    # Sleep 10 seconds to let CVC5 processes finish
    sleep 10
    ./kill_cvc_processes.sh
    sleep 10
    # Check the command's exit status
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo "✓ Dataset $dataset succeeded"
        echo "Execution succeeded - end time: $(date)" >> "$logfile"
    else
        echo "✗ Dataset $dataset failed"
        echo "Execution failed - end time: $(date)" >> "$logfile"
        echo "Error: dataset $dataset failed; please check the log file $logfile"
    fi
    
    echo ""
done

echo "=========================================="
echo "All benchmarks finished - $(date)"
echo "All log files have been saved under $LOG_DIR/"
echo "=========================================="