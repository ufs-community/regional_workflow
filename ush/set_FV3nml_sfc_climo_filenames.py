#!/usr/bin/env python3

import unittest
import os
from textwrap import dedent

from python_utils import process_args, print_input_args, print_info_msg, print_err_msg_exit,\
                         check_var_valid_value, run_command, mv_vrfy,mkdir_vrfy,cmd_vrfy,cp_vrfy,\
                         rm_vrfy,import_vars,set_env_var,list_to_str,str_to_list,\
                         lowercase, define_macro_utilities

def set_FV3nml_sfc_climo_filenames():
    """
    This function sets the values of the variables in
    the forecast model's namelist file that specify the paths to the surface
    climatology files on the FV3LAM native grid (which are either pregenerated
    or created by the MAKE_SFC_CLIMO_TN task).  Note that the workflow
    generation scripts create symlinks to these surface climatology files
    in the FIXLAM directory, and the values in the namelist file that get
    set by this function are relative or full paths to these links.

    Args:
        None
    Returns:
        None
    """

    # import all environment variables
    import_vars()

    # The regular expression regex_search set below will be used to extract
    # from the elements of the array FV3_NML_VARNAME_TO_SFC_CLIMO_FIELD_MAPPING
    # the name of the namelist variable to set and the corresponding surface
    # climatology field from which to form the name of the surface climatology file
    regex_search = "^[ ]*([^| ]+)[ ]*[|][ ]*([^| ]+)[ ]*$"

    # Set the suffix of the surface climatology files.
    suffix = "tileX.nc"

    # create yaml-complaint string
    settings = '''
            'namsfc': {'''

    dummy_run_dir = EXPTDIR + "/any_cyc"
    if DO_ENSEMBLE == "TRUE":
        dummy_run_dir += "/any_ensmem"

    for i,mapping in enumerate(FV3_NML_VARNAME_TO_SFC_CLIMO_FIELD_MAPPING):
        (_,nml_var_name,_) = run_command( f''' printf "%s\n" "{mapping}" | 
                  {SED} -n -r -e "s/{regex_search}/\\1/p" ''')
        (_,sfc_climo_field_name,_) = run_command(f''' printf "%s\n" "{mapping}" | 
                          {SED} -n -r -e "s/{regex_search}/\\2/p" ''')

        check_var_valid_value(sfc_climo_field_name, SFC_CLIMO_FIELDS)

        fp = f'{FIXLAM}/{CRES}.{sfc_climo_field_name}.{suffix}'
        if RUN_ENVIR != "nco":
            (_,fp,_) = run_command( f'realpath --canonicalize-missing --relative-to="{dummy_run_dir}" "{fp}"' )

        settings += f'''
                "{nml_var_name}": {fp},'''

    settings += '''
            }'''

    print_info_msg(f'''
        The variable \"settings\" specifying values of the namelist variables
        has been set as follows:
        
        settings =
        {settings}''', verbose=DEBUG)

    # Rename the FV3 namelist and call set_namelist
    fv3_nml_base_fp = f'{FV3_NML_FP}.base' 
    mv_vrfy(f'{FV3_NML_FP} {fv3_nml_base_fp}')

    (ext,_,err) = run_command(f'''{USHDIR}/set_namelist.py -q -n {fv3_nml_base_fp} -u "{settings}" -o {FV3_NML_FP}''')

    if ext != 0:
        print_err_msg_exit(f'''
            Call to python script set_namelist.py to set the variables in the FV3
            namelist file that specify the paths to the surface climatology files
            failed.  Parameters passed to this script are:
              Full path to base namelist file:
                fv3_nml_base_fp = \"{fv3_nml_base_fp}\"
              Full path to output namelist file:
                FV3_NML_FP = \"{FV3_NML_FP}\"
              Namelist settings specified on command line (these have highest precedence):
                settings =
            {settings}''')

    rm_vrfy(f'{fv3_nml_base_fp}')

class Testing(unittest.TestCase):
    def test_set_FV3nml_sfc_climo_filenames(self):
        set_FV3nml_sfc_climo_filenames()
    def setUp(self):
        define_macro_utilities();
        set_env_var('DEBUG','TRUE')
        USHDIR = os.path.dirname(os.path.abspath(__file__))
        EXPTDIR = USHDIR + "/test_data/expt";
        FIXLAM = EXPTDIR + "/fix_lam"
        mkdir_vrfy("-p",FIXLAM)
        cp_vrfy(f'{USHDIR}/templates/input.nml.FV3', f'{EXPTDIR}/input.nml')
        set_env_var("USHDIR",USHDIR)
        set_env_var("EXPTDIR",EXPTDIR)
        set_env_var("FIXLAM",FIXLAM)
        set_env_var("DO_ENSEMBLE",False)
        set_env_var("CRES","C3357")
        set_env_var("RUN_ENVIR","nco")
        set_env_var("FV3_NML_FP",EXPTDIR + "/input.nml")

        FV3_NML_VARNAME_TO_SFC_CLIMO_FIELD_MAPPING=[
            "FNALBC  | snowfree_albedo",
            "FNALBC2 | facsf",
            "FNTG3C  | substrate_temperature",
            "FNVEGC  | vegetation_greenness",
            "FNVETC  | vegetation_type",
            "FNSOTC  | soil_type",
            "FNVMNC  | vegetation_greenness",
            "FNVMXC  | vegetation_greenness",
            "FNSLPC  | slope_type",
            "FNABSC  | maximum_snow_albedo"
        ]
        SFC_CLIMO_FIELDS=[
            "facsf",
            "maximum_snow_albedo",
            "slope_type",
            "snowfree_albedo",
            "soil_type",
            "substrate_temperature",
            "vegetation_greenness",
            "vegetation_type"
        ]
        set_env_var("FV3_NML_VARNAME_TO_SFC_CLIMO_FIELD_MAPPING",
                     FV3_NML_VARNAME_TO_SFC_CLIMO_FIELD_MAPPING)
        set_env_var("SFC_CLIMO_FIELDS",SFC_CLIMO_FIELDS)

