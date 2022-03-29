#!/usr/bin/env python3

import unittest
import os
from textwrap import dedent
from datetime import datetime

from python_utils import print_input_args, print_info_msg, print_err_msg_exit,\
                         date_to_str, mkdir_vrfy,cp_vrfy,\
                         import_vars,set_env_var,\
                         define_macos_utilities, cfg_to_yaml_str

from set_namelist import set_namelist

def set_FV3nml_stoch_params(cdate):
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

    print_input_args(locals())

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
    
    fv3_nml_ensmem_fp=os.path.join(CYCLE_BASEDIR, f"{date_to_str(cdate,True)}{os.sep}{ensmem_name}{os.sep}{FV3_NML_FN}")
    print(fv3_nml_ensmem_fp)
    
    ensmem_num=ENSMEM_INDX
    
    cdate_i = int(cdate.strftime('%Y%m%d')) 
    iseed_shum=cdate_i*1000 + ensmem_num*10 + 2
    iseed_skeb=cdate_i*1000 + ensmem_num*10 + 3
    iseed_sppt=cdate_i*1000 + ensmem_num*10 + 1
    iseed_lsm_spp=cdate_i*1000 + ensmem_num*10 + 9
    
    num_iseed_spp=len(ISEED_SPP)
    iseed_spp = [None]*num_iseed_spp
    for i in range(num_iseed_spp):
      iseed_spp[i]=cdate_i*1000 + ensmem_num*10 + ISEED_SPP[i]

    settings = {}
    if DO_SPPT or DO_SHUM or DO_SKEB:
        settings['nam_stochy'] = {
              'iseed_shum': iseed_shum,
              'iseed_skeb': iseed_skeb,
              'iseed_sppt': iseed_sppt
        }

    if DO_SPP:
        settings['nam_spperts'] = {
              'iseed_spp': iseed_spp
        }

    if DO_LSM_SPP:
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
        self.cdate=datetime(2021, 1, 1)
        
        mkdir_vrfy("-p", os.path.join(EXPTDIR,f'{date_to_str(self.cdate,True)}{os.sep}mem0'))
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

