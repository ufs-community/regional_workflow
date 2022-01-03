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
scrfunc_fp=$( $READLINK -f "${BASH_SOURCE[0]}" )
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

This is the ex-script for the task that copies/fetches to a local direc-
tory (either from disk or HPSS) the external model files from which ini-
tial or boundary condition files for the FV3 will be generated.
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
valid_args=()
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
#print_input_args valid_args
#
#-----------------------------------------------------------------------
#
# Check if restart file exists
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
#
#-----------------------------------------------------------------------
#
# Create work directory
#
#-----------------------------------------------------------------------
#
workdir="${CYCLE_DIR}/AQM/tmp_AQICS"
mkdir_vrfy -p "${workdir}"
cd_vrfy ${workdir}
#
#-----------------------------------------------------------------------
#
# Add air quality tracer variables from previous cycle's restart output
# to atmosphere's initial condition file according to the steps below:
#
# a. Remove time dimension and microphysics tracers from previous cycle's
#    restart file. 
#
# b. Remove checksum attribute to prevent overflow
#
# c. Rename dimensions and coordinates from restart file to match names
#    in atmosphere's IC file
#
# d-i. GFS ICs are defined on one additional (top) layer than tracers in
#    the restart file. We extract the top layer from the tracer file and
#    set all tracers to 0 (via ncdiff), extend the number of vertical levels
#    by 1 (ncap2), then add the 0-valued top layer. Note that the vertical
#    dimension is set as record (UNLIMITED), then reset to fixed length
#    in order to achieve this result using NCO tools
#
# j. Add the vertically-extended tracers to the GFS IC file
#
# k. Rename reulting file as the expected atmospheric IC file
#
#-----------------------------------------------------------------------
#
# Select ncap or ncap2 tool based on availability
if   command -v ncap2 >/dev/null 2>&1 ; then
  ncap_cmd=ncap2
elif command -v ncap  >/dev/null 2>&1 ; then
  ncap_cmd=ncap
else
  print_err_msg_exit "\
  NCO Arithmetic Processor not found (neither ncap nor ncap2)"
fi

print_info_msg "
  Found NCO Arithmetic Processor: ${ncap_cmd}"
#
#-----------------------------------------------------------------------
#
gfs_ic_file=${CYCLE_DIR}/INPUT/gfs_data.tile${TILE_RGNL}.halo${NH0}.nc
wrk_ic_file=gfs.nc

print_info_msg "
  Adding air quality tracers to atmospheric initial condition file:
    tracer file: \"${fv_tracer_file}\"
    FV3 IC file: \"${gfs_ic_file}\""

cp_vrfy ${gfs_ic_file} ${wrk_ic_file}

exclude_vars="Time,graupel,ice_wat,liq_wat,o3mr,rainwat,snowwat,sphum"
ncwa -a Time -C -x -v "${exclude_vars}" -O ${fv_tracer_file} tmp1.nc

ncatted -a checksum,,d,s, tmp1.nc

ncrename -d xaxis_1,lon -v xaxis_1,lon \
         -d yaxis_1,lat -v yaxis_1,lat \
         -d zaxis_1,lev -v zaxis_1,lev \
         -O tmp1.nc tmp2.nc

ncks --mk_rec_dmn lev -O -o tmp1.nc tmp2.nc

ncks -O -d lev,0,0 tmp1.nc tmp1_ptop.nc

${ncap_cmd} -s 'lev=lev+1' tmp1.nc tmp1_pfull.nc

ncrcat -O -o tmp1.nc tmp1_ptop.nc tmp1_pfull.nc

ncks --fix_rec_dmn lev -C -O -o tmp2.nc tmp1.nc
 
ncks -A -C -x -v lon,lat,lev tmp2.nc ${wrk_ic_file}

mv_vrfy ${wrk_ic_file} ${gfs_ic_file}

rm_vrfy tmp1.nc tmp1_ptop.nc tmp1_pfull.nc tmp2.nc
#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
    print_info_msg "
========================================================================
Successfully added air quality tracers to atmospheric initial condition
file!!!

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

