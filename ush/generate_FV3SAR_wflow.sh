#!/bin/bash

#
#-----------------------------------------------------------------------
#
# This file defines and then calls a function that sets up a forecast
# experiment and creates a workflow (according to the parameters speci-
# fied in the configuration file; see instructions).
#
#-----------------------------------------------------------------------
#
function generate_FV3SAR_wflow() {
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
local scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
local scrfunc_fn=$( basename "${scrfunc_fp}" )
local scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Get the name of this function.
#
#-----------------------------------------------------------------------
#
local func_name="${FUNCNAME[0]}"
#
#-----------------------------------------------------------------------
#
# Set directories.
#
#-----------------------------------------------------------------------
#
ushdir="${scrfunc_dir}"
#
#-----------------------------------------------------------------------
#
# Source bash utility functions.
#
#-----------------------------------------------------------------------
#
. $ushdir/source_util_funcs.sh
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; set -u +x; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# Source the file that defines and then calls the setup function.  The
# setup function in turn first sources the default configuration file 
# (which contains default values for the experiment/workflow parameters)
# and then sources the user-specified configuration file (which contains
# user-specified values for a subset of the experiment/workflow parame-
# ters that override their default values).
#
#-----------------------------------------------------------------------
#
. $ushdir/setup.sh
#
#-----------------------------------------------------------------------
#
# Set the full paths to the template and actual workflow xml files.  The
# actual workflow xml will be placed in the run directory and then used
# by rocoto to run the workflow.
#
#-----------------------------------------------------------------------
#

TEMPLATE_XML_FP="${TEMPLATE_DIR}/${WFLOW_XML_FN}"
WFLOW_XML_FP="$EXPTDIR/${WFLOW_XML_FN}"
#
#-----------------------------------------------------------------------
#
# Set local variables that will be used later below to replace place-
# holder values in the workflow xml file.
#
#-----------------------------------------------------------------------
#
PROC_RUN_FCST="${NUM_NODES}:ppn=${NCORES_PER_NODE}"
NPROCS_RUN_FCST=$(( ${NUM_NODES} * ${NCORES_PER_NODE} ))
#
#-----------------------------------------------------------------------
#
# Set the variable containing a generic version of the cycle directory.
# This variable will be used in the rocoto workflow XML file.  By "generic", 
# we mean that the year, month, day, and hour in this variable are 
# placeholders that rocoto will replace with actual values (integers).
#
#-----------------------------------------------------------------------
#
CDATE_generic="@Y@m@d@H"
if [ "${RUN_ENVIR}" = "nco" ]; then
#
# Can't do this because there will be leftover directories from previous
# runs with the same experiment settings that are difficult to remove.
# Have to split the cycle CDATE from the grid name.
#
#  CYCLE_DIR="$STMP/tmpnwprd/${EMC_GRID_NAME}_${CDATE_generic}"

  cycle_basedir="$STMP/tmpnwprd/${EMC_GRID_NAME}" 
  check_for_preexist_dir ${cycle_basedir} ${PREEXISTING_DIR_METHOD}
  CYCLE_DIR="${cycle_basedir}/${CDATE_generic}"

else

  CYCLE_DIR="$EXPTDIR/${CDATE_generic}"

fi
#
#-----------------------------------------------------------------------
#
# Fill in the rocoto workflow XML file with parameter values that are 
# either specified in the configuration file/script (config.sh) or set in
# the setup script sourced above.
#
#-----------------------------------------------------------------------

settings="
  'account': $ACCOUNT
  'sched': $SCHED
  'queue_default': $QUEUE_DEFAULT
  'queue_default_tag': $QUEUE_DEFAULT_TAG
  'queue_hpss': $QUEUE_HPSS
  'queue_hpss_tag': $QUEUE_HPSS_TAG
  'queue_fcst': $QUEUE_FCST
  'queue_fcst_tag': $QUEUE_FCST_TAG
  'proc_run_fcst': $PROC_RUN_FCST
  'nprocs_run_fcst': $NPROCS_RUN_FCST
  'ncores_per_node': $NCORES_PER_NODE
  'ushdir': $USHDIR
  'jobsdir': $JOBSDIR
  'exptdir': $EXPTDIR
  'logdir': $LOGDIR
  'cycle_dir': $CYCLE_DIR
  'global_var_defns_fp': $GLOBAL_VAR_DEFNS_FP
  'extrn_mdl_name_ics': $EXTRN_MDL_NAME_ICS
  'extrn_mdl_name_lbcs': $EXTRN_MDL_NAME_LBCS
  'extrn_mdl_files_sysbasedir_ics': $EXTRN_MDL_FILES_SYSBASEDIR_ICS
  'extrn_mdl_files_sysbasedir_lbcs': $EXTRN_MDL_FILES_SYSBASEDIR_LBCS
  'date_first_cycl': !datetime $DATE_FIRST_CYCL${CYCL_HRS[0]}
  'date_last_cycl': !datetime $DATE_LAST_CYCL${CYCL_HRS[0]}
  'cycl_freq': !!str 24:00:00
  'fcst_len_hrs': $FCST_LEN_HRS
  'make_grid_tn': $MAKE_GRID_TN
  'make_orog_tn': $MAKE_OROG_TN
  'make_sfc_climo_tn': $MAKE_SFC_CLIMO_TN
  'get_extrn_ics_tn': $GET_EXTRN_ICS_TN
  'get_extrn_lbcs_tn': $GET_EXTRN_LBCS_TN
  'make_ics_tn': $MAKE_ICS_TN
  'make_lbcs_tn': $MAKE_LBCS_TN
  'run_fcst_tn': $RUN_FCST_TN
  'run_post_tn': $RUN_POST_TN
  'run_task_make_grid': $RUN_TASK_MAKE_GRID
  'run_task_make_orog': $RUN_TASK_MAKE_OROG
  'run_task_make_sfc_climo': $RUN_TASK_MAKE_SFC_CLIMO
"

$USHDIR/create_xml.py -q -u "${settings}" -t $TEMPLATE_XML_FP -o $WFLOW_XML_FP || exit 1

#
#-----------------------------------------------------------------------
#
# For select workflow tasks, create symlinks (in an appropriate subdi-
# rectory under the workflow directory tree) that point to module files
# in the various cloned external repositories.  In principle, this is 
# better than having hard-coded module files for tasks because the sym-
# links will always point to updated module files.  However, it does re-
# quire that these module files in the external repositories be coded
# correctly, e.g. that they really be lua module files and not contain
# any shell commands (like "export SOME_VARIABLE").
#
#-----------------------------------------------------------------------
#
machine=${MACHINE,,}

cd_vrfy "${MODULES_DIR}/tasks/$machine"

#
# The "module" file (really a shell script) for orog in the UFS_UTILS 
# repo uses a shell variable named MOD_PATH, but it is not clear where
# that is defined.  That needs to be fixed.  Until then, we have to use
# a hard-coded module file, which may or may not be compatible with the
# modules used in the UFS_UTILS repo to build the orog code.
#ln_vrfy -fs "${UFS_UTILS_DIR}/modulefiles/fv3gfs/orog.$machine" \
#            "${MAKE_OROG_TN}"
ln_vrfy -fs "${MAKE_OROG_TN}.hardcoded" "${MAKE_OROG_TN}"

ln_vrfy -fs "${UFS_UTILS_DIR}/modulefiles/modulefile.sfc_climo_gen.$machine" \
            "${MAKE_SFC_CLIMO_TN}"

#ln_vrfy -fs "${CHGRES_DIR}/modulefiles/chgres_cube.$machine" \
#            "${MAKE_ICS_TN}"
#ln_vrfy -fs "${MAKE_ICS_TN}.hardcoded" "${MAKE_ICS_TN}"
cp_vrfy "${CHGRES_DIR}/modulefiles/chgres_cube.$machine" \
        "${MAKE_ICS_TN}"
cat "${MAKE_ICS_TN}.local" >> "${MAKE_ICS_TN}"

#ln_vrfy -fs "${CHGRES_DIR}/modulefiles/chgres_cube.$machine" \
#            "${MAKE_LBCS_TN}"
#ln_vrfy -fs "${MAKE_LBCS_TN}.hardcoded" "${MAKE_LBCS_TN}"
cp_vrfy "${CHGRES_DIR}/modulefiles/chgres_cube.$machine" \
        "${MAKE_LBCS_TN}"
cat "${MAKE_LBCS_TN}.local" >> "${MAKE_LBCS_TN}"

ln_vrfy -fs "${UFS_WTHR_MDL_DIR}/NEMS/src/conf/modules.nems" \
            "${RUN_FCST_TN}"


#Only some platforms build EMC_post using modules
case $MACHINE in

"CHEYENNE")
  print_info_msg "No post modulefile needed for $MACHINE"
  ;;

*)
  ln_vrfy -fs "${EMC_POST_DIR}/modulefiles/post/v8.0.0-$machine" \
            "${RUN_POST_TN}"
  ;;

esac

cd_vrfy -
#
#-----------------------------------------------------------------------
#
# Copy the workflow (re)launch script to the experiment directory.
#
#-----------------------------------------------------------------------
#
print_info_msg "
Creating symlink in the experiment directory (EXPTDIR) to the workflow
launch script (WFLOW_LAUNCH_SCRIPT_FP):
  EXPTDIR = \"${EXPTDIR}\"
  WFLOW_LAUNCH_SCRIPT_FP = \"${WFLOW_LAUNCH_SCRIPT_FP}\""
ln_vrfy -fs "${WFLOW_LAUNCH_SCRIPT_FP}" "$EXPTDIR"
#
#-----------------------------------------------------------------------
#
# If USE_CRON_TO_RELAUNCH is set to TRUE, add a line to the user's cron
# table to call the (re)launch script every CRON_RELAUNCH_INTVL_MNTS mi-
# nutes.
#
#-----------------------------------------------------------------------
#
if [ "${USE_CRON_TO_RELAUNCH}" = "TRUE" ]; then
#
# Make a backup copy of the user's crontab file and save it in a file.
#
  time_stamp=$( date "+%F_%T" )
  crontab_backup_fp="$EXPTDIR/crontab.bak.${time_stamp}"
  print_info_msg "
Copying contents of user cron table to backup file:
  crontab_backup_fp = \"${crontab_backup_fp}\""
  crontab -l > ${crontab_backup_fp}
#
# Below, we use "grep" to determine whether the crontab line that the 
# variable CRONTAB_LINE contains is already present in the cron table.  
# For that purpose, we need to escape the asterisks in the string in 
# CRONTAB_LINE with backslashes.  Do this next.
#
  crontab_line_esc_astr=$( printf "%s" "${CRONTAB_LINE}" | \
                           sed -r -e "s%[*]%\\\\*%g" )
#
# In the grep command below, the "^" at the beginning of the string be-
# ing passed to grep is a start-of-line anchor while the "$" at the end
# of the string is an end-of-line anchor.  Thus, in order for grep to 
# find a match on any given line of the output of "crontab -l", that 
# line must contain exactly the string in the variable crontab_line_-
# esc_astr without any leading or trailing characters.  This is to eli-
# minate situations in which a line in the output of "crontab -l" con-
# tains the string in crontab_line_esc_astr but is precedeeded, for ex-
# ample, by the comment character "#" (in which case cron ignores that
# line) and/or is followed by further commands that are not part of the 
# string in crontab_line_esc_astr (in which case it does something more
# than the command portion of the string in crontab_line_esc_astr does).
#
  grep_output=$( crontab -l | grep "^${crontab_line_esc_astr}$" )
  exit_status=$?

  if [ "${exit_status}" -eq 0 ]; then

    print_info_msg "
The following line already exists in the cron table and thus will not be
added:
  CRONTAB_LINE = \"${CRONTAB_LINE}\""
  
  else

    print_info_msg "
Adding the following line to the cron table in order to automatically
resubmit FV3SAR workflow:
  CRONTAB_LINE = \"${CRONTAB_LINE}\""

    ( crontab -l; echo "${CRONTAB_LINE}" ) | crontab -

  fi

fi
#
#-----------------------------------------------------------------------
#
# Copy fixed files from system directory to the FIXam directory (which 
# is under the experiment directory).  Note that some of these files get
# renamed.
#
#-----------------------------------------------------------------------
#

# In NCO mode, we assume the following copy operation is done beforehand,
# but that can be changed.
if [ "${RUN_ENVIR}" != "nco" ]; then

  print_info_msg "$VERBOSE" "
Copying fixed files from system directory to the experiment directory..."

  check_for_preexist_dir $FIXam "delete"
  mkdir -p $FIXam

  cp_vrfy $FIXgsm/global_hyblev.l65.txt $FIXam
  for (( i=0; i<${NUM_FIXam_FILES}; i++ )); do
    cp_vrfy $FIXgsm/${FIXgsm_FILENAMES[$i]} \
            $FIXam/${FIXam_FILENAMES[$i]}
  done

fi
#
#-----------------------------------------------------------------------
#
# Copy templates of various input files to the experiment directory.
#
#-----------------------------------------------------------------------
#
print_info_msg "$VERBOSE" "
Copying templates of various input files to the experiment directory..."

print_info_msg "$VERBOSE" "
  Copying the template data table file to the experiment directory..."
cp_vrfy "${DATA_TABLE_TMPL_FP}" "${DATA_TABLE_FP}"

print_info_msg "$VERBOSE" "
  Copying the template field table file to the experiment directory..."
cp_vrfy "${FIELD_TABLE_TMPL_FP}" "${FIELD_TABLE_FP}"

print_info_msg "$VERBOSE" "
  Copying the template NEMS configuration file to the experiment direct-
  ory..."
cp_vrfy "${NEMS_CONFIG_TMPL_FP}" "${NEMS_CONFIG_FP}"
#
# If using CCPP ... 
#
if [ "${USE_CCPP}" = "TRUE" ]; then
#
# Copy the CCPP physics suite definition file from its location in the 
# clone of the FV3 code repository to the experiment directory (EXPT-
# DIR).
#
  print_info_msg "$VERBOSE" "
Copying the CCPP physics suite definition XML file from its location in
the forecast model directory sturcture to the experiment directory..."
  cp_vrfy "${CCPP_PHYS_SUITE_IN_CCPP_FP}" "${CCPP_PHYS_SUITE_FP}"
#
# If using the GSD_v0 or GSD_SAR physics suite, copy the fixed file con-
# taining cloud condensation nuclei (CCN) data that is needed by the 
# Thompson microphysics parameterization to the experiment directory.
#
  if [ "${CCPP_PHYS_SUITE}" = "FV3_GSD_v0" ] || \
     [ "${CCPP_PHYS_SUITE}" = "FV3_GSD_SAR_v1" ] || \
     [ "${CCPP_PHYS_SUITE}" = "FV3_GSD_SAR" ]; then
    print_info_msg "$VERBOSE" "
Copying the fixed file containing cloud condensation nuclei (CCN) data 
(needed by the Thompson microphysics parameterization) to the experiment
directory..."
    cp_vrfy "$FIXgsd/CCN_ACTIVATE.BIN" "$EXPTDIR"
  fi

fi
#
#-----------------------------------------------------------------------
#
# Set parameters in the FV3SAR namelist file.
#
#-----------------------------------------------------------------------
#
print_info_msg "$VERBOSE" "
Setting parameters in FV3 namelist file (FV3_NML_FP):
  FV3_NML_FP = \"${FV3_NML_FP}\""
#
# Set npx and npy, which are just NX plus 1 and NY plus 1, respectively.  
# These need to be set in the FV3SAR Fortran namelist file.  They repre-
# sent the number of cell vertices in the x and y directions on the re-
# gional grid.
#
npx=$((NX+1))
npy=$((NY+1))
#
# Set parameters.
#

# Question:
# For a JPgrid type grid, what should stretch_fac be set to?  This de-
# pends on how the FV3 code uses the stretch_fac parameter in the name-
# list file.  Recall that for a JPgrid, it gets set in the function 
# set_gridparams_JPgrid(.sh) to something like 0.9999, but is it ok to
# set it to that here in the FV3 namelist file?

# For the GSD_v0 and the GSD_SAR physics suites, set the parameter lsoil
# according to the external models used to obtain ICs and LBCs.
#

if [ "${CCPP_PHYS_SUITE}" = "FV3_GSD_v0" ] || \
   [ "${CCPP_PHYS_SUITE}" = "FV3_GSD_SAR" ]; then

  if [ "${EXTRN_MDL_NAME_ICS}" = "GSMGFS" -o \
       "${EXTRN_MDL_NAME_ICS}" = "FV3GFS" ] && \
     [ "${EXTRN_MDL_NAME_LBCS}" = "GSMGFS" -o \
       "${EXTRN_MDL_NAME_LBCS}" = "FV3GFS" ]; then
    lsoil=4
  elif [ "${EXTRN_MDL_NAME_ICS}" = "RAPX" -o \
         "${EXTRN_MDL_NAME_ICS}" = "HRRRX" ] && \
       [ "${EXTRN_MDL_NAME_LBCS}" = "RAPX" -o \
         "${EXTRN_MDL_NAME_LBCS}" = "HRRRX" ]; then
    lsoil=9
  else
    print_err_msg_exit "\
The value to set the variable lsoil to in the FV3 namelist file (FV3_-
NML_FP) has not been specified for the following combination of physics
suite and external models for ICs and LBCs:
  CCPP_PHYS_SUITE = \"${CCPP_PHYS_SUITE}\"
  EXTRN_MDL_NAME_ICS = \"${EXTRN_MDL_NAME_ICS}\"
  EXTRN_MDL_NAME_LBCS = \"${EXTRN_MDL_NAME_LBCS}\"
Please change one or more of these parameters or provide a value for 
lsoil (and change workflow generation script(s) accordingly) and rerun."
  fi

fi

settings="
'atmos_model_nml': {
    'blocksize': ${BLOCKSIZE},
    'ccpp_suite': ${CCPP_PHYS_SUITE},
  },
'fv_core_nml': {
    'layout': [${LAYOUT_X}, ${LAYOUT_Y}],
    'npx': ${npx},
    'npy': ${npy},
    'target_lat': ${LAT_CTR},
    'target_lon': ${LON_CTR},
    'stretch_fac': ${STRETCH_FAC},
    'bc_update_interval': ${LBC_UPDATE_INTVL_HRS},
  },
'gfs_physics_nml': {
    'lsoil': ${lsoil:-null},
  },
'namsfc': {
     'FNSMCC': ${FNSMCC},
     'FNSOTC': ${FNSOTC},
     'FNVETC': ${FNVETC},
     'FNABSC': ${FNABSC},
     'FNALBC': ${FNALBC},
     'FNGLAC': ${FNGLAC},
     'FNMXIC': ${FNMXIC},
     'FNTSFC': ${FNTSFC},
     'FNSNOC': ${FNSNOC},
     'FNZORC': ${FNZORC},
     'FNALBC2': ${FNALBC2},
     'FNAISC': ${FNAISC},
     'FNTG3C': ${FNTG3C},
     'FNVEGC': ${FNVEGC},
     'FNMSKH': ${FNMSKH},
     'FNTSFA': ${FNTSFA},
     'FNACNA': ${FNACNA},
     'FNSNOA': ${FNSNOA},
     'FNVMNC': ${FNVMNC},
     'FNVMXC': ${FNVMXC},
     'FNSLPC': ${FNSLPC},
   },
"

$USHDIR/set_namelist.py -q -c $FV3_NML_CONFIG_FP $CCPP_PHYS_SUITE -n $FV3_NML_BASE_FP -o ${FV3_NML_FP} -u "{$settings}" 
if [[ $? -ne 0 ]]; then
  echo "
  !!!!!!!!!!!!!!!!!!!!!!

  set_namelist.py failed!
  Check documentation to ensure that the proper python environment is available

  !!!!!!!!!!!!!!!!!!!!!!
  "
  exit 1
fi
#
#-----------------------------------------------------------------------
#
# To have a record of how this experiment/workflow was generated, copy
# the experiment/workflow configuration file to the experiment directo-
# ry.
#
#-----------------------------------------------------------------------
#
cp_vrfy $USHDIR/${EXPT_CONFIG_FN} $EXPTDIR
#
#-----------------------------------------------------------------------
#
# For convenience, print out the commands that need to be issued on the 
# command line in order to launch the workflow and to check its status.  
# Also, print out the command that should be placed in the user's cron-
# tab in order for the workflow to be continually resubmitted.
#
#-----------------------------------------------------------------------
#
wflow_db_fn="${WFLOW_XML_FN%.xml}.db"
rocotorun_cmd="rocotorun -w ${WFLOW_XML_FN} -d ${wflow_db_fn} -v 10"
rocotostat_cmd="rocotostat -w ${WFLOW_XML_FN} -d ${wflow_db_fn} -v 10"

print_info_msg "
========================================================================
========================================================================

Workflow generation completed.

========================================================================
========================================================================

The experiment directory is:

  > EXPTDIR=\"$EXPTDIR\"

"
case $MACHINE in

"CHEYENNE")
  print_info_msg "To launch the workflow, first ensure that you have a compatible version
of rocoto in your \$PATH. On Cheyenne, version 1.3.1 has been pre-built; you can load it
in your \$PATH with one of the following commands, depending on your default shell:

bash:
  > export PATH=\${PATH}:/glade/p/ral/jntp/tools/rocoto/rocoto-1.3.1/bin/

tcsh:
  > setenv PATH \${PATH}:/glade/p/ral/jntp/tools/rocoto/rocoto-1.3.1/bin/
"
  ;;

*)
  print_info_msg "To launch the workflow, first ensure that you have a compatible version
of rocoto loaded.  For example, to load version 1.3.1 of rocoto, use

  > module load rocoto/1.3.1

(This version has been tested on hera; later versions may also work but
have not been tested.)  
"
  ;;

esac
print_info_msg "
To launch the workflow, change location to the 
experiment directory (EXPTDIR) and issue the rocotrun command, as fol-
lows:

  > cd $EXPTDIR
  > ${rocotorun_cmd}

To check on the status of the workflow, issue the rocotostat command 
(also from the experiment directory):

  > ${rocotostat_cmd}

Note that:

1) The rocotorun command must be issued after the completion of each 
   task in the workflow in order for the workflow to submit the next 
   task(s) to the queue.

2) In order for the output of the rocotostat command to be up-to-date,
   the rocotorun command must be issued immediately before the rocoto-
   stat command.

For automatic resubmission of the workflow (say every 3 minutes), the 
following line can be added to the user's crontab (use \"crontab -e\" to
edit the cron table): 

*/3 * * * * cd $EXPTDIR && ./launch_FV3SAR_wflow.sh

Done.
"
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/func-
# tion.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1

}




#
#-----------------------------------------------------------------------
#
# Start of the script that will call the experiment/workflow generation 
# function defined above.
#
#-----------------------------------------------------------------------
#
set -u
#set -x
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
scrfunc_fn=$( basename "${scrfunc_fp}" )
scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Set directories.
#
#-----------------------------------------------------------------------
#
ushdir="${scrfunc_dir}"
#
# Set the name of and full path to the temporary file in which we will 
# save some experiment/workflow variables.  The need for this temporary
# file is explained below.
#
tmp_fn="tmp"
tmp_fp="$ushdir/${tmp_fn}"
rm -f "${tmp_fp}"
#
# Set the name of and full path to the log file in which the output from
# the experiment/workflow generation function will be saved.
#
log_fn="log.generate_FV3SAR_wflow"
log_fp="$ushdir/${log_fn}"
rm -f "${log_fp}"
#
# Call the generate_FV3SAR_wflow function defined above to generate the
# experiment/workflow.  Note that we pipe the output of the function 
# (and possibly other commands) to the "tee" command in order to be able
# to both save it to a file and print it out to the screen (stdout).  
# The piping causes the call to the function (and the other commands 
# grouped with it using the curly braces, { ... }) to be executed in a 
# subshell.  As a result, the experiment/workflow variables that the 
# function sets are not available outside of the grouping, i.e. they are
# not available at and after the call to "tee".  Since some of these va-
# riables are needed after the call to "tee" below, we save them in a 
# temporary file and read them in outside the subshell later below.
#
{ 
generate_FV3SAR_wflow 2>&1  # If this exits with an error, the whole {...} group quits, so things don't work...
retval=$?
echo "$EXPTDIR" >> "${tmp_fp}"
echo "$retval" >> "${tmp_fp}"
} | tee "${log_fp}"
#
# Read in experiment/workflow variables needed later below from the tem-
# porary file created in the subshell above containing the call to the 
# generate_FV3SAR_wflow function.  These variables are not directly 
# available here because the call to generate_FV3SAR_wflow above takes
# place in a subshell (due to the fact that we are then piping its out-
# put to the "tee" command).  Then remove the temporary file.
#
exptdir=$( sed "1q;d" "${tmp_fp}" )
retval=$( sed "2q;d" "${tmp_fp}" )
rm "${tmp_fp}"
#
# If the call to the generate_FV3SAR_wflow function above was success-
# ful, move the log file in which the "tee" command saved the output of
# the function to the experiment directory.
#
if [[ $retval -eq 0 ]]; then
  mv "${log_fp}" "$exptdir"
#
# If the call to the generate_FV3SAR_wflow function above was not suc-
# cessful, print out an error message and exit with a nonzero return 
# code.
# 
else
  printf "
Experiment/workflow generation failed.  Check the log file from the ex-
periment/workflow generation script in the file specified by log_fp:
  log_fp = \"${log_fp}\"
Stopping.
"
  exit 1
fi



