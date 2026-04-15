import logging
import colorlog

def setup_colored_logger():
    """Configure a colored logger"""
    # Configure colored logging
    color_formatter = colorlog.ColoredFormatter(
        '%(log_color)s%(asctime)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S',
        log_colors={
            'DEBUG': 'cyan',
            'INFO': 'green',
            'WARNING': 'yellow',
            'ERROR': 'red',
            'CRITICAL': 'red,bg_white',
        }
    )

    # Create and configure the log handler
    handler = colorlog.StreamHandler()
    handler.setFormatter(color_formatter)
    logger = colorlog.getLogger()
    logger.addHandler(handler)
    # Silence non-critical logs; keep CRITICAL
    logger.setLevel(logging.INFO)
    # logger.setLevel(logging.DEBUG) # switch to DEBUG level if you need to see network-send info

    # Clear the default handlers to avoid duplicate output
    logger.handlers = [handler]
    
    return logger