import os
from pathlib import Path

def process_smt_file(input_path, output_dir):
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Copy the original file to the target directory
    orig_path = output_dir / input_path.name
    with open(input_path, 'r') as src, open(orig_path, 'w') as dst:
        dst.write(src.read())

    # Read the original file contents
    with open(input_path, 'r') as f:
        lines = [line.rstrip('\n') for line in f]

    # Initialize the storage buckets
    sections = {
        'set_logic': [],
        'datatypes': [],
        'functions': [],
        'proof_goal': [],
        'check_exit': []
    }

    current_block = None
    paren_stack = 0
    proof_goal_lines = []  # stores multi-line content of the proof goal
    potential_proof_goal = False  # marks a possible start of a proof goal
    assert_paren_count = 0  # keeps the paren count for an assert

    for line in lines:
        # Strip comments (from semicolon onward)
        original_line = line  # keep the original line format
        if ';' in line:
            line = line.split(';', 1)[0].rstrip()
            original_line = line  # update the original line with comment removed
        stripped = line.strip()
        if not stripped:
            continue

        # Handle set-logic
        if stripped.startswith('(set-logic'):
            sections['set_logic'].append(original_line)
        
        # Handle datatypes (with parenthesis matching)
        elif stripped.startswith('(declare-datatypes'):
            current_block = 'datatypes'
            paren_stack = stripped.count('(') - stripped.count(')')
            sections[current_block].append(original_line)
        
        # Handle function declarations and ordinary asserts (but not the proof goal)
        elif stripped.startswith(('(declare-fun', '(assert (')) and not stripped.startswith('(assert (not') and not potential_proof_goal:
            current_block = 'functions'
            paren_stack = stripped.count('(') - stripped.count(')')
            sections[current_block].append(original_line)
        
        # Proof goal — case 1: (assert (not appears on the same line
        elif stripped.startswith('(assert (not'):
            current_block = 'proof_goal'
            proof_goal_lines = [original_line]
            paren_stack = stripped.count('(') - stripped.count(')')
            potential_proof_goal = False
            # Finish immediately if already balanced
            if paren_stack == 0:
                sections['proof_goal'].append(' '.join([line.strip() for line in proof_goal_lines]))
                proof_goal_lines = []
                current_block = None
        
        # Proof goal — case 2: (assert on its own line, possibly the start of a proof goal
        elif stripped.startswith('(assert') and not stripped.startswith('(assert ('):
            potential_proof_goal = True
            proof_goal_lines = [original_line]
            assert_paren_count = stripped.count('(') - stripped.count(')')
        
        # Proof goal — case 3: (not encountered while in the potential_proof_goal state
        elif potential_proof_goal and stripped.startswith('(not'):
            current_block = 'proof_goal'
            proof_goal_lines.append(original_line)
            paren_stack = assert_paren_count + stripped.count('(') - stripped.count(')')
            potential_proof_goal = False
            # Finish immediately if already balanced
            if paren_stack == 0:
                sections['proof_goal'].append(' '.join([line.strip() for line in proof_goal_lines]))
                proof_goal_lines = []
                current_block = None
        
        # Proof goal — case 4: other content encountered in potential_proof_goal state means it is not a proof goal
        elif potential_proof_goal and not stripped.startswith('(not'):
            # Not a proof goal; treat it as an ordinary function
            current_block = 'functions'
            paren_stack = assert_paren_count
            sections[current_block].extend(proof_goal_lines)
            sections[current_block].append(original_line)
            paren_stack += stripped.count('(') - stripped.count(')')
            potential_proof_goal = False
            proof_goal_lines = []
            if paren_stack <= 0:
                current_block = None
        
        # Proof goal — continuation
        elif current_block == 'proof_goal':
            proof_goal_lines.append(original_line)
            paren_stack += stripped.count('(') - stripped.count(')')
            # If parens are balanced, finalize the proof goal
            if paren_stack <= 0:
                sections['proof_goal'].append(' '.join([line.strip() for line in proof_goal_lines]))
                proof_goal_lines = []
                current_block = None
        
        # Handle other multi-line declarations
        elif current_block in ['datatypes', 'functions']:
            sections[current_block].append(original_line)
            paren_stack += stripped.count('(') - stripped.count(')')
            if paren_stack <= 0:
                current_block = None
        
        # Preserve trailing commands
        elif stripped.startswith(('(check-sat', '(exit')):
            sections['check_exit'].append(original_line)

    # Handle an unfinished potential_proof_goal (if the file ends while still in this state)
    if potential_proof_goal and proof_goal_lines:
        sections['functions'].extend(proof_goal_lines)

    # Generate the template file
    with open(output_dir / "template.smt2", 'w') as f:
        # Write set-logic
        if sections['set_logic']:
            f.write(sections['set_logic'][0] + '\n\n')
        
        # Write datatypes
        if sections['datatypes']:
            f.write('; datatypes\n')
            f.write('\n'.join(sections['datatypes']) + '\n')
            f.write('; datatypes end\n\n')
        
        # Write function declarations
        if sections['functions']:
            f.write('; functions declarations\n')
            f.write('\n'.join(sections['functions']) + '\n')
            f.write('; functions declarations end\n\n')
        
        # Write the proof goal
        if sections['proof_goal']:
            f.write('; proof goal\n')
            for goal in sections['proof_goal']:
                f.write(goal + '\n')
            f.write('; proof goal end\n\n')
        
        # Write trailing commands
        if sections['check_exit']:
            f.write('\n'.join(sections['check_exit']) + '\n')

def process_directory(source_dir, target_root):
    for root, _, files in os.walk(source_dir):
        for file in files:
            if file.endswith('.smt2'):
                input_path = Path(root) / file
                # Preserve the directory structure: create the same relative path under the target root
                relative_path = input_path.relative_to(source_dir).parent
                output_dir = target_root / relative_path / file[:-5]
                process_smt_file(input_path, output_dir)

if __name__ == '__main__':
    process_directory(
        Path('preprocessed/autoproof/standard'),
        Path('preprocessed/auto/standard')
    )