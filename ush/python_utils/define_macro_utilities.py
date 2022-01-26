#!/usr/bin/env python3

import os

from python_utils.print_msg import print_err_msg_exit
from python_utils.run_command import run_command
from python_utils.environment import set_env_var

def check_darwin(cmd):
    """ Check if darwin command exists """
    (err,_,_) = run_command(f'command -v {cmd}')
    if err != 0:
        print_err_msg_exit(f'''    
For Darwin-based operating systems (MacOS), the '{value}' utility is required to run the UFS SRW Application.
Reference the User's Guide for more information about platform requirements.
Aborting.''')
    return True

def define_macro_utilities():

    """ set some environment variables for Darwin systems  
    
    The macros include: READLINK, SED, DATE_UTIL and LN_UTIL
    """
    if os.uname()[0] == 'Darwin':
        if check_darwin('greadlink'):
            set_env_var('READLINK','greadlink')
        if check_darwin('gsed'):
            set_env_var('SED','gsed')
        if check_darwin('gdate'):
            set_env_var('DATE_UTIL','gdate')
        if check_darwin('gln'):
            set_env_var('LN_UTIL','gln')
    else:
        set_env_var('READLINK','readlink')
        set_env_var('SED','sed')
        set_env_var('DATE_UTIL','date')
        set_env_var('LN_UTIL','ln')

