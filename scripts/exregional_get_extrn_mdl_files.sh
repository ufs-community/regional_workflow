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

This is the ex-script for the task that copies/fetches to a local directory 
either from disk or HPSS) the external model files from which initial or 
boundary condition files for the FV3 will be generated.
========================================================================"
#
#-----------------------------------------------------------------------
#
# Specify the set of valid argument names for this script/function.  Then 
# process the arguments provided to this script/function (which should 
# consist of a set of name-value pairs of the form arg1="value1", etc).
#
#-----------------------------------------------------------------------
#
valid_args=( \
"anl_or_fcst" \
"extrn_mdl_cdate" \
"extrn_mdl_name" \
"extrn_mdl_staging_dir" \
"fcst_hrs" \
"file_names" \
"file_type" \
"input_file_path" \
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
# Set up optional flags for calling retrieve_data.py
#
#-----------------------------------------------------------------------
#
additional_flags=""

if [ -n ${file_names} ] ; then
  additional_flags="$additional_flags
  --file_names ${file_names}"
fi

if [ -n ${file_type} ] ; then 
  additional_flags="$additional_flags
  --file_type ${file_type}"
fi

#
#-----------------------------------------------------------------------
#
# Call ush script to retrieve files
#
#-----------------------------------------------------------------------
#

${USHDIR}/retrieve_data.py \
  --anl_or_fcst ${anl_or_fcst} \
  --config ${USHDIR}/templates/data_locations.yml \
  --cycle_date ${extrn_mdl_cdate} \
  --data_stores disk hpss aws \
  --external_model ${EXTRN_MDL_NAME} \
  --fcst_hrs fcst_hrs \
  --output_path ${extrn_mdl_staging_dir} \
  --input_file_path ${input_file_path} \
  ${additional_flags}

#
#-----------------------------------------------------------------------
#
# Create a variable definitions file (a shell script) and save in it the
# values of several external-model-associated variables generated in this 
# script that will be needed by downstream workflow tasks.
#
#-----------------------------------------------------------------------
#
if [ "${ics_or_lbcs}" = "ICS" ]; then
  extrn_mdl_var_defns_fn="${EXTRN_MDL_ICS_VAR_DEFNS_FN}"
elif [ "${ics_or_lbcs}" = "LBCS" ]; then
  extrn_mdl_var_defns_fn="${EXTRN_MDL_LBCS_VAR_DEFNS_FN}"
fi
extrn_mdl_var_defns_fp="${extrn_mdl_staging_dir}/${extrn_mdl_var_defns_fn}"
check_for_preexist_dir_file "${extrn_mdl_var_defns_fp}" "delete"

if [ "${data_src}" = "disk" ]; then
  extrn_mdl_fns_str="( "$( printf "\"%s\" " "${extrn_mdl_fns_on_disk[@]}" )")"
elif [ "${data_src}" = "HPSS" ]; then
  extrn_mdl_fns_str="( "$( printf "\"%s\" " "${extrn_mdl_fns_in_arcv[@]}" )")"
elif [ "${data_src}" = "online" ]; then
  extrn_mdl_fns_str="( "$( printf "\"%s\" " "${extrn_mdl_fns_on_disk[@]}" )")"
fi

settings="\
DATA_SRC=\"${data_src}\"
EXTRN_MDL_CDATE=\"${extrn_mdl_cdate}\"
EXTRN_MDL_STAGING_DIR=\"${extrn_mdl_staging_dir}\"
EXTRN_MDL_FNS=${extrn_mdl_fns_str}"
#
# If the external model files obtained above were for generating LBCS (as
# opposed to ICs), then add to the external model variable definitions 
# file the array variable EXTRN_MDL_LBC_SPEC_FHRS containing the forecast 
# hours at which the lateral boundary conditions are specified.
#
if [ "${ics_or_lbcs}" = "LBCS" ]; then
  extrn_mdl_lbc_spec_fhrs_str="( "$( printf "\"%s\" " "${extrn_mdl_lbc_spec_fhrs[@]}" )")"
  settings="$settings
EXTRN_MDL_LBC_SPEC_FHRS=${extrn_mdl_lbc_spec_fhrs_str}"
fi

{ cat << EOM >> ${extrn_mdl_var_defns_fp}
$settings
EOM
} || print_err_msg_exit "\
Heredoc (cat) command to create a variable definitions file associated
with the external model from which to generate ${ics_or_lbcs} returned with a 
nonzero status.  The full path to this variable definitions file is:
  extrn_mdl_var_defns_fp = \"${extrn_mdl_var_defns_fp}\""
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/function.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1

