# ProofMate (LLM4SMT)

Using LLMs to aid in solving SMT files with induction.

## Project Structure

```
LLM4Ind/
├── .env_template                 # .env 模板文件（参照此文件创建 .env）
├── env_config.py                 # 环境配置加载与LLM模型初始化
├── logger_config.py              # 彩色日志配置
├── Mate_new.py                   # 核心求解器（CVC5/CVC4 + LLM引理生成）
├── Mate_new_vampire.py           # 核心求解器（Vampire版本）
├── cvc5_runner.py                # CVC5/CVC4 多策略并行验证运行器
├── cvc5_parser.py                # CVC5 输出解析器
├── vampire_runner.py             # Vampire 验证运行器
├── run_exp_folder.py             # 批量实验运行器（多进程并行，支持超时控制）
├── run_exp_folder_vampire.py     # 批量实验运行器（Vampire版本）
├── run_all_benchmark.sh          # 全量基准测试入口脚本（CVC5/CVC4）
├── run_all_benchmark_vampire.sh  # 全量基准测试入口脚本（Vampire）
├── main.py                       # 单任务运行入口
├── preprocessed.py               # SMT2 预处理：解析、重构、模板生成
├── kill_cvc_processes.sh         # 清理残留 CVC4/CVC5 进程
├── kill_vampire_processes.sh     # 清理残留 Vampire 进程
├── benchmarks/
│   ├── smtlib2/                  # 原始 SMT-LIB2 基准测试集
│   │   ├── autoproof/
│   │   ├── dtt/
│   │   ├── ind-ben/
│   │   ├── int/
│   │   └── vmcai15-dt/
│   └── preprocessed/             # 预处理后的基准测试集
│       ├── all-int/
│       ├── autoproof/
│       ├── dtt/
│       ├── ind-ben/
│       └── vmcai15-dt/
├── cvc/
│   ├── cvc5-Linux-x86_64-static/
│   │   └── bin/cvc5              # CVC5 求解器可执行文件
│   └── cvc4_binary/
│       └── cvc4-1.6-x86_64-linux-opt  # CVC4 求解器可执行文件
└── vampire/
    └── vampire                   # Vampire 求解器可执行文件
```

## Usage

### 1. Environment Setup

安装 Python 依赖：

```bash
pip install langchain_openai python-dotenv colorlog psutil tqdm
```

### 2. Configuration

复制模板文件并填入自己的 API 密钥和路径：

```bash
cp .env_template .env
# 编辑 .env，将 sk-xxxxxxx 替换为实际的 API 密钥
```

`.env_template` 中包含了所有可配置项及说明，请参照修改。

### 3. Preprocessing

用 `preprocessed.py` 对原始 SMT2 基准测试进行预处理：

```bash
python3 preprocessed.py
```

预处理后的文件存放在 `benchmarks/preprocessed/` 目录下（现有benchmarks已经处理好了）。

### 4. Running

**批量运行（推荐）：**

通过 `run_all_benchmark.sh` 一键运行所有基准测试集（可以直接在这个脚本里面修改要运行的benchmarks目录，不需要用下面那个run_exp_folder.py）：

```bash
bash run_all_benchmark.sh
```

脚本内可修改要运行的数据集列表和日志目录。

**运行指定数据集：**

```bash
python3 run_exp_folder.py --root-path ./benchmarks/preprocessed/autoproof
```

支持的命令行参数：

| 参数 | 说明 |
|------|------|
| `--root-path` | 预处理后的数据集路径 |
| `--baseline` | 启用 baseline 模式（仅运行求解器初始验证，不使用 LLM） |
| `--strategy-mode` | 提示词策略：`default`（默认）/ `zero_shot` / `naive` |

**运行单个任务：**

```bash
python3 main.py <base_path> <base_name>
```

### 5. Results

运行结果自动保存至 `result_csv/` 目录，文件名格式为 `results_<timestamp>_<dataset>_<mode>.csv`。

实验运行时会将数据集复制到 `result_files/` 目录下避免污染原始文件。

## Supported Models (不局限下面，自己配置API就行，注意在env_config修改定义配置)

| MODEL_TYPE | Model | Provider |
|------------|-------|----------|
| `gpt-4o` (default) | GPT-5 | OpenRouter |
| `deepseek` | DeepSeek-Chat | DeepSeek API |
| `qwen` | Qwen3-235B | OpenRouter |
| `gemini` | Gemini 2.5 Flash | OpenRouter |

## Supported Solvers

- **CVC5** — 支持多策略并行验证（simple / inductive / inductive-no-ematching）
- **CVC4** — 归纳推理配置
- **Vampire** — 一阶逻辑定理证明器

## Publication

**Can LLM Aid in Solving Constraints with Inductive Definitions?**

Solving constraints involving inductive (aka recursive) definitions is challenging. State-of-the-art SMT/CHC solvers and first-order logic provers provide only limited support for solving such constraints, especially when they involve, e.g., abstract data types. In this work, we leverage structured prompts to elicit Large Language Models (LLMs) to generate auxiliary lemmas that are necessary for reasoning about these inductive definitions. We further propose a neuro-symbolic approach, which synergistically integrates LLMs with constraint solvers: the LLM iteratively generates conjectures, while the solver checks their validity and usefulness for proving the goal. We evaluate our approach on a diverse benchmark suite comprising constraints originating from algebraic data types and recurrence relations. The experimental results show that our approach can improve the state-of-the-art SMT and CHC solvers, solving considerably more (around 25%) proof tasks involving inductive definitions, demonstrating its efficacy.

**Full version paper:** [https://doi.org/10.48550/arXiv.2603.03668](https://doi.org/10.48550/arXiv.2603.03668)
