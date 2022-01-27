#!/usr/bin/env python3

import os
import unittest

from python_utils.process_args import process_args
from python_utils.environment import import_vars,set_env_var
from python_utils.print_input_args import print_input_args
from python_utils.run_command import run_command
from python_utils.print_msg import print_err_msg_exit
from python_utils.define_macro_utilities import define_macro_utilities

def check_ruc_lsm(**kwargs):
    """ This file defines a function that checks whether the RUC land surface
    model (LSM) parameterization is being called by the selected physics suite.

    Args:
        ccpp_phys_suite_fp: full path to CCPP physics suite xml file
    Returns:
        Boolean
    """

    valid_args = ['ccpp_phys_suite_fp']
    dictionary = process_args(valid_args, **kwargs)
    print_input_args(dictionary)
    import_vars(dictionary=dictionary)

    ruc_lsm_name = "lsm_ruc"     
    regex_search = f'^[ ]*<scheme>({ruc_lsm_name})<\/scheme>[ ]*$'

    SED=os.environ['SED']
    (_,ruc_lsm_name_or_null,_) = \
        run_command( f'{SED} -r -n -e "s/{regex_search}/\\1/p" "{ccpp_phys_suite_fp}"' )

    if ruc_lsm_name_or_null == None:
        return False
    elif ruc_lsm_name_or_null == ruc_lsm_name:
        return True
    else:
        print_err_msg_exit(f'''
            Unexpected value returned for ruc_lsm_name_or_null:
              ruc_lsm_name_or_null = \"{ruc_lsm_name_or_null}\"
            This variable should be set to either \"{ruc_lsm_name}\" or an empty
            string.''')

class Testing(unittest.TestCase):
    def test_check_ruc_lsm(self):
        self.assertTrue( check_ruc_lsm(ccpp_phys_suite_fp="test_data/suite_FV3_GSD_SAR.xml") )
    def setUp(self):
        define_macro_utilities();
        set_env_var('DEBUG','FALSE')

