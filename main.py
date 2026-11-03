#!/usr/bin/env python3
"""
Main program entry file
Invokes the solver functionality in Mate_new.py
"""

import sys
import logging

# Import the solver module

# Import the solver module
import Mate_new as mate_solver

# Obtain the prove_run function
prove_run = mate_solver.prove_run

if __name__ == "__main__":
    # Arguments reduced to just the path and the base filename
    if len(sys.argv) < 3:
        print("Usage: python3 main.py <base_path> <base_name>")
        sys.exit(1)
    
    base_path = sys.argv[1]
    base_name = sys.argv[2]
    
    # Start the verification process
    final_status = prove_run(base_path, base_name)
    
    # Print the final result
    logging.info("Final verification conclusion: %s", "Success" if final_status else "Fail")
    logging.info("unsat" if final_status else "")
    sys.exit(0 if final_status else 1)