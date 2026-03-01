# ProofMate (LLM4SMT)

使用LLMs辅助带归纳的SMT文件的求解。

## 使用说明

### 预处理
- 请先使用preprocess.py处理原始的Benchmark
    - preprocessed/ 目录下是处理好的
- 将处理好的准备运行的benchmark放到运行目录

### 运行
- 处理后即可使用Mate.py进行实际的测试
- 具体过程，假如 int-ben-llm/0911-10mins-llm-vmcai15dt 为运行目录

```bash
mkdir int-ben-llm/0911-10mins-llm-vmcai15dt
cp -r preprocessed/vmcai15-dt int-ben-llm/0911-10mins-llm-vmcai15dt

# run one case
python3 Mate_parallel_prompt-adt-ind-0907-0.90.9-10mins.py int-ben-llm/0911-10mins-llm-vmcai15dt/vmcai15-dt/clam/nosg/goal1 template

# run dir
bash exe-0911-llm-0.9-0.9-10mins-for-example.sh

# resutls
python3 result-llm.py
```


### 本地参数环境配置
环境配置：
```bash
    ## 安装 langchain
    pip install langchain_openai python-dotenv 
    ## 安装彩色日志
    pip install colorlog
```
请在本地新建.env文件
```config
OPENAI_API_KEY=sk-xxx
DEEPSEEK_API_KEY=sk-xxx
# 不配置则默认使用GPT-4o
MODEL_TYPE=deepseek
```

## 文件说明
- Mate.py 主程序文件
- result-llm.py 分析指定文件夹下的日志文件并生成Excel格式的报告
- preprocessed.py SMT2文件预处理，解析重构、模版生成、批量处理