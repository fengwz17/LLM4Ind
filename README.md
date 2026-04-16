# ProofMate (LLM4SMT)

Using LLMs to aid in solving SMT files with induction.

## Project Structure

```
LLM4Ind/
├── .env_template                 # .env template file (create .env based on this)
├── env_config.py                 # Environment configuration loading and LLM model initialization
├── logger_config.py              # Colored logging configuration
├── Mate_new.py                   # Core solver (CVC5/CVC4 + LLM lemma generation)
├── Mate_new_vampire.py           # Core solver (Vampire version)
├── cvc5_runner.py                # CVC5/CVC4 multi-strategy parallel verification runner
├── cvc5_parser.py                # CVC5 output parser
├── vampire_runner.py             # Vampire verification runner
├── run_exp_folder.py             # Batch experiment runner (multi-process parallel, with timeout control)
├── run_exp_folder_vampire.py     # Batch experiment runner (Vampire version)
├── run_all_benchmark.sh          # Full benchmark entry script (CVC5/CVC4)
├── run_all_benchmark_vampire.sh  # Full benchmark entry script (Vampire)
├── main.py                       # Single-task runner entry
├── preprocessed.py               # SMT2 preprocessing: parsing, restructuring, template generation
├── kill_cvc_processes.sh         # Clean up leftover CVC4/CVC5 processes
├── kill_vampire_processes.sh     # Clean up leftover Vampire processes
├── benchmarks/
│   ├── smtlib2/                  # Original SMT-LIB2 benchmark sets
│   │   ├── autoproof/
│   │   ├── dtt/
│   │   ├── ind-ben/
│   │   ├── int/
│   │   └── vmcai15-dt/
│   ├── preprocessed/             # Preprocessed benchmark sets
│   │   ├── all-int/
│   │   ├── autoproof/
│   │   ├── dtt/
│   │   ├── ind-ben/
│   │   └── vmcai15-dt/
│   └── do-not-supported-yet/     # ⚠️ Currently unsupported benchmark sets (not covered in the paper)
├── cvc/
│   ├── cvc5-Linux-x86_64-static/
│   │   └── bin/cvc5              # CVC5 solver executable
│   └── cvc4_binary/
│       └── cvc4-1.6-x86_64-linux-opt  # CVC4 solver executable
└── vampire/
    └── vampire                   # Vampire solver executable
```

## Usage

### 1. Environment Setup

Install Python dependencies:

```bash
pip install langchain_openai python-dotenv colorlog psutil tqdm
```

### 2. Configuration

Copy the template file and fill in your own API keys and paths:

```bash
cp .env_template .env
# Edit .env and replace sk-xxxxxxx with your actual API key
```

`.env_template` contains all configurable options with explanations; modify accordingly.

### 3. Preprocessing

Use `preprocessed.py` to preprocess the original SMT2 benchmarks:

```bash
python3 preprocessed.py
```

The preprocessed files are stored under `benchmarks/preprocessed/` (the existing benchmarks are already preprocessed).

> **⚠️ Note:** The `benchmarks/do-not-supported-yet/` directory contains benchmarks that are **not covered in the paper** and are currently **not supported**. Please do **not** run benchmarks from this directory.

### 4. Running

**Batch run (recommended):**

Use `run_all_benchmark.sh` to run all benchmark sets with a single command (you can directly modify the benchmarks directories to run inside this script; there is no need to use the `run_exp_folder.py` below):

```bash
bash run_all_benchmark.sh
```

You can modify the list of datasets to run and the log directory inside the script.

**Run a specified dataset:**

```bash
python3 run_exp_folder.py --root-path ./benchmarks/preprocessed/autoproof
```

Supported command-line arguments:

| Argument | Description |
|------|------|
| `--root-path` | Path to the preprocessed dataset |
| `--baseline` | Enable baseline mode (only run the solver's initial verification, without LLM) |
| `--strategy-mode` | Prompt strategy: `default` / `zero_shot` / `naive` |

**Run a single task:**

```bash
python3 main.py <base_path> <base_name>
```

### 5. Results

Run results are automatically saved to the `result_csv/` directory, with filenames in the format `results_<timestamp>_<dataset>_<mode>.csv`.

During experiment runs, the dataset is copied to the `result_files/` directory to avoid polluting the original files.

## Supported Models (not limited to those below; just configure your own API. Note: modify the definitions in env_config accordingly)

| MODEL_TYPE | Model | Provider |
|------------|-------|----------|
| `gpt-4o` (default) | GPT-5 | OpenRouter |
| `deepseek` | DeepSeek-Chat | DeepSeek API |
| `qwen` | Qwen3-235B | OpenRouter |
| `gemini` | Gemini 2.5 Flash | OpenRouter |

## Supported Solvers

- **CVC5** — supports multi-strategy parallel verification (simple / inductive / inductive-no-ematching)
- **CVC4** — inductive reasoning configuration
- **Vampire** — first-order logic theorem prover

## Publication

**Can LLM Aid in Solving Constraints with Inductive Definitions?**

Solving constraints involving inductive (aka recursive) definitions is challenging. State-of-the-art SMT/CHC solvers and first-order logic provers provide only limited support for solving such constraints, especially when they involve, e.g., abstract data types. In this work, we leverage structured prompts to elicit Large Language Models (LLMs) to generate auxiliary lemmas that are necessary for reasoning about these inductive definitions. We further propose a neuro-symbolic approach, which synergistically integrates LLMs with constraint solvers: the LLM iteratively generates conjectures, while the solver checks their validity and usefulness for proving the goal. We evaluate our approach on a diverse benchmark suite comprising constraints originating from algebraic data types and recurrence relations. The experimental results show that our approach can improve the state-of-the-art SMT and CHC solvers, solving considerably more (around 25%) proof tasks involving inductive definitions, demonstrating its efficacy.

**Full version paper:** [https://doi.org/10.48550/arXiv.2603.03668](https://doi.org/10.48550/arXiv.2603.03668)
