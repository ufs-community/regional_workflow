#!/usr/bin/env python3

import os
from python_utils.print_msg import print_info_msg, print_err_msg_exit
from python_utils.change_case import lowercase
from python_utils.run_command import run_command

def set_bash_param(file_full_path, param, value):
    """ Function to replace placeholder values of variables in
        several different types of files with actual values

    Args:
        
        file_full_path:
            Full path to the file in which the specified parameter's value will be set.

        param: 
            Name of the parameter whose value will be set.

        value:
            Value to set the parameter to.
    """

    # get verbosity from environment
    DEBUG = os.getenv('DEBUG') 
    if DEBUG != None and lowercase(DEBUG) == 'false':
        DEBUG = False
    else:
        DEBUG = True

    # print info message
    file_ = os.path.basename(file_full_path)
    print_info_msg(f'Setting parameter \"{param}\" in file \"{file_}\" to \"{value}\" ...',
        verbose=DEBUG)

    # set param value
    regex_search = f"(^\s*{param}=)(\".*\")?([^ \"]*)?(\(.*\))?(\s*[#].*)?"
    regex_replace = f"\\1\"{value}\"\\5"

    #use grep to determine if pattern exists
    (err,_,_) = run_command(f"grep -q -E '{regex_search}' '{file_full_path}'")

    if err == 0:
        SED = os.getenv('SED')
        run_command(f"{SED} -i -r -e 's%{regex_search}%{regex_replace}%' '{file_full_path}'")
    else:
        print_err_msg_exit(f'''
Specified file (file_full_path) does not contain the searched-for regu-
lar expression (regex_search):
  file_full_path = \"{file_full_path}\"
  param = \"{param}\"
  value = \"{value}\"
  regex_search = {regex_search}''')

