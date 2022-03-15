#!/usr/bin/env python3

import unittest
import os
from textwrap import dedent

from python_utils import process_args, print_input_args, print_info_msg, print_err_msg_exit,\
                         check_var_valid_value,mkdir_vrfy,cp_vrfy,\
                         import_vars,set_env_var,\
                         define_macos_utilities, cfg_to_yaml_str

from set_namelist import set_namelist

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
    fv3_nml_ensmem_fp=os.path.join(CYCLE_BASEDIR, f"{cdate_i}{os.sep}{ensmem_name}{os.sep}{FV3_NML_FN}")
    
    ensmem_num=ENSMEM_INDX
    
    iseed_shum=cdate_i*1000 + ensmem_num*10 + 2
    iseed_skeb=cdate_i*1000 + ensmem_num*10 + 3
    iseed_sppt=cdate_i*1000 + ensmem_num*10 + 1
    iseed_lsm_spp=cdate_i*1000 + ensmem_num*10 + 9
    
    num_iseed_spp=len(ISEED_SPP)
    iseed_spp = [None]*num_iseed_spp
    for i in range(num_iseed_spp):
      iseed_spp[i]=cdate_i*1000 + ensmem_num*10 + ISEED_SPP[i]

    settings = {}
    if DO_SPPT == True or DO_SHUM == True or DO_SKEB == True:
        settings['nam_stochy'] = {
              'iseed_shum': iseed_shum,
              'iseed_skeb': iseed_skeb,
              'iseed_sppt': iseed_sppt
        }

    if DO_SPP == True:
        settings['nam_spperts'] = {
              'iseed_spp': iseed_spp
        }

    if DO_LSM_SPP == True:
        settings['nam_sppperts'] = {
              'iseed_lndp': [iseed_lsm_spp]
        }

    if settings:
       settings_str = cfg_to_yaml_str(settings)
       try:
           set_namelist(["-q", "-n", FV3_NML_FP, "-u", settings_str, "-o", fv3_nml_ensmem_fp])
       except:
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
               {settings_str}'''))
    else:
        print_info_msg(f'''
            The variable \"settings\" is empty, so not setting any namelist values.''')

class Testing(unittest.TestCase):
    def test_set_FV3nml_stoch_params(self):
        set_FV3nml_stoch_params(cdate=self.cdate)
    def setUp(self):
        define_macos_utilities();
        set_env_var('DEBUG',True)
        set_env_var('VERBOSE',True)
        USHDIR = os.path.dirname(os.path.abspath(__file__))
        EXPTDIR = os.path.join(USHDIR,"test_data","expt");
        cp_vrfy(os.path.join(USHDIR,f'templates{os.sep}input.nml.FV3'), \
                os.path.join(EXPTDIR,'input.nml'))
        self.cdate='20210101'
        mkdir_vrfy("-p", os.path.join(EXPTDIR,f'{self.cdate}{os.sep}mem0'))
        set_env_var("USHDIR",USHDIR)
        set_env_var("CYCLE_BASEDIR",EXPTDIR)
        set_env_var("ENSMEM_INDX",0)
        set_env_var("FV3_NML_FN","input.nml")
        set_env_var("FV3_NML_FP",os.path.join(EXPTDIR,"input.nml"))
        set_env_var("DO_SPPT",True)
        set_env_var("DO_SPP",True)
        set_env_var("DO_LSM_SPP",True)
        ISEED_SPP = [ 4, 4, 4, 4, 4]
        set_env_var("ISEED_SPP",ISEED_SPP)

