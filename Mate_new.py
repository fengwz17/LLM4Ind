import re
import logging
import sys
import json
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import List, Tuple, Optional
from logger_config import setup_colored_logger
from env_config import setup_environment, setup_model
from cvc5_runner import run_cvc_solver_with_timeout

# Configure colored logging
logger = setup_colored_logger()
config = setup_environment()

# Initialize the model
llm = setup_model(config)

# Failed-lemma management functions are defined at the top of the file
def get_failed_lemmas_file(base_path: str, goal_name: str) -> Path:
    """Get the file path for failed-lemma records; the filename is derived from the goal name."""
    # Extract the suffix of the goal name to build the filename
    if goal_name == "template":
        filename = "failed_lemmas.json"
    else:
        # Extract the part after "template", e.g. template_1 -> _1, template_1_2 -> _1_2
        suffix = goal_name.replace("template", "")
        filename = f"failed_lemmas{suffix}.json"
    
    return Path(base_path) / filename

def load_failed_lemmas(base_path: str, goal_name: str) -> dict:
    """Load failed-lemma records"""
    failed_file = get_failed_lemmas_file(base_path, goal_name)
    if failed_file.exists():
        try:
            with open(failed_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            logging.warning(f"Error loading failed-lemma file: {e}")
    return {"invalid_lemmas": [], "useless_lemma_groups": []}

def save_failed_lemmas(base_path: str, goal_name: str, failed_data: dict):
    """Save failed-lemma records"""
    failed_file = get_failed_lemmas_file(base_path, goal_name)
    try:
        with open(failed_file, 'w', encoding='utf-8') as f:
            json.dump(failed_data, f, ensure_ascii=False, indent=2)
        # logging.info(f"Saved failed lemmas to: {failed_file.name}")
    except Exception as e:
        logging.error(f"Error saving failed-lemma file: {e}")

def add_invalid_lemma(base_path: str, goal_name: str, lemma: str, reason: str):
    """Add an invalid-lemma record"""
    failed_data = load_failed_lemmas(base_path, goal_name)
    lemma_record = {"lemma": lemma, "reason": reason}
    if lemma_record not in failed_data["invalid_lemmas"]:
        failed_data["invalid_lemmas"].append(lemma_record)
        save_failed_lemmas(base_path, goal_name, failed_data)
        # logging.info(f"Recorded invalid lemma for {goal_name}: {reason} - {lemma[:50]}...")

def add_useless_lemma_group(base_path: str, goal_name: str, lemma_group: List[str]):
    """Add a useless-lemma-group record"""
    failed_data = load_failed_lemmas(base_path, goal_name)
    if lemma_group not in failed_data["useless_lemma_groups"]:
        failed_data["useless_lemma_groups"].append(lemma_group)
        save_failed_lemmas(base_path, goal_name, failed_data)
        logging.info(f"Recorded useless lemma group for {goal_name}: {len(lemma_group)} lemmas")

def create_prompt(smt_file_content: str, prompt_mode: str, base_path: str = None, goal_name: str = None, folder_path: str = None) -> list:
    """Create a structured message list for the LLM"""
    if folder_path is None:
        raise ValueError("folder path of prompts must be provided")

    with open(f"{folder_path}/{prompt_mode}/system_prompt.txt", "r", encoding="utf-8") as file:
        system_prompt_content = file.read()
    with open(f"{folder_path}/{prompt_mode}/user_prompt.txt", "r", encoding="utf-8") as file:
        user_prompt_content = file.read()
    # Append information about previously failed lemmas
    failed_info = ""
    if base_path and goal_name:
        failed_data = load_failed_lemmas(base_path, goal_name)
        
        if failed_data["invalid_lemmas"]:
            failed_info += "\n\n; IMPORTANT: The following lemmas are INVALID or CANNOT be verified. DO NOT generate these lemmas:\n"
            for i, record in enumerate(failed_data["invalid_lemmas"], 1):
                failed_info += f"; Invalid lemma {i} ({record['reason']}): {record['lemma']}\n"
        
        if failed_data["useless_lemma_groups"]:
            failed_info += "\n; IMPORTANT: The following lemma groups are USELESS for proving the original goal. DO NOT generate the exact same group:\n"
            for i, group in enumerate(failed_data["useless_lemma_groups"], 1):
                failed_info += f"; Useless group {i}:\n"
                for j, lemma in enumerate(group, 1):
                    failed_info += f";   {j}. {lemma}\n"
    
    # Build the structured message list
    user_content = user_prompt_content.format(smt_file_content=smt_file_content) + failed_info
    
    messages = [
        {"role": "system", "content": system_prompt_content},
        {"role": "user", "content": user_content}
    ]
    
    return messages

def extract_balanced_forall(assert_not_content: str) -> Optional[str]:
    """Extract a balanced forall expression"""
    # First, locate the start position of forall
    start_match = re.search(r'\(\s*forall', assert_not_content)
    if not start_match:
        return None
    
    start_pos = start_match.start()
    balance = 0
    end_pos = start_pos
    
    # Scan from the start of forall to find the matching closing parenthesis
    for i, c in enumerate(assert_not_content[start_pos:]):
        if c == '(':
            balance += 1
        elif c == ')':
            balance -= 1
            if balance == 0:
                end_pos = start_pos + i + 1
                break
    
    return assert_not_content[start_pos:end_pos]

def parse_llm_response(response: str) -> List[str]:
    """Parse the LLM output and extract valid assertions"""
    pattern = r'; Output begin(.*?); Output end'
    match = re.search(pattern, response, re.DOTALL)
    if not match:
        raise ValueError("Malformed response: missing output markers")

    result = []
    for line in match.group(1).split('\n'):
        line = line.strip()
        if not line:
            continue
        
        # Use the existing extract_balanced_forall function to extract forall content
        # This handles both (forall...) and (assert (forall...)) cases
        forall_content = extract_balanced_forall(line)
        if forall_content:
            result.append(forall_content)
    
    return result

def verify_combined_lemmas(original_assert: re.Match, asserts: List[str], original_content: str, output_path: Path) -> bool:
    
    """Verify the effectiveness of the combined lemmas"""
    combined_asserts = "\n".join([f"(assert {a})" for a in asserts])

    # Insert the lemmas before the proof goal, keeping the proof-goal block unchanged
    new_content = re.sub(
        r'; proof goal',
        combined_asserts + "\n; proof goal",
        original_content,
        count=1
    )

    output_path.write_text(new_content)
    combined_cvc_timeout = config['COMBINED_CVC_TIMEOUT']
    return run_cvc_solver_with_timeout(output_path, combined_cvc_timeout)


def perform_initial_verification(goal_smt_file: Path) -> bool:
    """Perform the initial verification check"""
    default_timeout = config['DEFAULT_CVC_TIMEOUT']
    logging.info(f"🔍 Performing initial check, target file: {goal_smt_file}")
    if run_cvc_solver_with_timeout(goal_smt_file, default_timeout):
        logging.info("✅ Original goal verified directly!")
        return True
    
    logging.error("CVC5 verification failed, starting to generate new lemmas...")
    return False


def extract_original_goal(smt_content: str) -> Tuple[re.Match, str]:
    """Extract the original goal assertion and forall expression"""
    original_assert = re.search(
        r'; proof goal\s*(\(assert.*?\))\s*; proof goal end',
        smt_content,
        flags=re.DOTALL
    )
    original_forall = extract_balanced_forall(original_assert.group(1))
    logging.info(f"Extracted original goal: {original_assert.group(1)}, forall expression: {original_forall}")
    return original_assert, original_forall

def generate_lemmas_with_llm(smt_content: str, prompt_strategy: str, goal_smt_file: Path, base_path: str, goal_name: str, folder_path: str) -> List[str]:
    """Use an LLM to generate lemmas"""
    logging.info(f"About to generate lemmas with the LLM, target file: {goal_smt_file}, prompt strategy: {prompt_strategy}")
    messages = create_prompt(smt_content, prompt_strategy, base_path, goal_name, folder_path)
    response = llm.invoke(messages)
    extracted_asserts = parse_llm_response(response.content)
    
    # logging.info(f"LLM response: {response.content}")
    logging.info("Extracted lemmas from LLM response: %s", extracted_asserts)
    
    return extracted_asserts

def normalize_formula(formula: str) -> str:
    """Enhanced formula normalization function"""
    # 1. Clean up whitespace
    formula = re.sub(r'\s+', ' ', formula.strip())
    
    # 2. Find the forall keyword
    forall_pos = formula.find('forall')
    if forall_pos == -1:
        return formula
    
    # 3. Manually parse the variable-definition section
    ptr = forall_pos + len('forall')
    while ptr < len(formula) and formula[ptr] in ' \t\n':
        ptr += 1
    
    if ptr >= len(formula) or formula[ptr] != '(':
        return formula
    
    # Locate the end of the variable-definition section
    balance = 0
    var_def_start = ptr
    for i in range(ptr, len(formula)):
        if formula[i] == '(':
            balance += 1
        elif formula[i] == ')':
            balance -= 1
            if balance == 0:
                var_def_end = i + 1
                break
    else:
        return formula
    
    # Extract the variable definitions and the formula body
    var_section = formula[var_def_start+1:var_def_end-1]
    body_start = var_def_end
    while body_start < len(formula) and formula[body_start] in ' \t\n':
        body_start += 1
    
    # Locate the formula body
    balance = 0
    body_end = len(formula)
    for i in range(body_start, len(formula)):
        if formula[i] == '(':
            balance += 1
        elif formula[i] == ')':
            balance -= 1
            if balance == 0:
                body_end = i + 1
                break
    
    body = formula[body_start:body_end]
    
    # 4. Parse the variable definitions
    var_defs = re.findall(r'\(\s*(\w+)\s+(\w+)\s*\)', var_section)
    if not var_defs:
        return formula
    
    # 5. Create a variable mapping
    var_map = {var: f'a{i}' for i, (var, _) in enumerate(var_defs)}
    
    # 6. Substitute variables
    normalized_body = body
    for old_var, new_var in sorted(var_map.items(), key=lambda x: -len(x[0])):
        normalized_body = re.sub(rf'\b{re.escape(old_var)}\b', new_var, normalized_body)
    
    # 7. Reconstruct the formula
    normalized_vars = ' '.join(f'({var_map[var]} {typ})' for var, typ in var_defs)
    return f'(forall ({normalized_vars}) {normalized_body})'

def extract_equality_parts(formula: str):
    """Extract the left- and right-hand sides of an equality"""
    # Find the outermost equality
    eq_start = formula.rfind('(=')
    if eq_start == -1:
        return None, None
    
    # Find the end of the equality
    balance = 0
    eq_end = len(formula)
    for i in range(eq_start, len(formula)):
        if formula[i] == '(':
            balance += 1
        elif formula[i] == ')':
            balance -= 1
            if balance == 0:
                eq_end = i + 1
                break
    
    # Extract the contents of the equality (stripping "(= " and ")")
    eq_content = formula[eq_start + 3:eq_end - 1].strip()
    
    # Manually parse the left and right sides
    balance = 0
    parts = []
    current_part = ""
    
    for char in eq_content:
        if char == '(':
            balance += 1
            current_part += char
        elif char == ')':
            balance -= 1
            current_part += char
        elif char == ' ' and balance == 0:
            if current_part.strip():
                parts.append(current_part.strip())
                current_part = ""
        else:
            current_part += char
    
    if current_part.strip():
        parts.append(current_part.strip())
    
    if len(parts) >= 2:
        return parts[0], parts[1]
    return None, None

def normalize_equality_order(formula: str) -> str:
    """Normalize the left/right order of an equality"""
    # Extract the left and right parts of the equality
    left, right = extract_equality_parts(formula)
    if left is None or right is None:
        return formula
    
    # Sort lexicographically so that identical equalities get a uniform ordering
    if left <= right:
        return formula  # already in canonical order
    else:
        # Swap left and right — we need to locate and replace the full equality
        eq_start = formula.rfind('(=')
        if eq_start == -1:
            return formula
            
        # Find the end of the equality
        balance = 0
        eq_end = len(formula)
        for i in range(eq_start, len(formula)):
            if formula[i] == '(':
                balance += 1
            elif formula[i] == ')':
                balance -= 1
                if balance == 0:
                    eq_end = i + 1
                    break
        
        # Construct the new equality
        new_equality = f'(= {right} {left})'
        return formula[:eq_start] + new_equality + formula[eq_end:]

def are_formulas_equivalent(formula1: str, formula2: str) -> bool:
    """Enhanced equivalence check between two formulas"""
    try:
        # 1. Normalize the two formulas
        norm1 = normalize_formula(formula1)
        norm2 = normalize_formula(formula2)
        
        # 2. Normalize equality ordering
        norm1 = normalize_equality_order(norm1)
        norm2 = normalize_equality_order(norm2)
        
        # 3. Compare the normalized formulas
        return norm1 == norm2
        
    except Exception as e:
        # print(f"Error during normalization: {e}; falling back to simple comparison")
        return formula1.strip() == formula2.strip()

def validate_lemmas_against_original(extracted_asserts: List[str], original_forall: str, base_path: str, goal_name: str) -> bool:
    """Enhanced lemma-validation function"""
    for i, assert_stmt in enumerate(extracted_asserts, 1):
        if are_formulas_equivalent(assert_stmt, original_forall):
            # logging.error(f"Lemma {i} is the same as the original goal; generation failed")
            # add_invalid_lemma(base_path, goal_name, assert_stmt, "Same as original goal")
            return False
    return True


def create_validation_files(extracted_asserts: List[str], smt_content: str,
                          smt_file_path: Path, goal_smt_name: str) -> List[Path]:
    """Create files for lemma-validity checking"""
    valid_check_paths = []
    for i, assert_stmt in enumerate(extracted_asserts, 1):
        valid_content = re.sub(
            r'; proof goal\s*\(assert.*?\)\s*; proof goal end',
            f'; proof goal\n(assert {assert_stmt})\n; proof goal end',
            smt_content,
            flags=re.DOTALL
        )
        valid_path = smt_file_path / f"{goal_smt_name}_valid_{i}.smt2"
        valid_path.write_text(valid_content)
        valid_check_paths.append(valid_path)
    return valid_check_paths


def verify_single_lemma(valid_path: Path) -> Tuple[Path, bool]:
    """Verify the validity of a single lemma"""
    logging.info(f"Starting validity check: {valid_path.name}")
    result = run_cvc_solver_with_timeout(valid_path, timeout=1)
    logging.info(f"Validity check finished: {valid_path.name}, returned {result}")
    return valid_path, result


def validate_lemmas_parallel(valid_check_paths: List[Path], base_path: str, goal_name: str) -> bool:
    """Validate lemma validity in parallel"""
    invalid_lemmas = []
    max_workers = min(len(valid_check_paths), 4)
    
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        future_to_path = {executor.submit(verify_single_lemma, path): path
                         for path in valid_check_paths}
        
        for future in as_completed(future_to_path):
            try:
                valid_path, result = future.result()
                if result:
                    # logging.warning(f"Found an invalid lemma: {valid_path.name}")
                    invalid_lemmas.append(valid_path)
                    # Record the invalid lemma
                    lemma_content = extract_lemma_from_file(valid_path)
                    if lemma_content:
                        add_invalid_lemma(base_path, goal_name, lemma_content, "verification failed")
                else:
                    logging.error(f"Cannot filter out the lemma for now: {valid_path.name}")
            except Exception as e:
                path = future_to_path[future]
                #logging.error(f"Exception while verifying lemma {path.name}: {e}")
                invalid_lemmas.append(path)
                # Record the lemma that triggered an exception
                lemma_content = extract_lemma_from_file(path)
                if lemma_content:
                    add_invalid_lemma(base_path, goal_name, lemma_content, f"verification exception: {e}")
    
    if invalid_lemmas:
        # logging.error("Illegal lemmas found; regeneration required")
        return False
    return True

def extract_lemma_from_file(file_path: Path) -> str:
    """Extract the lemma content from a validation file"""
    try:
        content = file_path.read_text()
        match = re.search(r'; proof goal\s*\(assert\s+(.+?)\)\s*; proof goal end', content, re.DOTALL)
        if match:
            return match.group(1).strip()
    except Exception as e:
        logging.error(f"Failed to extract lemma content: {e}")
    return None


def generate_formal_proof_files(extracted_asserts: List[str], smt_content: str,
                        smt_file_path: Path, goal_smt_name: str) -> List[str]:
    """Generate formal verification files (with negated lemmas)"""
    generated_files = []
    for i, assert_stmt in enumerate(extracted_asserts, 1):
        lemma_content = re.sub(
            r'; proof goal\s*\(assert.*?\)\s*; proof goal end',
            f'; proof goal\n(assert (not {assert_stmt}))\n; proof goal end',
            smt_content,
            flags=re.DOTALL
        )
        lemma_path = smt_file_path / f"{goal_smt_name}_{i}.smt2"
        lemma_path.write_text(lemma_content)
        generated_files.append(lemma_path.name.split('.')[0])
        logging.info(f"Generated verification file: {lemma_path.name}")
    return generated_files


def quick_run(base_path: str, goal_smt_name: str, prompt_strategy: str, folder_path: str, baseline_only: bool = False) -> Tuple[bool, List[str], List[str]]:
    """Quick-run function; returns the verification result, subgoal files, and generated lemmas"""
    smt_file_path = Path(base_path)
    goal_smt_file = smt_file_path / f"{goal_smt_name}.smt2"
    smt_content = goal_smt_file.read_text()

    # Step 1: initial verification check
    if baseline_only:
        # In baseline mode, use task_timeout as the timeout
        task_timeout = config['TASK_TIMEOUT']
        logging.info(f"🔍 Baseline mode: performing initial verification check, timeout: {task_timeout}s")
        result = run_cvc_solver_with_timeout(goal_smt_file, task_timeout)
        if result:
            logging.info("✅ Baseline mode: initial verification succeeded!")
        else:
            logging.info("❌ Baseline mode: initial verification failed")
        return result, [], []

    # Step 2: extract the original goal
    original_assert, original_forall = extract_original_goal(smt_content)
    
    # Step 3: use the LLM to generate lemmas
    extracted_asserts = generate_lemmas_with_llm(smt_content, prompt_strategy, goal_smt_file, base_path, goal_smt_name, folder_path)

    # If no lemmas were generated, try re-verifying with a longer timeout
    if not extracted_asserts:
        logging.info("The LLM returned no lemmas; retrying with an increased timeout on the original goal")
        retry_timeout = config['RETRY_CVC_TIMEOUT']
        if run_cvc_solver_with_timeout(goal_smt_file, retry_timeout):
            logging.info("Original goal succeeded after increasing the timeout to %d seconds!", retry_timeout)
            return True, [], []
        return False, [], []

    # TODO: remove this section for the ablation study ↓
    # Step 4: check whether the lemmas are identical to the original goal
    if not validate_lemmas_against_original(extracted_asserts, original_forall, base_path, goal_smt_name):
        return False, [], extracted_asserts

    # Step 5: create validation files and check lemma validity in parallel
    valid_check_paths = create_validation_files(extracted_asserts, smt_content, smt_file_path, goal_smt_name)
    
    if not validate_lemmas_parallel(valid_check_paths, base_path, goal_smt_name):
        return False, [], extracted_asserts


    # Step 6: check whether the lemmas help prove the original goal
    combined_path = smt_file_path / f"{goal_smt_name}_with_lemmas.smt2"
    if not verify_combined_lemmas(original_assert, extracted_asserts, smt_content, combined_path):
        logging.error("Generated lemmas did not help prove the original goal")
        # Record the useless lemma group
        add_useless_lemma_group(base_path, goal_smt_name, extracted_asserts)
        return False, [], extracted_asserts
    else:
        logging.info("Lemmas are useful; generating lemma verification files to check whether the lemmas hold")

    # Step 7: generate formal verification files
    generated_files = generate_formal_proof_files(extracted_asserts, smt_content, smt_file_path, goal_smt_name)
    
    return True, generated_files, extracted_asserts

def prove_subgoals_parallel(base_path: str, subgoals: List[str], depth: int = 0, strategy_mode: str = "default", baseline_only: bool = False, parent_lemmas: List[str] = None, parent_goal_name: str = None) -> bool:
    """Verify multiple subgoals in parallel; abort all processes as soon as any one fails"""
    if not subgoals:
        return True
    
    logging.info(f"🚀 Starting parallel verification of {len(subgoals)} subgoals: {subgoals} (recursion depth: {depth})")
    
    # Use ThreadPoolExecutor for parallel execution
    with ThreadPoolExecutor(max_workers=min(len(subgoals), 4)) as executor:
        # Submit all tasks, passing the incremented depth argument
        future_to_subgoal = {executor.submit(prove_run, base_path, subgoal, depth + 1, strategy_mode, baseline_only): subgoal
                            for subgoal in subgoals}
        
        try:
            # Wait for tasks to complete; return immediately on any failure
            for future in as_completed(future_to_subgoal):
                subgoal = future_to_subgoal[future]
                try:
                    result = future.result()
                    if not result:
                        logging.error(f"💥 Subgoal {subgoal} verification failed; aborting all parallel tasks")
                        # Record lemmas that caused the subgoal failure in the parent goal's failure records
                        if parent_lemmas and parent_goal_name:
                            for lemma in parent_lemmas:
                                add_invalid_lemma(base_path, parent_goal_name, lemma, f"Caused subgoal {subgoal} verification failure")
                        # Cancel all unfinished tasks
                        for f in future_to_subgoal:
                            if not f.done():
                                f.cancel()
                        return False
                    else:
                        logging.info(f"✅ Subgoal {subgoal} verification succeeded")
                except Exception as e:
                    logging.error(f"💥 Subgoal {subgoal} raised an exception: {e}; aborting all parallel tasks")
                    # Record lemmas that caused the exception in the parent goal's failure records
                    if parent_lemmas and parent_goal_name:
                        for lemma in parent_lemmas:
                            add_invalid_lemma(base_path, parent_goal_name, lemma, f"Caused subgoal {subgoal} execution exception: {e}")
                    # Cancel all unfinished tasks
                    for f in future_to_subgoal:
                        if not f.done():
                            f.cancel()
                    return False
            
            logging.info(f"🌟 All {len(subgoals)} subgoals verified successfully in parallel")
            return True
            
        except KeyboardInterrupt:
            logging.warning("Received interrupt signal; cancelling all parallel tasks")
            for f in future_to_subgoal:
                if not f.done():
                    f.cancel()
            return False


def prove_run(base_path: str, base_name: str, depth: int = 0, strategy_mode: str = "default", baseline_only: bool = False) -> bool:
    """Recursive verification function driven by prompt strategies — main program entry"""
    # Check the recursion-depth limit
    max_depth = config['MAX_RECURSION_DEPTH']
    if depth >= max_depth:
        logging.warning(f"🚫 Reached maximum recursion depth {max_depth}; stopping processing of {base_name}")
        return False
    
    # In baseline mode, just call quick_run for the initial verification
    if baseline_only:
        logging.info(f"🎯 Baseline mode: starting processing of {base_name}")
        result, _, _ = quick_run(base_path, base_name, "", "", baseline_only=True)
        return result
    
    logging.info(f"Starting processing — Path: {base_path}, Name: {base_name} (recursion depth: {depth})")

    # Perform the initial verification check
    goal_smt_file = Path(base_path) / f"{base_name}.smt2"
    if perform_initial_verification(goal_smt_file):
        return True

    # Define prompt strategies
    prompt_default_strategies = [
        "prove_prompt_equational_reasoning",
        "prove_prompt_term_rewrite"
    ]

    # "Ours" strategy list
    prompts_ours_strategies = [
        "prove_prompt_equational_reasoning",
        "prove_prompt_term_rewrite"
    ]

    prompts_naive_strategies = [
        "prompt_naive"  # When this runs, it should execute 2x3=6 times
    ]

    default_prompt_strategies = {
        "folder_path": "./prompts_ours",
        "strategies": prompt_default_strategies,
        "max_attempts": config['MAX_ATTEMPTS_PER_PROMPT']
    }

    ours_prompt_strategies = {
        "folder_path": "./prompts_ours",
        "strategies": prompts_ours_strategies,
        "max_attempts": config['MAX_ATTEMPTS_PER_PROMPT']
    }

    naive_prompt_strategies = {
        "folder_path": "./prompts_naive",
        "strategies": prompts_naive_strategies,
        "max_attempts": config['MAX_ATTEMPTS_PER_PROMPT'] * 2
    }
    
    select_use_prompt_strategies = ours_prompt_strategies

    max_attempts_per_prompt = select_use_prompt_strategies["max_attempts"]

    # Try each prompt strategy in order
    for prompt_idx, prompt_strategy in enumerate(select_use_prompt_strategies["strategies"]):
        logging.info(f"[Strategy {prompt_idx+1}] Processing {base_name} — using strategy {prompt_strategy}")
        
        # Try each prompt up to max_attempts_per_prompt times (currently defaults to 3)
        for attempt in range(max_attempts_per_prompt):
            logging.info(f"[Main phase] Processing {base_name} — attempt {attempt+1}/{max_attempts_per_prompt} ({prompt_strategy})")
            try:
                ret, new_subgoals, extracted_asserts = quick_run(base_path, base_name, prompt_strategy, select_use_prompt_strategies["folder_path"], baseline_only=False)
                # ret == True means potentially useful subgoals were found, NOT that the proof succeeded
                # The lemmas passed quick filtering
                # If the lemmas are useful but the lemmas themselves could not be verified, allow 5 attempts
                if ret:
                    logging.info(f"🎯 Strategy {prompt_strategy} attempt {attempt+1}: successfully searched for potentially useful lemmas!")
                    
                    # Proof succeeded — no subgoals left
                    if not new_subgoals:
                        logging.info(f"🏆 Subgoal {base_name} proof completed!")
                        return True

                    # Handle subgoals — parallel execution
                    logging.info(f"🔍 Discovered subgoals: {new_subgoals}")
                    # Pass the currently generated lemmas and goal name
                    current_lemmas = extracted_asserts
                    if prove_subgoals_parallel(base_path, new_subgoals, depth, strategy_mode, baseline_only, current_lemmas, base_name):
                        logging.info(f"🌟 All subgoals verified; {base_name} ultimately succeeded")
                        return True
                    else:
                        logging.warning(f"💥 Subgoal verification failed; continuing with the next generation attempt")
                        # Do not return False directly; continue with the next attempt
                        continue
                    
            except TimeoutError:
                logging.warning(f"Strategy {prompt_strategy} attempt {attempt+1} timed out")
                continue
            except Exception as e:
                logging.error(f"Strategy {prompt_strategy} attempt {attempt+1} raised an error: {e}")
                continue
            
        logging.error(f"All attempts of strategy {prompt_strategy} failed; switching to the next strategy")

    # All strategies and attempts have failed
    logging.error(f"🚫 All strategies failed for {base_name}")
    return False
