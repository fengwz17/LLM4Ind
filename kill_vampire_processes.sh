#!/bin/bash

# Script that kills all vampire processes.
# Keeps running until no vampire processes remain.

echo "Starting to kill all vampire processes..."

# Get this script's own PID so we can exclude it
SCRIPT_PID=$$

while true; do
    # Get the PIDs of all vampire processes.
    # Match only the actual vampire executable, excluding:
    # 1. the grep process itself
    # 2. the kill_vampire_processes.sh script
    # 3. unrelated processes such as SCREEN sessions
    # 4. this script itself
    pids=$(ps aux | grep -E '[^/]vampire[^/]|/vampire/vampire|vampire\.smt2' | \
           grep -v grep | \
           grep -v 'kill_vampire' | \
           grep -v 'SCREEN' | \
           grep -v "$$" | \
           awk '{print $2}')
    
    if [ -z "$pids" ]; then
        echo "No vampire processes found; done!"
        break
    else
        count=$(echo $pids | wc -w)
        echo "Found $count vampire processes; terminating..."
        
        # First, try a graceful termination
        for pid in $pids; do
            # Check whether the process still exists
            if ps -p $pid > /dev/null 2>&1; then
                # Try to terminate the process group
                kill -TERM -$pid 2>/dev/null || kill -TERM $pid 2>/dev/null
            fi
        done
        
        # Wait for the processes to exit
        sleep 2
        
        # Check whether any processes are still alive; force-kill them if so
        remaining_pids=$(ps aux | grep -E '[^/]vampire[^/]|/vampire/vampire|vampire\.smt2' | \
                         grep -v grep | \
                         grep -v 'kill_vampire' | \
                         grep -v 'SCREEN' | \
                         grep -v "$$" | \
                         awk '{print $2}')
        
        if [ -n "$remaining_pids" ]; then
            echo "Force-terminating remaining processes..."
            echo $remaining_pids | xargs kill -9 2>/dev/null
        fi
        
        echo "Termination signal sent; checking again in 2 seconds..."
        sleep 2
    fi
done

echo "All vampire processes have been terminated!"

