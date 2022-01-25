#!/usr/bin/env python3

import os
from python_utils.print_msg import print_err_msg_exit
from python_utils.run_command import run_command

def get_manage_externals_config_property(externals_cfg_fp, external_name, property_name):
    """
    This function searches a specified manage_externals configuration file
    and extracts from it the value of the specified property of the external
    with the specified name (e.g. the relative path in which the external
    has been/will be cloned by the manage_externals utility).
    
    Args:
    
      externals_cfg_fp:
         The absolute or relative path to the manage_externals configuration
         file that will be searched.
    
      external_name:
         The name of the external to search for in the manage_externals confi-
         guration file specified by externals_cfg_fp.
    
      property_name:
         The name of the property whose value to obtain (for the external spe-
         cified by external_name).
    
    Returns:
        The property value
    """

    if not os.path.exists(externals_cfg_fp):
        print_err_msg_exit(f'''
The specified manage_externals configuration file (externals_cfg_fp) 
does not exist:
  externals_cfg_fp = \"{externals_cfg_fp}\"''')
    
    SED=os.getenv('SED')

    regex_search=f'^[ ]*({property_name})[ ]*=[ ]*([^ ]*).*'
    cmd = f'{SED} -r -n \
                -e "/^[ ]*\[{external_name}\]/!b" \
                -e ":SearchForLine" \
                -e "s/({regex_search})/\\1/;t FoundLine" \
                -e "n;bSearchForLine" \
                -e ":FoundLine" \
                -e "p;q" \
                "{externals_cfg_fp}" '

    (ret,line,_) = run_command(cmd)

    if line == None:
        print_err_msg_exit(f'''
In the specified manage_externals configuration file (externals_cfg_fp), 
the specified property (property_name) was not found for the the speci-
fied external (external_name): 
  externals_cfg_fp = \"{externals_cfg_fp}\"
  external_name = \"{external_name}\"
  property_name = \"{property_name}\"''')
    else:
        line = line[:-1]
        cmd = f'printf "%s" "{line}" | {SED} -r -n -e "s/{regex_search}/\\2/p"'
        (_,property_value,_) = run_command(cmd)
        return property_value

    return None

