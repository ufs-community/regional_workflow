#!/bin/bash

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#
. ${GLOBAL_VAR_DEFNS_FP}
. $USHDIR/source_util_funcs.sh
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
# Print message indicating entry into script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
Entering script:  \"${scrfunc_fn}\"
In directory:     \"${scrfunc_dir}\"

This is the ex-script for the task that runs a chemical analysis with
JEDI for the specified cycle.
========================================================================"
#
#-----------------------------------------------------------------------
#
# Specify the set of valid argument names for this script/function.
# Then process the arguments provided to this script/function (which
# should consist of a set of name-value pairs of the form arg1="value1",
# etc).
#
#-----------------------------------------------------------------------
#
valid_args=( "JEDI_WORKDIR" "JEDI_WORKDIR_DATA" "JEDI_WORKDIR_INPUT" )
process_args valid_args "$@"
#
#-----------------------------------------------------------------------
#
# For debugging purposes, print out values of arguments passed to this
# script.  Note that these will be printed out only if VERBOSE is set to
# TRUE.
#
#-----------------------------------------------------------------------
#
print_input_args valid_args
#
#-----------------------------------------------------------------------
#
# Set and export variables.
#
#-----------------------------------------------------------------------
#
export OMP_NUM_THREADS=1
export OMP_STACKSIZE=1024m
#
#-----------------------------------------------------------------------
#
# Load modules.
#
#-----------------------------------------------------------------------
#
source ${MACHINE_FILE}
#
#-----------------------------------------------------------------------
#
# Create links to fix files and  executables
#
#-----------------------------------------------------------------------
#
print_info_msg "$VERBOSE" "
Creating links in the JEDI subdirectory of the current cycle's run directory 
to the necessary executables and fix files: \"${JEDI_WORKDIR}\""
# executables
ln_vrfy -sf $EXECDIR/fv3jedi_error_covariance_training.x ${JEDI_WORKDIR}/.
ln_vrfy -sf $EXECDIR/fv3jedi_var.x ${JEDI_WORKDIR}/.
# FV3-JEDI fix files
ln_vrfy -sf $JEDI_DIR/build/fv3-jedi/test/Data/fieldsets ${JEDI_WORKDIR_DATA}/fieldsets
ln_vrfy -sf $JEDI_DIR/build/fv3-jedi/test/Data/fv3files ${JEDI_WORKDIR_DATA}/fv3files
# FV3 namelist
ln_vrfy -sf $FV3_NML_FP ${JEDI_WORKDIR_DATA}/input.nml

print_info_msg "$VERBOSE" "
Creating links in the JEDI/INPUT subdirectory of the current cycle's run di-
rectory to the grid and (filtered) orography files: \"${JEDI_WORKDIR_INPUT}\""

cd_vrfy ${JEDI_WORKDIR_INPUT}

relative_or_null=""
if [ "${RUN_TASK_MAKE_GRID}" = "TRUE" ]; then
  relative_or_null="--relative"
fi

# Symlink to mosaic file with a completely different name.
target="${FIXLAM}/${CRES}${DOT_OR_USCORE}mosaic.halo${NH3}.nc"   # Should this point to this halo4 file or a halo3 file???
symlink="grid_spec.nc"
if [ -f "${target}" ]; then
  ln_vrfy -sf ${relative_or_null} $target $symlink
else
  print_err_msg_exit "\
Cannot create symlink because target does not exist:
  target = \"$target}\""
fi

# Symlink to halo-3 grid file with "halo3" stripped from name.
mosaic_fn="grid_spec.nc"
grid_fn=$( get_charvar_from_netcdf "${mosaic_fn}" "gridfiles" )

target="${FIXLAM}/${grid_fn}"
symlink="${grid_fn}"
if [ -f "${target}" ]; then
  ln_vrfy -sf ${relative_or_null} $target $symlink
else
  print_err_msg_exit "\
Cannot create symlink because target does not exist:
  target = \"$target}\""
fi

# Symlink to halo-4 grid file with "${CRES}_" stripped from name.
#
# If this link is not created, then the code hangs with an error message
# like this:
#
#   check netcdf status=           2
#  NetCDF error No such file or directory
# Stopped
#
# Note that even though the message says "Stopped", the task still con-
# sumes core-hours.
#
target="${FIXLAM}/${CRES}${DOT_OR_USCORE}grid.tile${TILE_RGNL}.halo${NH4}.nc"
symlink="grid.tile${TILE_RGNL}.halo${NH4}.nc"
if [ -f "${target}" ]; then
  ln_vrfy -sf ${relative_or_null} $target $symlink
else
  print_err_msg_exit "\
Cannot create symlink because target does not exist:
  target = \"$target}\""
fi

relative_or_null=""
if [ "${RUN_TASK_MAKE_OROG}" = "TRUE" ]; then
  relative_or_null="--relative"
fi

# Symlink to halo-0 orography file with "${CRES}_" and "halo0" stripped from name.
target="${FIXLAM}/${CRES}${DOT_OR_USCORE}oro_data.tile${TILE_RGNL}.halo${NH0}.nc"
symlink="oro_data.nc"
if [ -f "${target}" ]; then
  ln_vrfy -sf ${relative_or_null} $target $symlink
else
  print_err_msg_exit "\
Cannot create symlink because target does not exist:
  target = \"$target}\""
fi

#
# Symlink to halo-4 orography file with "${CRES}_" stripped from name.
#
# If this link is not created, then the code hangs with an error message
# like this:
#
#   check netcdf status=           2
#  NetCDF error No such file or directory
# Stopped
#
# Note that even though the message says "Stopped", the task still con-
# sumes core-hours.
#
target="${FIXLAM}/${CRES}${DOT_OR_USCORE}oro_data.tile${TILE_RGNL}.halo${NH4}.nc"
symlink="oro_data.tile${TILE_RGNL}.halo${NH4}.nc"
if [ -f "${target}" ]; then
  ln_vrfy -sf ${relative_or_null} $target $symlink
else
  print_err_msg_exit "\
Cannot create symlink because target does not exist:
  target = \"$target}\""
fi

#
#-----------------------------------------------------------------------
#
# link model forecast file location to bkg/ directory
#
#-----------------------------------------------------------------------
#
rst_dir=${PREV_CYCLE_DIR}/RESTART
rst_file=fv_tracer.res.tile1.nc
fv_tracer_file=${rst_dir}/${CDATE:0:8}.${CDATE:8:2}0000.${rst_file}
print_info_msg "
  Looking for tracer restart file: \"${fv_tracer_file}\""
if [ ! -r ${fv_tracer_file} ]; then
  if [ -r ${rst_dir}/coupler.res ]; then
    rst_info=( $( tail -n 1 ${rst_dir}/coupler.res ) )
    rst_date=$( printf "%04d%02d%02d%02d" ${rst_info[@]:0:4} )
    print_info_msg "
  Tracer file not found. Checking available restart date:
    requested date: \"${CDATE}\"
    available date: \"${rst_date}\""
    if [ "${rst_date}" == "${CDATE}" ] ; then
      fv_tracer_file=${rst_dir}/${rst_file}
      if [ -r ${fv_tracer_file} ]; then
        print_info_msg "
  Tracer file found: \"${fv_tracer_file}\""
      else
        print_err_msg_exit "\
  No suitable tracer restart file found."
      fi
    fi
  fi
fi

ln_vrfy -sf $rst_dir ${JEDI_WORKDIR_DATA}/bkg

#
#-----------------------------------------------------------------------
#
# Link observations to working directory
# if Observation directory does not exist, we are going to assume
# the analysis is moot and exit gracefully, but print a message!
#-----------------------------------------------------------------------
#
if [ ! -d "${DA_OBS_DIR}/${CDATE}" ] ; then
  print_info_msg "!==============================================================="
  print_info_msg "! While setting up the JEDI working directory, it was found that"
  print_info_msg "! ${DA_OBS_DIR}/${CDATE} does not exist. Assuming we will skip analysis step."
  print_info_msg "! Exiting this task gracefully"
  print_info_msg "!==============================================================="
  rm_vrfy -rf ${JEDI_WORKDIR}
  exit 0
fi
print_info_msg "$VERBOSE" "
Linking observation directory ${DA_OBS_DIR}/${CDATE} to working directory"
ln_vrfy -sf ${DA_OBS_DIR}/${CDATE} ${JEDI_WORKDIR_DATA}/obs
#
#-----------------------------------------------------------------------
#
# Run Python script to create YAML
#-----------------------------------------------------------------------
#
YAMLS='jedi_no2_3dvar.yaml jedi_no2_bump.yaml'
TEMPLATEDIR=${USHDIR}/templates
${USHDIR}/gen_JEDI_yaml.py -i $TEMPLATEDIR -o ${JEDI_WORKDIR} -c ${CDATE} -y $YAMLS
#
#-----------------------------------------------------------------------
#
# change to JEDI working directory
#
#-----------------------------------------------------------------------
#
cd_vrfy ${JEDI_WORKDIR}
#
#-----------------------------------------------------------------------
#
# Run BUMP first
#
#-----------------------------------------------------------------------
#
${RUN_CMD_UTILS} ./fv3jedi_error_covariance_training.x jedi_no2_bump.yaml || print_err_msg_exit "\
Call to executable to run fv3jedi_error_covariance_training.x returned with nonzero exit
code."
#
#-----------------------------------------------------------------------
#
# Run JEDI var now
#
#-----------------------------------------------------------------------
#
${RUN_CMD_UTILS} ./fv3jedi_var.x jedi_no2_3dvar.yaml || print_err_msg_exit "\
Call to executable to run fv3jedi_var.x returned with nonzero exit
code."
#
#-----------------------------------------------------------------------
#
# Move original RESTART files to .ges suffix
#
#-----------------------------------------------------------------------
#
print_info_msg "$VERBOSE" "
Copying original RESTART fv_tracer to fv_tracer.ges"
cp_vrfy ${fv_tracer_file} ${fv_tracer_file}.ges
#
#-----------------------------------------------------------------------
#
# Use nco tools to take variables in analysis and put in RESTART/
#
#-----------------------------------------------------------------------
#
if [ "${USE_CHEM_ANL}" = "TRUE" ]; then
    print_info_msg "$VERBOSE" "
    Using ncks to merge analysis fields into RESTART file"
    dimvars="xaxis_1,yaxis_1,zaxis_1,Time"
    anl_data_dir=${JEDI_WORKDIR_DATA}/analysis
    fv_tracer_anl=${anl_data_dir}/${CDATE:0:8}.${CDATE:8:2}0000.3dvar_anl.fv_tracer.res.nc
    ncks -A -x -v $dimvars ${fv_tracer_anl} ${fv_tracer_file} || print_err_msg_exit "\
    Call to ncks returned with nonzero exit code."
fi
#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
chemical data assimilation completed successfully!!!

Exiting script:  \"${scrfunc_fn}\"
In directory:    \"${scrfunc_dir}\"
========================================================================"
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/func-
# tion.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1
