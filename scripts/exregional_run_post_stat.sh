#!/bin/bash
set -x

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

This is the ex-script for the task that runs METplus for grid-stat on
the UPP output files by initialization time for all forecast hours.
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
valid_args=( \
"postprd_dir" \
"poststat_dir" \
"cdate" \
"fcst_len_hrs" \
)
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
# Get the cycle date and hour (in formats of yyyymmdd and hh, respect-
# ively) from CDATE. Also read in FHR and create a comma-separated list
# for METplus to run over.
#
#-----------------------------------------------------------------------
#
yyyymmdd=${cdate:0:8}
hh=${cdate:8:2}

fhr_len=$( printf "%03d" "${fcst_len_hrs}" )

field1="PMTF"
field2="OZCON"
field3="1 hybrid level"

output_file="${field1}_${field2}-01_2_48.grb2"

cd_vrfy "${poststat_dir}"

basetime=$( $DATE_UTIL --date "$yyyymmdd $hh" +%y%j%H%M )

for fhr in $(seq -f "%03g" 1 ${fcst_len_hrs}); do

  input_file="NATLEV_${basetime}f${fhr}00"

  if [ ${fhr} = "001" ]; then
     wgrib2 ${postprd_dir}/${input_file} -match ":${field1}" -match ":${field3}" -GRIB ${output_file}
     wgrib2 ${postprd_dir}/${input_file} -match ":${field2}" -match ":${field3}" -append -GRIB ${output_file}
  else
     wgrib2 ${postprd_dir}/${input_file} -match ":${field1}" -match ":${field3}" -append -GRIB ${output_file}
     wgrib2 ${postprd_dir}/${input_file} -match ":${field2}" -match ":${field3}" -append -GRIB ${output_file}
  fi

done

#
#-----------------------------------------------------------------------
#
# Set and export variables.
#
#-----------------------------------------------------------------------
#
export OMP_NUM_THREADS=1
export OMP_STACKSIZE=2056M
#
#-----------------------------------------------------------------------
#
# Set machine-dependent parameters.
#
#-----------------------------------------------------------------------
#
case "$MACHINE" in

  "WCOSS_DELL_P3")
    ulimit -s unlimited
    RUN_CMD_UTILS="mpirun"
    ;;

  *)
    source ${MACHINE_FILE}
    ;;

esac
#


#
#-----------------------------------------------------------------------
#
# Execute UPP-POST-STAT
#
#-----------------------------------------------------------------------
#
cp_vrfy "${SR_WX_APP_TOP_DIR}/src/upp_post_stat/PM25-O3-stat" "${EXECDIR}/"
chmod +x ${EXECDIR}/PM25-O3-stat

${RUN_CMD_UTILS} ${EXECDIR}/PM25-O3-stat || \
print_err_msg_exit "\
Call to execute Post-UP Stat failed
"
#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
UPP-POST-STAT completed successfully.

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
