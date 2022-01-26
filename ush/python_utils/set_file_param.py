#!/usr/bin/env python3

import os
from python_utils.print_msg import print_info_msg, print_err_msg_exit
from python_utils.change_case import lowercase
from python_utils.run_command import run_command
from python_utils.environment import import_vars

def set_file_param(file_full_path, param, value):
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

    # import environment variables we need
    IMPORTS = [ 'SED', 'WFLOW_XML_FN', 'RGNL_GRID_NML_FN', 'FV3_NML_FN',
                'DIAG_TABLE_FN', 'MODEL_CONFIG_FN', 'GLOBAL_VAR_DEFNS_FN' ]
    import_vars(dictionary=os.environ, env_vars=IMPORTS)

    # set param value based on what type of file it is
    if file_ == WFLOW_XML_FN:
        regex_search = f'(^\s*<!ENTITY\s+{param}\s*\")(.*)(\">.*)'
        regex_replace = f'\\1{value}\\3'
    elif file_ == RGNL_GRID_NML_FN:
        regex_search = f"^(\s*{param}\s*=)(.*)"
        regex_replace = f"\\1 {value}"
    elif file_ == FV3_NML_FN:
        regex_search = f"(.*)(<{param}>)(.*)"
        regex_replace = f"\\1{value}\\3"
    elif file_ == DIAG_TABLE_FN:
        regex_search = f"(.*)(<{param}>)(.*)"
        regex_replace = f"\\1{value}\\3"
    elif file_ == MODEL_CONFIG_FN:
        regex_search = f"^(\s*{param}:\s*)(.*)"
        regex_replace = f"\\1{value}"
    elif file_ == GLOBAL_VAR_DEFNS_FN:
        regex_search = f'(^\s*{param}=)(\".*\")?([^ \"]*)?(\(.*\))?(\s*[#].*)?'
        regex_replace = f"\\1{value}\\5"
    else:
        print_err_msg_exit(f'''
The regular expressions for performing search and replace have not been 
specified for this file:
  file = \"{file_}\"''')

    #use grep to determine if pattern exists
    (err,_,_) = run_command(f"grep -q -E '{regex_search}' '{file_full_path}'")

    if err == 0:
        run_command(f"{SED} -i -r -e 's%{regex_search}%{regex_replace}%' '{file_full_path}'")
    else:
        print_err_msg_exit(f'''
Specified file (file_full_path) does not contain the searched-for regu-
lar expression (regex_search):
  file_full_path = \"{file_full_path}\"
  param = \"{param}\"
  value = \"{value}\"
  regex_search = {regex_search}''')

