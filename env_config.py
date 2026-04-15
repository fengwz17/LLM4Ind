import os
import logging
from dotenv import load_dotenv
from langchain_openai import ChatOpenAI

def setup_environment():
    """Environment variable and proxy configuration"""
    # Load the .env file
    load_dotenv()
    
    # Load all required environment variables in one place
    openai_api_key = os.getenv('OPENAI_API_KEY')
    deepseek_api_key = os.getenv('DEEPSEEK_API_KEY')
    qwen_api_key = os.getenv('QWEN_API_KEY')
    gemini_api_key = os.getenv('GEMINI_API_KEY')
    http_proxy = os.getenv('HTTP_PROXY')
    https_proxy = os.getenv('HTTPS_PROXY')
    model_type = os.getenv('MODEL_TYPE', 'gpt-4o')  # defaults to gpt-4o
    cvc5_binary = os.getenv('CVC5_BINARY', './cvc/cvc5-Linux-x86_64-static/bin/cvc5')  # path to the CVC5 binary
    cvc4_binary = os.getenv('CVC4_BINARY', './cvc/cvc4_binary/cvc4-1.6-x86_64-linux-opt')  # path to the CVC4 binary
    vampire_binary = os.getenv('VAMPIRE_BINARY', './vampire/vampire')  # path to the Vampire binary
    max_attempts_per_prompt = int(os.getenv('MAX_ATTEMPTS_PER_PROMPT', '3'))  # maximum number of attempts per prompt strategy
    default_cvc_timeout = int(os.getenv('DEFAULT_CVC_TIMEOUT', '60'))  # default CVC5 timeout (initial verification check)
    retry_cvc_timeout = int(os.getenv('RETRY_CVC_TIMEOUT', '100'))  # retry CVC5 timeout (extended timeout when re-verifying the original goal)
    combined_cvc_timeout = int(os.getenv('COMBINED_CVC_TIMEOUT', '60'))  # CVC5 timeout with lemmas
    max_recursion_depth = int(os.getenv('MAX_RECURSION_DEPTH', '3'))  # maximum recursion depth
    task_timeout = int(os.getenv('TASK_TIMEOUT', '1200'))  # timeout for a single task (seconds)
    max_parallel_tasks = int(os.getenv('MAX_PARALLEL_TASKS', '20'))  # maximum number of parallel tasks

    # Proxy configuration
    if http_proxy and https_proxy:
        os.environ['http_proxy'] = http_proxy
        os.environ['https_proxy'] = https_proxy
        logging.info("Proxy enabled: %s", http_proxy)
    else:
        logging.info("No proxy configuration found; skipping proxy setup.")
    # logging.info("Skipping proxy setup.")

    # Check that the required API keys are present
    if not openai_api_key:
        raise ValueError("OPENAI_API_KEY is not set in .env file.")
    if model_type == 'deepseek' and not deepseek_api_key:
        raise ValueError("DEEPSEEK_API_KEY is not set in .env file for DeepSeek model.")
    if model_type == 'qwen' and not qwen_api_key:
        raise ValueError("QWEN_API_KEY is not set in .env file for Qwen model.")
    if model_type == 'gemini' and not gemini_api_key:
        raise ValueError("GEMINI_API_KEY is not set in .env file for Gemini model.")
    
    return {
        'OPENAI_API_KEY': openai_api_key,
        'DEEPSEEK_API_KEY': deepseek_api_key,
        'QWEN_API_KEY': qwen_api_key,
        'GEMINI_API_KEY': gemini_api_key,
        'MODEL_TYPE': model_type,
        'CVC5_BINARY': cvc5_binary,
        'CVC4_BINARY': cvc4_binary,
        'VAMPIRE_BINARY': vampire_binary,
        'MAX_ATTEMPTS_PER_PROMPT': max_attempts_per_prompt,
        'DEFAULT_CVC_TIMEOUT': default_cvc_timeout,
        'RETRY_CVC_TIMEOUT': retry_cvc_timeout,
        'COMBINED_CVC_TIMEOUT': combined_cvc_timeout,
        'MAX_RECURSION_DEPTH': max_recursion_depth,
        'TASK_TIMEOUT': task_timeout,
        'MAX_PARALLEL_TASKS': max_parallel_tasks
    }

def setup_model(config):
    """Initialize the model based on the configuration"""
    if config['MODEL_TYPE'] == 'deepseek':
        llm = ChatOpenAI(
            model='deepseek-chat',
            openai_api_key=config['DEEPSEEK_API_KEY'],
            openai_api_base='https://api.deepseek.com',
            temperature=0.9,  # set temperature to 0.9 to increase diversity
            top_p=0.9  # set top_p to 0.9 to increase creativity
            # max_tokens=1024
        )
        logging.info("Using the DeepSeek-chat model for inference")
    elif config['MODEL_TYPE'] == 'qwen':
        llm = ChatOpenAI(
            model='qwen/qwen3-235b-a22b-2507',
            openai_api_key=config['QWEN_API_KEY'],
            openai_api_base='https://openrouter.ai/api/v1',
            temperature=0.9,  # set temperature to 0.9 to increase diversity
            top_p=0.9  # set top_p to 0.9 to increase creativity
        )
        logging.info("Using the Qwen model for inference")
    elif config['MODEL_TYPE'] == 'gemini':
        llm = ChatOpenAI(
            model='google/gemini-2.5-flash',
            openai_api_key=config['GEMINI_API_KEY'],
            openai_api_base='https://openrouter.ai/api/v1',
            temperature=0.9,  # set temperature to 0.9 to increase diversity
            top_p=0.9  # set top_p to 0.9 to increase creativity
        )
        logging.info("Using the Gemini model for inference")
    else:
        llm = ChatOpenAI(
            model='openai/gpt-5', # 'openai/gpt-4o-2024-11-20',
            openai_api_key=config['OPENAI_API_KEY'],
            openai_api_base='https://openrouter.ai/api/v1',
            temperature=0.9,  # set temperature to 0.9 to increase diversity
            top_p=0.9  # set top_p to 0.9 to increase creativity
            # temperature=0.7
        )
        logging.info("Using the GPT-5 model for inference.")
    
    return llm