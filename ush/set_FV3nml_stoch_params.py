#!/usr/bin/env python3

import unittest
import os
from textwrap import dedent

from python_utils import process_args, print_input_args, print_info_msg, print_err_msg_exit,\
                         check_var_valid_value, run_command, mv_vrfy,mkdir_vrfy,cmd_vrfy,cp_vrfy,\
                         rm_vrfy,import_vars,set_env_var,list_to_str,str_to_list,\
                         lowercase, define_macos_utilities

def set_FV3nml_stoch_params(**kwargs):
    """
    This function, for an ensemble-enabled experiment 
    (i.e. for an experiment for which the workflow configuration variable 
    DO_ENSEMBLE has been set to "TRUE"), creates new namelist files with
    unique stochastic "seed" parameters, using a base namelist file in the 
    ${EXPTDIR} directory as a template. These new namelist files are stored 
    within each member directory housed within each cycle directory. Files 
    of any two ensemble members differ only in their stochastic "seed" 
    parameter values.  These namelist files are generated when this file is
    called as part of the RUN_FCST_TN task.  

    Args:
        cdate
    Returns:
        None
    """

    valid_args = ['cdate']
    dictionary = process_args(valid_args, **kwargs)
    print_input_args(dictionary)
    import_vars(dictionary=dictionary)

    # import all environment variables
    import_vars()

    #
    #-----------------------------------------------------------------------
    #
    # For a given cycle and member, generate a namelist file with unique
    # seed values.
    #
    #-----------------------------------------------------------------------
    #
    ensmem_name=f"mem{ENSMEM_INDX}"
    
    cdate_i = int(cdate.strftime('%Y%m%d')) 
    fv3_nml_ensmem_fp=f"{CYCLE_BASEDIR}/{cdate_i}/{ensmem_name}/{FV3_NML_FN}"
    
    ensmem_num=ENSMEM_INDX
    
    iseed_shum=cdate_i*1000 + ensmem_num*10 + 2
    iseed_skeb=cdate_i*1000 + ensmem_num*10 + 3
    iseed_sppt=cdate_i*1000 + ensmem_num*10 + 1
    iseed_spp=cdate_i*1000 + ensmem_num*10 + 4
    
    settings=f"""
            'nam_stochy': {{
              'iseed_shum': {iseed_shum},
              'iseed_skeb': {iseed_skeb},
              'iseed_sppt': {iseed_sppt},
              }}
            'nam_spperts': {{
              'iseed_spp': {iseed_spp},
              }}
            """
    
    (err,_,oute) = run_command(f'''{USHDIR}/set_namelist.py -q -n {FV3_NML_FP} -u "{settings}" -o {fv3_nml_ensmem_fp}''')
    print_info_msg(oute)
    if err != 0:
        print_err_msg_exit(dedent(f'''
            Call to python script set_namelist.py to set the variables in the FV3
            namelist file that specify the paths to the surface climatology files
            failed.  Parameters passed to this script are:
              Full path to base namelist file:
                FV3_NML_FP = \"{FV3_NML_FP}\"
              Full path to output namelist file:
                fv3_nml_ensmem_fp = \"{fv3_nml_ensmem_fp}\"
              Namelist settings specified on command line (these have highest precedence):
                settings =
            {settings}'''))

class Testing(unittest.TestCase):
    def test_set_FV3nml_stoch_params(self):
        set_FV3nml_stoch_params(cdate=self.cdate)
    def setUp(self):
        define_macos_utilities();
        set_env_var('DEBUG',True)
        set_env_var('VERBOSE',True)
        USHDIR = os.path.dirname(os.path.abspath(__file__))
        EXPTDIR = USHDIR + "/test_data/expt";
        cp_vrfy(f'{USHDIR}/templates/input.nml.FV3', f'{EXPTDIR}/input.nml')
        self.cdate='20210101'
        mkdir_vrfy("-p", f'{EXPTDIR}/{self.cdate}/mem0')
        set_env_var("USHDIR",USHDIR)
        set_env_var("CYCLE_BASEDIR",EXPTDIR)
        set_env_var("ENSMEM_INDX",0)
        set_env_var("FV3_NML_FN","input.nml")
        set_env_var("FV3_NML_FP",EXPTDIR + "/input.nml")

