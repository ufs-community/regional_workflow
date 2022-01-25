#!/usr/bin/env python3

import os

from python_utils.process_args import process_args
from python_utils.print_input_args import print_input_args
from python_utils.print_msg import print_err_msg_exit
from python_utils.check_var_valid_value import check_var_valid_value
from python_utils.filesys_cmds_vrfy import ln_vrfy

def create_symlink_to_file(**kwargs):
    """ Create a symbolic link to the specified target file.

    Args:
        **kwargs: key-value pairs
    Returns:
        None
    """

    valid_args = ["target", "symlink", "relative"]
    arg_values = process_args(valid_args, **kwargs)

    print_input_args(arg_values)

    if arg_values["target"] == None:
        print_err_msg_exit(f'''
The argument \"target\" specifying the target of the symbolic link that
this function will create was not specified in the call to this function:
  target = \"{target}\"''')

    if arg_values["symlink"] == None:
        print_err_msg_exit(f'''
The argument \"symlink\" specifying the target of the symbolic link that
this function will create was not specified in the call to this function:
  target = \"{symlink}\"''')

    if arg_values["relative"] == None:
        arg_values["relative"] = "TRUE"

    valid_vals_relative = ["TRUE", "true", "YES", "yes", "FALSE", "false", "NO", "no"]
    check_var_valid_value(arg_values["relative"], valid_vals_relative)

    if not os.path.exists(arg_values["target"]):
        print_err_msg_exit(f'''
Cannot create symlink to specified target file because the latter does
not exist or is not a file:
    target = \"{target}\"''')
    
    relative_flag=""
    if arg_values["relative"] in valid_vals_relative[:4]:
        RELATIVE_LINK_FLAG = os.getenv('RELATIVE_LINK_FLAG')
        if RELATIVE_LINK_FLAG != None:
            relative_flag=f'{RELATIVE_LINK_FLAG}'

    ln_vrfy(f'-sf {relative_flag} {arg_values["target"]} {arg_values["symlink"]}')

