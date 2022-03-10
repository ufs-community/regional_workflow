#!/usr/bin/env python3

import unittest
from datetime import datetime

from python_utils.process_args import process_args
from python_utils.environment import import_vars,set_env_var
from python_utils.print_input_args import print_input_args
from python_utils.run_command import run_command
from python_utils.print_msg import print_info_msg, print_err_msg_exit

def create_model_configure_file(**kwargs):
    """ Creates a model configuration file in the specified
    run directory

    Args:
        cdate: cycle date
        run_dir: run directory
        sub_hourly_post
        dt_subhourly_post_mnts
        dt_atmos
    Returns:
        None
    """

    #process input arguments
    valid_args = [ "cdate", "run_dir", "sub_hourly_post", "dt_subhourly_post_mnts", "dt_atmos" ]
    dictionary = process_args(valid_args, **kwargs)
    print_input_args(dictionary)
    import_vars(dictionary=dictionary)

    #import all environment variables
    import_vars()
    
    #
    #-----------------------------------------------------------------------
    #
    # Create a model configuration file in the specified run directory.
    #
    #-----------------------------------------------------------------------
    #
    print_info_msg(f'''
        Creating a model configuration file (\"{MODEL_CONFIG_FN}\") in the specified
        run directory (run_dir):
          run_dir = \"{run_dir}\"''', verbose=VERBOSE)
    #
    # Extract from cdate the starting year, month, day, and hour of the forecast.
    #
    yyyy=cdate.year
    mm=cdate.month
    dd=cdate.day
    hh=cdate.hour
    #
    # Set parameters in the model configure file.
    #
    dot_quilting_dot=f".{lowercase(str(QUILTING))}."
    dot_print_esmf_dot=f".{lowercase(str(PRINT_ESMF))}."
    dot_cpl_dot=f".{lowercase(str(CPL))}."
    dot_write_dopost=f".{lowercase(str(WRITE_DOPOST))}."
    #
    #-----------------------------------------------------------------------
    #
    # Create a multiline variable that consists of a yaml-compliant string
    # specifying the values that the jinja variables in the template 
    # model_configure file should be set to.
    #
    #-----------------------------------------------------------------------
    #
    settings=f'''
      'PE_MEMBER01': {PE_MEMBER01}
      'print_esmf': {dot_print_esmf_dot}
      'start_year': {yyyy}
      'start_month': {mm}
      'start_day': {dd}
      'start_hour': {hh}
      'nhours_fcst': {FCST_LEN_HRS}
      'dt_atmos': {DT_ATMOS}
      'cpl': {dot_cpl_dot}
      'atmos_nthreads': {OMP_NUM_THREADS_RUN_FCST}
      'restart_interval': {RESTART_INTERVAL}
      'write_dopost': {dot_write_dopost}
      'quilting': {dot_quilting_dot}
      'output_grid': {WRTCMP_output_grid}'''
    #  'output_grid': \'${WRTCMP_output_grid}\'"
    #
    # If the write-component is to be used, then specify a set of computational
    # parameters and a set of grid parameters.  The latter depends on the type
    # (coordinate system) of the grid that the write-component will be using.
    #
    if QUILTING == True:
    
        settings+=f'''
      'write_groups': {WRTCMP_write_groups}
      'write_tasks_per_group': {WRTCMP_write_tasks_per_group}
      'cen_lon': {WRTCMP_cen_lon}
      'cen_lat': {WRTCMP_cen_lat}
      'lon1': {WRTCMP_lon_lwr_left}
      'lat1': {WRTCMP_lat_lwr_left}'''
    
        if WRTCMP_output_grid == "lambert_conformal":
    
          settings+=f'''
      'stdlat1': {WRTCMP_stdlat1}
      'stdlat2': {WRTCMP_stdlat2}
      'nx': {WRTCMP_nx}
      'ny': {WRTCMP_ny}
      'dx': {WRTCMP_dx}
      'dy': {WRTCMP_dy}
      'lon2': \"\"
      'lat2': \"\"
      'dlon': \"\"
      'dlat': \"\"'''
    
        elif WRTCMP_output_grid == "regional_latlon" or \
             WRTCMP_output_grid == "rotated_latlon":
    
          settings+=f'''
      'lon2': {WRTCMP_lon_upr_rght}
      'lat2': {WRTCMP_lat_upr_rght}
      'dlon': {WRTCMP_dlon}
      'dlat': {WRTCMP_dlat}
      'stdlat1': \"\"
      'stdlat2': \"\"
      'nx': \"\"
      'ny': \"\"
      'dx': \"\"
      'dy': \"\"'''
    #
    # If sub_hourly_post is set to "TRUE", then the forecast model must be 
    # directed to generate output files on a sub-hourly interval.  Do this 
    # by specifying the output interval in the model configuration file 
    # (MODEL_CONFIG_FN) in units of number of forecat model time steps (nsout).  
    # nsout is calculated using the user-specified output time interval 
    # dt_subhourly_post_mnts (in units of minutes) and the forecast model's 
    # main time step dt_atmos (in units of seconds).  Note that nsout is 
    # guaranteed to be an integer because the experiment generation scripts 
    # require that dt_subhourly_post_mnts (after conversion to seconds) be 
    # evenly divisible by dt_atmos.  Also, in this case, the variable output_fh 
    # [which specifies the output interval in hours; 
    # see the jinja model_config template file] is set to 0, although this 
    # doesn't matter because any positive of nsout will override output_fh.
    #
    # If sub_hourly_post is set to "FALSE", then the workflow is hard-coded 
    # (in the jinja model_config template file) to direct the forecast model 
    # to output files every hour.  This is done by setting (1) output_fh to 1 
    # here, and (2) nsout to -1 here which turns off output by time step interval.
    #
    # Note that the approach used here of separating how hourly and subhourly
    # output is handled should be changed/generalized/simplified such that 
    # the user should only need to specify the output time interval (there
    # should be no need to specify a flag like sub_hourly_post); the workflow 
    # should then be able to direct the model to output files with that time 
    # interval and to direct the post-processor to process those files 
    # regardless of whether that output time interval is larger than, equal 
    # to, or smaller than one hour.
    #
    if sub_hourly_post == True:
        nsout=dt_subhourly_post_mnts*60 / dt_atmos
        output_fh=0
    else:
        output_fh=1
        nsout=-1

    settings+=f'''
      'output_fh': {output_fh}
      'nsout': {nsout}'''
    
    print_info_msg(f'''
        The variable \"settings\" specifying values to be used in the \"{MODEL_CONFIG_FN}\"
        file has been set as follows:
        #-----------------------------------------------------------------------
        settings =
        {settings}''',verbose=VERBOSE)
    #
    #-----------------------------------------------------------------------
    #
    # Call a python script to generate the experiment's actual MODEL_CONFIG_FN
    # file from the template file.
    #
    #-----------------------------------------------------------------------
    #
    model_config_fp=f"{run_dir}/{MODEL_CONFIG_FN}"
    (err,_,_) = run_command(f'''{USHDIR}/fill_jinja_template.py -q -u "{settings}" -t {MODEL_CONFIG_TMPL_FP} -o {model_config_fp}''')

    if err != 0:
        print_err_msg_exit(f'''
            Call to python script fill_jinja_template.py to create a \"{MODEL_CONFIG_FN}\"
            file from a jinja2 template failed.  Parameters passed to this script are:
              Full path to template rocoto XML file:
                MODEL_CONFIG_TMPL_FP = \"{MODEL_CONFIG_TMPL_FP}\"
              Full path to output rocoto XML file:
                model_config_fp = \"{model_config_fp}\"
              Namelist settings specified on command line:
                settings =
            {settings}''')

class Testing(unittest.TestCase):
    def test_create_model_configure_file(self):
        create_model_configure_file()
        self.assertTrue(False)
    def setUp(self):
        set_env_var('DEBUG','FALSE')

