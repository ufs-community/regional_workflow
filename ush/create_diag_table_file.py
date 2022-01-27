#!/usr/bin/env python3

import unittest
from textwrap import dedent

from python_utils.process_args import process_args
from python_utils.environment import import_vars,set_env_var
from python_utils.print_input_args import print_input_args
from python_utils.define_macro_utilities import define_macro_utilities

def create_diag_table_file(**kwargs):
    """ Creates a diagnostic table file for each cycle to be run

    Args:
        run_dir: run directory
    Returns:
        None
    """

    #process input arguments
    valid_args = [ "run_dir" ]
    dictionary = process_args(valid_args, **kwargs)
    print_input_args(dictionary)
    import_vars(dictionary=dictionary)

    #import needed environment variables
    IMPORTS = [ 'VERBOSE', 'DIAG_TABLE_FN', 'DIAG_TABLE_FN', 'DIAG_TABLE_TMPL_F',
                'CDATE', 'CRES', 'USHDIR']
    import_vars(env_vars=IMPORTS)
    
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
        
            diag_table_fp = \"{diag_table_fp}\"''', verboes=VERBOSE)

    settings = dedent(f'''
            starttime: !datetime {CDATE}
            cres: {CRES}''')

    #call fill jinja
    (err,_,_) = run_command( f'{USHDIR}/fill_jinja_template.py -q -u "{settings}" -t "{DIAG_TABLE_TMPL_FP}" -o "{diag_table_fp}')

    if err != 0:
        print_err_msg_exit(f'''
            !!!!!!!!!!!!!!!!!
            
            fill_jinja_template.py failed!
            
            !!!!!!!!!!!!!!!!!''')

class Testing(unittest.TestCase):
    def test_create_diag_table_file(self):
        self.assertTrue(False)
    def setUp(self):
        define_macro_utilities();
        set_env_var('DEBUG','FALSE')

