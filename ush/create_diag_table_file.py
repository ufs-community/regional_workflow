#!/usr/bin/env python3

import os
import unittest
from textwrap import dedent

from python_utils import process_args, import_vars, set_env_var, print_input_args, \
                         print_info_msg, print_err_msg_exit, cfg_to_yaml_str

from fill_jinja_template import fill_jinja_template

def create_diag_table_file(**kwargs):
    """ Creates a diagnostic table file for each cycle to be run

    Args:
        run_dir: run directory
    Returns:
        Boolean
    """

    #process input arguments
    valid_args = [ "run_dir" ]
    dictionary = process_args(valid_args, **kwargs)
    print_input_args(dictionary)
    import_vars(dictionary=dictionary)

    #import all environment variables
    import_vars()
    
    #create a diagnostic table file within the specified run directory
    print_info_msg(f'''
        Creating a diagnostics table file (\"{DIAG_TABLE_FN}\") in the specified
        run directory...
        
          run_dir = \"{run_dir}\"''', verbose=VERBOSE)

    diag_table_fp = f'{run_dir}/{DIAG_TABLE_FN}'

    print_info_msg(f'''
        
        Using the template diagnostics table file:
        
            diag_table_tmpl_fp = {DIAG_TABLE_TMPL_FP}
        
        to create:
        
            diag_table_fp = \"{diag_table_fp}\"''', verbose=VERBOSE)

    settings = {
       'starttime': CDATE,
       'cres': CRES
    }
    settings_str = cfg_to_yaml_str(settings)

    #call fill jinja
    try:
        fill_jinja_template(["-q", "-u", settings_str, "-t", DIAG_TABLE_TMPL_FP, "-o", diag_table_fp])
    except:
        print_err_msg_exit(f'''
            !!!!!!!!!!!!!!!!!
            
            fill_jinja_template.py failed!
            
            !!!!!!!!!!!!!!!!!''')
        return False
    return True

class Testing(unittest.TestCase):
    def test_create_diag_table_file(self):
        self.assertTrue(\
                create_diag_table_file( \
                      run_dir=f"{os.getenv('USHDIR')}/test_data"))
    def setUp(self):
        USHDIR = os.path.dirname(os.path.abspath(__file__))
        DIAG_TABLE_FN="diag_table"
        DIAG_TABLE_TMPL_FP = f'{USHDIR}/templates/{DIAG_TABLE_FN}.FV3_GFS_v15p2'
        set_env_var('DEBUG',True)
        set_env_var('VERBOSE',True)
        set_env_var("USHDIR",USHDIR)
        set_env_var("DIAG_TABLE_FN",DIAG_TABLE_FN)
        set_env_var("DIAG_TABLE_TMPL_FP",DIAG_TABLE_TMPL_FP)
        set_env_var("CRES","C48")
        set_env_var("CDATE","2021010106")

