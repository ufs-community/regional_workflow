#
#-----------------------------------------------------------------------
#
# This file defines a function that
#
#-----------------------------------------------------------------------
#
function get_extrn_mdl_files_from_noaa_hpss() {
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
# Specify the set of valid argument names for this script/function.  Then
# process the arguments provided to this script/function (which should
# consist of a set of name-value pairs of the form arg1="value1", etc).
#
#-----------------------------------------------------------------------
#
  local valid_args=( \
    "ccpp_phys_suite_fp" \
    "output_varname_sdf_uses_ruc_lsm" \
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
# Declare local variables.
#
#-----------------------------------------------------------------------
#
  local ruc_lsm_name \
        regex_search \
        ruc_lsm_name_or_null \
        sdf_uses_ruc_lsm
#
#-----------------------------------------------------------------------
#
# Set extrn_mdl_fps_in_arcv to the full paths within the archive files of
# the external model files.
#
#-----------------------------------------------------------------------
#
  prefix=${extrn_mdl_arcvrel_dir:+${extrn_mdl_arcvrel_dir}/}
  extrn_mdl_fps_in_arcv=( "${extrn_mdl_fns_in_arcv[@]/#/$prefix}" )

  extrn_mdl_fps_in_arcv_str="( "$( printf "\"%s\" " "${extrn_mdl_fps_in_arcv[@]}" )")"
  extrn_mdl_arcv_fps_str="( "$( printf "\"%s\" " "${extrn_mdl_arcv_fps[@]}" )")"

  print_info_msg "
Fetching external model files from HPSS.  The full paths to these files 
in the archive file(s) (extrn_mdl_fps_in_arcv), the archive files on HPSS 
in which these files are stored (extrn_mdl_arcv_fps), and the staging
directory to which they will be copied (extrn_mdl_staging_dir) are:
  extrn_mdl_fps_in_arcv = ${extrn_mdl_fps_in_arcv_str}
  extrn_mdl_arcv_fps = ${extrn_mdl_arcv_fps_str}
  extrn_mdl_staging_dir = \"${extrn_mdl_staging_dir}\""
#
#-----------------------------------------------------------------------
#
# Get the number of archive files to consider.
#
#-----------------------------------------------------------------------
#
  num_arcv_files="${#extrn_mdl_arcv_fps[@]}"
#
#-----------------------------------------------------------------------
#
# Consider the case of the archive file to be fetched from HPSS being in
# tar format.
#
#-----------------------------------------------------------------------
#
  if [ "${extrn_mdl_arcv_fmt}" = "tar" ]; then
#
#-----------------------------------------------------------------------
#
# Loop through the set of archive files specified in extrn_mdl_arcv_fps
# and extract a subset of the specified external model files from each.
#
#-----------------------------------------------------------------------
#
    num_files_to_extract="${#extrn_mdl_fps_in_arcv[@]}"

    for (( narcv=0; narcv<${num_arcv_files}; narcv++ )); do

      narcv_formatted=$( printf "%02d" $narcv )
      arcv_fp="${extrn_mdl_arcv_fps[$narcv]}"
#
# Before trying to extract (a subset of) the external model files from 
# the current tar archive file (which is on HPSS), create a list of those 
# external model files that are stored in the current tar archive file.  
# For this purpose, we first use the "htar -tvf" command to list all the 
# external model files that are in the current archive file and store the 
# result in a log file.  (This command also indirectly checks whether the 
# archive file exists on HPSS.)  We then grep this log file for each 
# external model file and create a list containing only those external 
# model files that exist in the current archive.
#
# Note that the "htar -tvf" command will fail if the tar archive file 
# itself doesn't exist on HPSS, but it won't fail if any of the external
# model file names passed to it don't exist in the archive file.  In the
# latter case, the missing files' names simply won't appear in the log
# file.
#
      htar_log_fn="log.htar_tvf.${narcv_formatted}"
      htar -tvf ${arcv_fp} ${extrn_mdl_fps_in_arcv[@]} >& ${htar_log_fn} || \
      print_err_msg_exit "\
htar file list operation (\"htar -tvf ...\") failed.  Check the log file 
htar_log_fn in the staging directory (extrn_mdl_staging_di)r for details:
  extrn_mdl_staging_dir = \"${extrn_mdl_staging_dir}\"
  htar_log_fn = \"${htar_log_fn}\""

      i=0
      files_in_crnt_arcv=()
      for (( nfile=0; nfile<${num_files_to_extract}; nfile++ )); do
        extrn_mdl_fp="${extrn_mdl_fps_in_arcv[$nfile]}"
#        grep -n ${extrn_mdl_fp} ${htar_log_fn} 2>&1 && { \
        grep -n ${extrn_mdl_fp} ${htar_log_fn} > /dev/null 2>&1 && { \
          files_in_crnt_arcv[$i]="${extrn_mdl_fp}"; \
          i=$((i+1)); \
        }
      done
#
# If none of the external model files were found in the current archive
# file, print out an error message and exit.
#
      num_files_in_crnt_arcv=${#files_in_crnt_arcv[@]}
      if [ ${num_files_in_crnt_arcv} -eq 0 ]; then
        extrn_mdl_fps_in_arcv_str="( "$( printf "\"%s\" " "${extrn_mdl_fps_in_arcv[@]}" )")"
        print_err_msg_exit "\
The current archive file (arcv_fp) does not contain any of the external 
model files listed in extrn_mdl_fps_in_arcv:
  arcv_fp = \"${arcv_fp}\"
  extrn_mdl_fps_in_arcv = ${extrn_mdl_fps_in_arcv_str}
The archive file should contain at least one external model file; otherwise, 
it would not be needed."
      fi
#
# Extract from the current tar archive file on HPSS all the external model 
# files that exist in that archive file.  Also, save the output of the 
# "htar -xvf" command in a log file for debugging (if necessary).
#
      htar_log_fn="log.htar_xvf.${narcv_formatted}"
      htar -xvf ${arcv_fp} ${files_in_crnt_arcv[@]} >& ${htar_log_fn} || \
      print_err_msg_exit "\
htar file extract operation (\"htar -xvf ...\") failed.  Check the log 
file htar_log_fn in the staging directory (extrn_mdl_staging_dir) for 
details:
  extrn_mdl_staging_dir = \"${extrn_mdl_staging_dir}\"
  htar_log_fn = \"${htar_log_fn}\""
#
# Note that the htar file extract operation above may return with a 0 
# exit code (success) even if one or more (or all) external model files 
# that it is supposed to contain were not extracted.  The names of those 
# files that were not extracted will not be listed in the log file.  Thus, 
# we now check whether the log file contains the name of each external 
# model file that should have been extracted.  If any are missing, we 
# print out a message and exit the script because initial condition and 
# surface field files needed by FV3 cannot be generated without all the 
# external model files.
#
      for fp in "${files_in_crnt_arcv[@]}"; do
#
# If the file path is absolute (i.e. starts with a "/"), then drop the
# leading "/" because htar strips it before writing the file path to the
# log file.
#
        fp=${fp#/}

        grep -n "${fp}" "${htar_log_fn}" > /dev/null 2>&1 || \
        print_err_msg_exit "\
External model file fp not extracted from tar archive file arcv_fp:
  arcv_fp = \"${arcv_fp}\"
  fp = \"$fp\"
Check the log file htar_log_fn in the staging directory (extrn_mdl_staging_dir) 
for details:
  extrn_mdl_staging_dir = \"${extrn_mdl_staging_dir}\"
  htar_log_fn = \"${htar_log_fn}\""

      done

    done
#
#-----------------------------------------------------------------------
#
# For each external model file that was supposed to have been extracted
# from the set of specified archive files, loop through the extraction 
# log files and check that it appears exactly once in one of the log files.  
# If it doesn't appear at all, then it means that file was not extracted,
# and if it appears more than once, then something else is wrong.  In 
# either case, print out an error message and exit.
#
#-----------------------------------------------------------------------
#
    for (( nfile=0; nfile<${num_files_to_extract}; nfile++ )); do
      extrn_mdl_fp="${extrn_mdl_fps_in_arcv[$nfile]}"
#
# If the file path is absolute (i.e. starts with a "/"), then drop the
# leading "/" because htar strips it before writing the file path to the
# log file.
#
      extrn_mdl_fp=${extrn_mdl_fp#/}

      num_occurs=0
      for (( narcv=0; narcv<${num_arcv_files}; narcv++ )); do
        narcv_formatted=$( printf "%02d" $narcv )
        htar_log_fn="log.htar_xvf.${narcv_formatted}"
        grep -n ${extrn_mdl_fp} ${htar_log_fn} > /dev/null 2>&1 && { \
          num_occurs=$((num_occurs+1)); \
        }
      done

      if [ ${num_occurs} -eq 0 ]; then
        print_err_msg_exit "\
The current external model file (extrn_mdl_fp) does not appear in any of
the archive extraction log files:
  extrn_mdl_fp = \"${extrn_mdl_fp}\"
Thus, it was not extracted, likely because it doesn't exist in any of the 
archive files."
      elif [ ${num_occurs} -gt 1 ]; then
        print_err_msg_exit "\
The current external model file (extrn_mdl_fp) appears more than once in
the archive extraction log files:
  extrn_mdl_fp = \"${extrn_mdl_fp}\"
The number of times it occurs in the log files is:
  num_occurs = ${num_occurs}
Thus, it was extracted from more than one archive file, with the last one
that was extracted overwriting all previous ones.  This should normally 
not happen."
      fi

    done
#
#-----------------------------------------------------------------------
#
# If extrn_mdl_arcvrel_dir is not set to the current directory (i.e. it
# is not equal to "."), then the htar command will have created the 
# subdirectory "./${extrn_mdl_arcvrel_dir}" under the current directory 
# and placed the extracted files there.  In that case, we move these 
# extracted files back to the current directory and then remove the 
# subdirectory created by htar.
#
#-----------------------------------------------------------------------
#
    if [ "${extrn_mdl_arcvrel_dir}" != "." ]; then
#
# The code below works if extrn_mdl_arcvrel_dir starts with a "/" or a 
# "./", which are the only case encountered thus far.  The code may have
# to be modified to accomodate other cases.
#
      if [ "${extrn_mdl_arcvrel_dir:0:1}" = "/" ] || \
         [ "${extrn_mdl_arcvrel_dir:0:2}" = "./" ]; then
#
# Strip the "/" or "./" from the beginning of extrn_mdl_arcvrel_dir to
# obtain the relative directory from which to move the extracted files
# to the current directory.  Then move the files.
#
        rel_dir=$( printf "%s" "${extrn_mdl_arcvrel_dir}" | \
                   sed -r 's%^(\/|\.\/)([^/]*)(.*)%\2\3%' ) 
        mv_vrfy ${rel_dir}/* .
#
# Get the first subdirectory in rel_dir, i.e. the subdirectory before the 
# first forward slash.  This is the subdirectory that we want to remove 
# since it no longer contains any files (only subdirectories).  Then remove
# it.
#
        subdir_to_remove=$( printf "%s" "${rel_dir}" | \
                            sed -r 's%^([^/]*)(.*)%\1%' ) 
        rm_vrfy -rf ./${subdir_to_remove}
#
# If extrn_mdl_arcvrel_dir does not start with a "/" (and it is not 
# equal to "."), then print out an error message and exit.
#
      else

        print_err_msg_exit "\
The archive-relative directory specified by extrn_mdl_arcvrel_dir [i.e. 
the directory \"within\" the tar file(s) listed in extrn_mdl_arcv_fps] is
not the current directory (i.e. it is not \".\"), and it does not start 
with a \"/\" or a \"./\":
  extrn_mdl_arcvrel_dir = \"${extrn_mdl_arcvrel_dir}\"
  extrn_mdl_arcv_fps = ${extrn_mdl_arcv_fps_str}
This script must be modified to account for this case."

      fi

    fi
#
#-----------------------------------------------------------------------
#
# Consider the case of the archive file to be fetched from HPSS being in
# zip format.
#
#-----------------------------------------------------------------------
#
  elif [ "${extrn_mdl_arcv_fmt}" = "zip" ]; then
#
#-----------------------------------------------------------------------
#
# For archive files that are in "zip" format files, the array extrn_mdl_arcv_fps 
# containing the list of archive files should contain only one element, 
# i.e. there should be only one archive file to consider.  Check for this.  
# If this ever changes (e.g. due to the way an external model that uses 
# the "zip" format archives its output files on HPSS), the code below must 
# be modified to loop over all archive files.
#
#-----------------------------------------------------------------------
#
    if [ "${num_arcv_files}" -gt 1 ]; then
      print_err_msg_exit "\
Currently, this script is coded to handle only one archive file if the 
archive file format is specified to be \"zip\", but the number of archive 
files (num_arcv_files) passed to this script is greater than 1:
  extrn_mdl_arcv_fmt = \"${extrn_mdl_arcv_fmt}\"
  num_arcv_files = ${num_arcv_files}
Please modify the script to handle more than one \"zip\" archive file.
Note that code already exists in this script that can handle multiple
archive files if the archive file format is specified to be \"tar\", so 
that can be used as a guide for the \"zip\" case."
    else
      arcv_fn="${extrn_mdl_arcv_fns[0]}"
      arcv_fp="${extrn_mdl_arcv_fps[0]}"
    fi
#
#-----------------------------------------------------------------------
#
# Fetch the zip archive file from HPSS.  
#
#-----------------------------------------------------------------------
#
    hsi_log_fn="log.hsi_get"
    hsi get "${arcv_fp}" >& ${hsi_log_fn} || \
    print_err_msg_exit "\
hsi file get operation (\"hsi get ...\") failed.  Check the log file 
hsi_log_fn in the staging directory (extrn_mdl_staging_dir) for details:
  extrn_mdl_staging_dir = \"${extrn_mdl_staging_dir}\"
  hsi_log_fn = \"${hsi_log_fn}\""
#
#-----------------------------------------------------------------------
#
# List the contents of the zip archive file and save the result in a log
# file.
#
#-----------------------------------------------------------------------
#
    unzip_log_fn="log.unzip_lv"
    unzip -l -v ${arcv_fn} >& ${unzip_log_fn} || \
    print_err_msg_exit "\
unzip operation to list the contents of the zip archive file arcv_fn in
the staging directory (extrn_mdl_staging_dir) failed.  Check the log 
file unzip_log_fn in that directory for details:
  arcv_fn = \"${arcv_fn}\"
  extrn_mdl_staging_dir = \"${extrn_mdl_staging_dir}\"
  unzip_log_fn = \"${unzip_log_fn}\""
#
#-----------------------------------------------------------------------
#
# Check that the log file from the unzip command above contains the name
# of each external model file.  If any are missing, then the corresponding 
# files are not in the zip file and thus cannot be extracted.  In that 
# case, print out a message and exit the script because initial condition 
# and surface field files for the FV3-LAM cannot be generated without all 
# the external model files.
#
#-----------------------------------------------------------------------
#
    for fp in "${extrn_mdl_fps_in_arcv[@]}"; do
      grep -n "${fp}" "${unzip_log_fn}" > /dev/null 2>&1 || \
      print_err_msg_exit "\
External model file fp does not exist in the zip archive file arcv_fn in 
the staging directory (extrn_mdl_staging_dir).  Check the log file 
unzip_log_fn in that directory for the contents of the zip archive:
  extrn_mdl_staging_dir = \"${extrn_mdl_staging_dir}\"
  arcv_fn = \"${arcv_fn}\"
  fp = \"$fp\"
  unzip_log_fn = \"${unzip_log_fn}\""
    done
#
#-----------------------------------------------------------------------
#
# Extract the external model files from the zip file on HPSS.  Note that 
# the -o flag to unzip is needed to overwrite existing files.  Otherwise, 
# unzip will wait for user input as to whether the existing files should 
# be overwritten.
#
#-----------------------------------------------------------------------
#
    unzip_log_fn="log.unzip"
    unzip -o "${arcv_fn}" ${extrn_mdl_fps_in_arcv[@]} >& ${unzip_log_fn} || \
    print_err_msg_exit "\
unzip file extract operation (\"unzip -o ...\") failed.  Check the log 
file unzip_log_fn in the staging directory (extrn_mdl_staging_dir) for 
details:
  extrn_mdl_staging_dir = \"${extrn_mdl_staging_dir}\"
  unzip_log_fn = \"${unzip_log_fn}\""
#
# NOTE:
# If extrn_mdl_arcvrel_dir is not empty, the unzip command above will 
# create a subdirectory under extrn_mdl_staging_dir and place the external 
# model files there.  We have not encountered this for the RAP and HRRR 
# models, but it may happen for other models in the future.  In that case, 
# extra code must be included here to move the external model files from 
# the subdirectory up to extrn_mdl_staging_dir and then the subdirectory 
# (analogous to what is done above for the case of extrn_mdl_arcv_fmt set 
# to "tar".
#
 
  fi
#
#
#-----------------------------------------------------------------------
#
# Set output variables.
#
#-----------------------------------------------------------------------
#
  eval ${output_varname_sdf_uses_ruc_lsm}="${sdf_uses_ruc_lsm}"
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/function.
#
#-----------------------------------------------------------------------
#
  { restore_shell_opts; } > /dev/null 2>&1

}

