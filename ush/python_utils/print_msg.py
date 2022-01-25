#!/usr/bin/env python3

import traceback
import sys

def print_err_msg_exit(error_msg="",stack_trace=True):
    """Function to print out an error message to stderr and exit.
    It also prints the stack trace.

    Args:
        error_msg : error message to print
    Returns:
        None
    """
    if stack_trace:
        traceback.print_stack(file=sys.stderr)

    msg_footer='\nExiting with nonzero status.'
    print(error_msg + msg_footer, file=sys.stderr)
    sys.exit(1)

def print_info_msg(info_msg,verbose=True):
    """ Function to print information message to stdout when verbose is set.

    Args:
        info_msg : Message to print
        verbose : set to False to silence printing
    Returns:
        True: if message is successfully printed
    """
  
    if verbose == True or verbose == 'TRUE':
        print(info_msg) 
        return True
    return False

