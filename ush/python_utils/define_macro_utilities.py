#!/usr/bin/env python3

import os

from python_utils.print_msg import print_err_msg_exit
from python_utils.run_command import run_command

def set_env_var(param,value,darwin=False):
    """ Set an environement variable

    Args:
        param: the variable to set
        value: its value
        darwin: set to True to test presence of command
    Returns:
        None
    """

    if darwin == True:
        (err,_,_) = run_command(f'command -v {value}')
        if err != 0:
            print_err_msg_exit(f'''    
For Darwin-based operating systems (MacOS), the '{value}' utility is required to run the UFS SRW Application.
Reference the User's Guide for more information about platform requirements.
Aborting.''')

    os.environ[param] = value

def define_macro_utilities():
    """ set some environment variables for Darwin systems  
    
    The macros include: READLINK, SED, DATE_UTIL and LN_UTIL
    """
    if os.uname()[0] == 'Darwin':
        set_env_var('READLINK','greadlink',True)
        set_env_var('SED','gsed',True)
        set_env_var('DATE_UTIL','gdate',True)
        set_env_var('LN_UTIL','gln',True)
    else:
        set_env_var('READLINK','readlink')
        set_env_var('SED','sed')
        set_env_var('DATE_UTIL','date')
        set_env_var('LN_UTIL','ln')

