#!/usr/bin/env python3

import unittest
import glob
import os

from python_utils import *

class Testing(unittest.TestCase):
    def test_change_case(self):
        self.assertEqual( uppercase('upper'), 'UPPER' )
        self.assertEqual( lowercase('LOWER'), 'lower' )
    def test_check_for_preexist_dir_file(self):
        cmd_vrfy('mkdir -p dir')
        self.assertTrue( os.path.exists('dir') )
        check_for_preexist_dir_file('dir-1', 'rename')
        dirs = glob.glob('dir*')
        self.assertEqual( len(dirs), 1)
        rm_vrfy('-rf dir*')
    def test_check_var_valid_value(self):
        self.assertTrue( check_var_valid_value('rice', [ 'egg', 'spam', 'rice' ]) )
    def test_count_files(self):
        cnt = count_files('py')
        self.assertGreater(cnt, 1)
    def test_filesys_cmds(self):
        dPATH=f'{self.PATH}/test_data/dir'
        mkdir_vrfy(dPATH)
        self.assertTrue( os.path.exists(dPATH) )
        cp_vrfy(f'{self.PATH}/change_case.py {dPATH}/change_cases.py')
        self.assertTrue( os.path.exists(f'{dPATH}/change_cases.py') )
        cmd_vrfy(f'rm -rf {dPATH}')
        self.assertFalse( os.path.exists('tt.py') )
    def test_get_charvar_from_netcdf(self):
        FILE=f'{self.PATH}/test_data/sample.nc'
        val = get_charvar_from_netcdf(FILE, 'pressure')
        self.assertTrue( val and (val.split()[0], '955.5,'))
    def test_is_array(self):
        arr = [ 2, 'egg', 5 ]
        self.assertTrue( is_array(arr) )
    def test_run_command(self):
        self.assertEqual( run_command('echo hello'), (0, 'hello', '') )
    def test_is_element_of(self):
        arr = [ 2, 'egg', 5 ]
        self.assertTrue( is_element_of('egg', arr) )
    def test_get_elem_inds(self):
        arr = [ 'egg', 'spam', 'egg', 'rice', 'egg']
        self.assertEqual( get_elem_inds(arr, 'egg', 'first' ) , 0 )
        self.assertEqual( get_elem_inds(arr, 'egg', 'last' ) , 4 )
        self.assertEqual( get_elem_inds(arr, 'egg', 'all' ) , [0, 2, 4] )
    def test_get_manage_externals_config_property(self):
        self.assertIn( \
            'regional_workflow',
            get_manage_externals_config_property( \
                f'{self.PATH}/../../../Externals.cfg',
                'regional_workflow',
                'repo_url'))
    def test_interpol_to_arbit_CRES(self):
        RES = 50
        RES_array = [ 5, 25, 40, 60, 80, 100 ]
        prop_array = [ 0.1, 0.2, 0.3, 0.4, 0.5, 0.6]
        prop = interpol_to_arbit_CRES(RES, RES_array, prop_array)
        self.assertAlmostEqual(prop, 0.35)
    def test_set_bash_param(self):
        FILE = f'{self.PATH}/test_data/var_defns.sh'
        set_bash_param(FILE, 'RUN_ENVIR', 'none')        
        (_,out,_) = run_command(f'grep RUN_ENVIR {FILE}')
        self.assertEqual( out, 'RUN_ENVIR="none"')
        set_bash_param(FILE, 'RUN_ENVIR', 'nco')        
        (_,out,_) = run_command(f'grep RUN_ENVIR {FILE}')
        self.assertEqual( out, 'RUN_ENVIR="nco"')
    def test_set_file_param(self):
        FILE = f'{self.PATH}/test_data/regional_grid.nml'
        cp_vrfy(f'{FILE}.org {FILE}')
        set_env_var("WFLOW_XML_FN",None)
        set_env_var("RGNL_GRID_NML_FN",None)
        set_env_var("FV3_NML_FN","regional_grid.nml")
        set_file_param(FILE, 'delx', '20')        
        ## Test more of this if they are used ##
    def test_create_symlink_to_file(self):
        TARGET = f'{self.PATH}/test_python_utils.py'
        SYMLINK = f'{self.PATH}/test_data/test_python_utils.py'
        create_symlink_to_file(TARGET,SYMLINK)
    def test_define_macro_utilities(self):
        set_env_var('MYVAR','MYVAL')
        val = os.getenv('MYVAR')
        self.assertEqual(val,'MYVAL')
        self.assertEqual(os.getenv('SED'),
            'gsed' if os.uname() == 'Darwin' else 'sed')
    def test_process_args(self):
        valid_args = [ "arg1", "arg2", "arg3", "arg4" ]
        values = process_args( valid_args,
                arg2 = "bye", arg3 = "hello",
                arg4 = ["this", "is", "an", "array"] )
        self.assertEqual(values,
            {'arg1': None,
             'arg2': 'bye',
             'arg3': 'hello',
             'arg4': ['this', 'is', 'an', 'array']} )
    def test_print_input_args(self):
        valid_args = { "arg1":1, "arg2":2, "arg3":3, "arg4":4 }
        self.assertEqual( print_input_args(valid_args), 4 )
    def test_import_vars(self):
        #test import
        global MYVAR
        set_env_var("MYVAR","MYVAL")
        env_vars = ["PWD", "MYVAR"]
        import_vars(env_vars=env_vars)
        self.assertEqual( PWD, os.getcwd() )
        self.assertEqual(MYVAR,"MYVAL")
        #test export
        MYVAR="MYNEWVAL"
        self.assertEqual(os.environ['MYVAR'],'MYVAL')
        export_vars(env_vars=env_vars)
        self.assertEqual(os.environ['MYVAR'],'MYNEWVAL')
        #test custom dictionary
        dictionary = { "Hello": "World!" }
        import_vars(dictionary=dictionary)
        self.assertEqual( Hello, "World!" )
    def test_config_parser(self):
        cfg = { "HRS": [ "1", "2" ] }
        shell_str = cfg_to_shell_str(cfg)
        self.assertEqual( shell_str, 'HRS=( "1" "2" )\n')
    def test_print_msg(self):
        self.assertEqual( print_info_msg("Hello World!", verbose=False), False)
    def setUp(self):
        define_macro_utilities();
        set_env_var('DEBUG','FALSE')
        self.PATH = os.path.dirname(__file__)
        
if __name__ == '__main__':
    unittest.main()

