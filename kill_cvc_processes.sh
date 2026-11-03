#!/bin/bash

# Script that kills all cvc4 and cvc5 processes.
# Keeps running until no cvc4 or cvc5 processes remain.

echo "Starting to kill all cvc4 and cvc5 processes..."

while true; do
    # Get the PIDs of all cvc4 and cvc5 processes
    pids=$(ps aux | grep -E 'cvc[45]' | grep -v grep | grep -v kill_cvc5.sh | awk '{print $2}')
    
    if [ -z "$pids" ]; then
        echo "No cvc4 or cvc5 processes found; done!"
        break
    else
        echo "Found $(echo $pids | wc -w) cvc4/cvc5 processes; terminating..."
        # Kill every process found
        echo $pids | xargs kill -9 2>/dev/null
        echo "Termination signal sent; checking again in 2 seconds..."
        sleep 2
    fi
done

echo "All cvc4 and cvc5 processes have been terminated!"