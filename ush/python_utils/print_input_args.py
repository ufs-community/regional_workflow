#!/usr/bin/env python3

import os
from python_utils.change_case import lowercase
from python_utils.print_msg import print_info_msg

def print_input_args(valid_args):
    """ Print out arguments for debugging purposes

    Args:
        valid_args: dictionary of key-value pairs
    Returns:
        Number of printed arguments
    """

    # get verbosity from environment
    DEBUG = os.getenv('DEBUG') 
    if DEBUG != None and lowercase(DEBUG) == 'false':
        DEBUG = False
    else:
        DEBUG = True
    
    if list(valid_args.keys())[0] == '__unset__':
        valid_arg_names = {}
    else:
        valid_arg_names = valid_args 
    num_valid_args = len(valid_arg_names)

    if num_valid_args == 0:
        msg = f'''No arguments have been passed to script/function.\n'''
    else:
        msg = f'''The arguments to script/function are set as follows:\n\n'''
        for k,v in valid_arg_names.items():
            msg = msg + f'{k}="{v}"\n'

    print_info_msg(msg,verbose=DEBUG)
    return num_valid_args

