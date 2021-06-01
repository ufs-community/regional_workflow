#!/bin/bash

#
#-----------------------------------------------------------------------
#
# This file defines a function that
#
#-----------------------------------------------------------------------
#
function get_WE2Etest_names_subdirs_descs() {
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
# Specify the set of valid argument names for this script/function.  Then
# process the arguments provided to this script/function (which should
# consist of a set of name-value pairs of the form arg1="value1", etc).
#
#-----------------------------------------------------------------------
#
  local valid_args=( \
    "ushdir" \
    "WE2E_basedir" \
    "WE2E_category_subdirs" \
    "output_varname_WE2E_test_names" \
    "output_varname_WE2E_test_subdirs" \
    "output_varname_WE2E_test_descs" \
    )
#  process_args "valid_args" "$@"
  local set_args_cmd=$( process_args "valid_args" "$@" )
  eval ${set_args_cmd}
#
#-----------------------------------------------------------------------
#
# For debugging purposes, print out values of arguments passed to this
# script.  Note that these will be printed out only if VERBOSE is set to
# TRUE.
#
#-----------------------------------------------------------------------
#
  print_input_args "valid_args"
##
##-----------------------------------------------------------------------
##
## Get the full path to the file in which this script/function is located
## (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
## which the file is located (scrfunc_dir).
##
##-----------------------------------------------------------------------
##
#scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
#scrfunc_fn=$( basename "${scrfunc_fp}" )
#scrfunc_dir=$( dirname "${scrfunc_fp}" )
##
##-----------------------------------------------------------------------
##
## The current script should be located in the "tests" subdirectory of the
## workflow's top-level directory, which we denote by homerrfs.  Thus,
## homerrfs is the directory one level above the directory in which the
## current script is located.  Set homerrfs accordingly.
##
##-----------------------------------------------------------------------
##
#homerrfs=${scrfunc_dir%/*}
##
##-----------------------------------------------------------------------
##
## Set directories.
##
##-----------------------------------------------------------------------
##
#ushdir="$homerrfs/ush"
#WE2E_basedir="$homerrfs/tests/baseline_configs"
#
#-----------------------------------------------------------------------
#
# Source bash utility functions.
#
#-----------------------------------------------------------------------
#
. $ushdir/source_util_funcs.sh


##
##-----------------------------------------------------------------------
##
##
##
##-----------------------------------------------------------------------
##
#WE2E_category_subdirs=( \
#  "." \
#  "grids_extrn_mdls_suites_community" \
#  "grids_extrn_mdls_suites_nco" \
#  "wflow_features" \
#  )
#
#-----------------------------------------------------------------------
#
# Declare local variables.
#
#-----------------------------------------------------------------------
#
  local all_items \
        config_fn \
        crnt_item \
        cwd \
        i \
        line \
        num_files \
        num_occurrences \
        num_symlinked_tests \
        num_WE2E_category_subdirs \
        num_WE2E_tests \
        regex_search \
        subdir \
        subdirs \
        symlinked_test_name \
        symlinked_test_subdir \
        target_dir \
        target_fn \
        target_fp \
        target_test_name \
        target_test_name_or_null \
        test_desc \
        test_name \
        test_name_or_null \
        WE2E_symlinked_test_names \
        WE2E_symlinked_test_subdirs \
        WE2E_symlinked_test_target_test_names \
        WE2E_test_descs \
        WE2E_test_names \
        WE2E_test_names_orig \
        WE2E_test_subdirs
#
#-----------------------------------------------------------------------
#
# Loop through all subdirectories under the WE2E tests base directory
# (including the base directory itself since the first element of
# WE2E_category_subdirs is ".").  From each such subdirectory, collect the
# names of all WE2E tests and append them in the array WE2E_test_names.
# Also, for each test added to WE2E_test_names, create a corresponding
# element in the array WE2E_test_subdirs that specifies the subdirectory under
# WE2E_basedir in which the test was found.
#
#-----------------------------------------------------------------------
#
WE2E_test_names=()
WE2E_test_subdirs=()
WE2E_test_descs=()

WE2E_symlinked_test_names=()
WE2E_symlinked_test_subdirs=()
WE2E_symlinked_test_target_test_names=()

num_WE2E_category_subdirs="${#WE2E_category_subdirs[@]}"
for (( i=0; i<=$((num_WE2E_category_subdirs-1)); i++ )); do

  subdir="${WE2E_category_subdirs[$i]}"
  cd_vrfy "${WE2E_basedir}/$subdir"
#
# Get the contents of the current subdirectory.  Consider each item that
# has a name of the form
#
#   config.${test_name}.sh
#
# to be a WE2E test base configuration file, and take the name of the
# test to be whatever test_name in the above expression happens to be.
# Ignore all other items in the subdirectory.
#
  all_items=( $(ls -1) )
  num_files="${#all_items[@]}"
  for (( j=0; j<=$((num_files-1)); j++ )); do

    crnt_item="${all_items[$j]}"
#
# Take further action for this item (file, symlink, directory, etc) only
# if it has a name of the form "config.${string}.sh", in which case we
# will take ${string} to be the name of the test.
#
    regex_search="^config\.(.*)\.sh$"
    test_name_or_null=$( printf "%s\n" "${crnt_item}" | \
                         sed -n -r -e "s/${regex_search}/\1/p" )

    if [ ! -z "${test_name_or_null}" ]; then
#
#-----------------------------------------------------------------------
#
# Use bash's -h conditional operator to check whether the current item
# is a symlink.  If it is a symlink, its target (after successively
# resolving all symlinks) may be a file, a directory, or a non-existent
# item (or something more exotic that we are not concerned with here).
# The only valid target we allow here is a file.  Thus, below, we check
# for these various possibilities and only allow the case of the target
# being an existing file.
#
#-----------------------------------------------------------------------
#
      if [ -h "${crnt_item}" ]; then
#
# Extract the name of the test from the name of the symlink and append
# it to the array WE2E_symlinked_test_names.  Also, append the subdirectory
# under WE2E_basedir under which the symlink is located to the array
# WE2E_symlinked_test_subdirs.
#
        WE2E_symlinked_test_names+=("${test_name_or_null}")
        WE2E_symlinked_test_subdirs+=("$subdir")
#
# Get the full path to the target of the symlink.  Then use bash's -f
# conditional operator to check whether the target is a "regular" file
# (as defined by bash).  Note that this test will return false if the
# target is a directory or does not exist and true otherwise.  Thus, the
# negation of this test used on the target (i.e. ! -f) that we use below
# will be true if the target is not an existing file.  In this case, we
# print out an error message and exit.
#
# Note that the -f operator recursively follows symlinks passed to it as
# an argument.  Thus, in the if-statement below, we could have used the
# name of the symlink (crnt_item) instead of the full path to the target
# (target_fp).  However, since below the full path to the target is needed
# for other uses as well, for clarity we simply use it.
#
        target_fp=$( readlink -f "${crnt_item}" )
#
# We require the target of the symlink to be a regular file, i.e. not
# another symlink, that is located in a subdirectory under the WE2E tests
# base directory (WE2E_basedir) or in the directory itself and has a
# name that follows the expected format for a WE2E test base configuration
# file, i.e. "config.${test_name}.sh".  Below, we check for all these
# conditions.
#
# First, check whether the target is a regular file.  If not, print out
# a warning and exit.
#
        if [ ! -f "${target_fp}" ]; then
          cwd="$(pwd)"
          print_err_msg_exit "\
The symlink (crnt_item) in the current directory (cwd) has a target
(target_fp) that is not a \"regular\" file (as defined by bash):
  cwd = \"${cwd}\"
  crnt_item = \"${crnt_item}\"
  target_fp = \"${target_fp}\"
This is probably because either the target doesn't exist or is a directory,
neither of which is allowed because the symlink must point to an existing
WE2E test base configuration file.  Please either point the symlink to
such a file or remove it, then rerun."
        fi
#
# Next, check whether the directory in which the target is located is
# under the WE2E tests base directory (WE2E_basedir).  We require that
# the target be located in one of the subdirectories under WE2E_basedir
# because the former represent each of the WE2E test categories, and
# every such test must fall into one of these categories.
#
        target_dir=$( dirname "${target_fp}" )
#
# Note that the bash parameter expansion ${var/search/replace} returns
# $var but with the first instance of "search" replaced by "replace" if
# the former is found in $var.  Otherwise, it returns the original $var.
# If "replace" is omitted, then "search" is simply deleted.  Thus, in
# the if-statement below, if ${target_dir/${WE2E_basedir}/} returns
# ${target_dir} without changes (in which case the test in the if-statment
# will evaluate to true), it means ${WE2E_basedir} was not found within
# ${target_dir}.  That in turn means ${target_dir} is not a location
# under ${WE2E_basedir}.  In this case, print out a warning and exit.
#
        if [ "${target_dir}" = "${target_dir/${WE2E_basedir}/}" ]; then
          cwd="$(pwd)"
          print_err_msg_exit "\
The symlink (crnt_item) in the current directory (cwd) has a target
(target_fp) located in a directory (target_dir) that is not a subdirectory
under the WE2E tests base directory (WE2E_basedir):
  cwd = \"${cwd}\"
  crnt_item = \"${crnt_item}\"
  target_fn = \"${target_fn}\"
  target_dir   = \"${target_dir}\"
  WE2E_basedir = \"${WE2E_basedir}\"
This is not allowed because the subdirectories under WE2E_basedir represent
each of the WE2E test categories, and every such test must fall into one
of these categories.  Please either move the target to one of the
subdirectories under WE2E_basedir or remove the symlink, then rerun."
        fi
#
# Finally, check whether the name of the target file is in the expected
# format "config.${test_name}.sh" for a WE2E test base configuration file.
# If not, print out a warning and exit.
#
        target_fn=$( basename "${target_fp}" )
        target_test_name_or_null=$( printf "%s\n" "${target_fn}" | \
                                    sed -n -r -e "s/${regex_search}/\1/p" )
        if [ -z "${target_test_name_or_null}" ]; then
          cwd="$(pwd)"
          print_err_msg_exit "\
The symlink (crnt_item) in the current directory (cwd) has a target
(target_fn; located in the directory target_dir) with a name that is not
in the form \"config.[test_name].sh\" expected for a WE2E base configuration
file:
  cwd = \"${cwd}\"
  crnt_item = \"${crnt_item}\"
  target_dir = \"${target_dir}\"
  target_fn = \"${target_fn}\"
Please either rename the target to have the form specified above or remove
the symlink, then rerun."
        fi
#
# Now that all the checks above have succeeded, save the name of the WE2E
# test that the target represents in the array WE2E_symlinked_test_target_test_names
# for later use.
#
        WE2E_symlinked_test_target_test_names+=("${target_test_name_or_null}")
#
#-----------------------------------------------------------------------
#
# If the current item is not a symlink, then check if it is a "regular"
# file.  In this context, we are really checking to ensure that the item
# is not a directory.  If it is a regular file (and thus not a directory),
# save the corresponding WE2E test name and the subdirectory (under the
# WE2E tests base directory) in which it is located in the arrays
# WE2E_test_names and WE2E_subdirs, respectively.  Otherwise, print out
# a warning and exit.
#
#-----------------------------------------------------------------------
#
      else

        if [ -f "${crnt_item}" ]; then
          WE2E_test_names+=("${test_name_or_null}")
          WE2E_test_subdirs+=("${subdir}")
        else
          cwd="$(pwd)"
          print_err_msg_exit "\
The item (crnt_item) in the current directory (cwd) is not a symlink,
but it is also not a regular file (i.e. it fails bash's -f conditional
operator):
  cwd = \"${cwd}\"
  crnt_item = \"${crnt_item}\"
  [ -f "${crnt_item}" ] = $([ -f "${crnt_item}" ])
This is probably because it is a directory, but it must be a file (more
specifically, it must be a WE2E test base configuration file).  Please
correct and rerun."
        fi

      fi

    fi

  done

done

echo
echo "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
printf "%s\n" "${WE2E_symlinked_test_names[@]}"
echo
echo "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
printf "%s\n" "${WE2E_symlinked_test_subdirs[@]}"
#exit
#
#-----------------------------------------------------------------------
#
# Loop over all the non-symlinked WE2E tests found above and make sure
# that the base configuration file corresponding to each test occurs
# only once in the directory tree under the WE2E tests base directory
# (WE2E_basedir).  In other words, a WE2E test with a given name may
# occur only once in the set of all such tests gathered from all the
# subdirectories under WE2E_basedir (including directly under that
# directory).
#
#-----------------------------------------------------------------------
#
num_WE2E_tests="${#WE2E_test_names[@]}"
for (( i=0; i<=$((num_WE2E_tests-1)); i++ )); do

  test_name="${WE2E_test_names[$i]}"
  subdirs=("${WE2E_test_subdirs[$i]}")

  num_occurrences=1
  for (( j=0; j<=$((num_WE2E_tests-1)); j++ )); do
    if [ "$j" -ne "$i" ]; then
      if [ "${WE2E_test_names[$j]}" = "${test_name}" ]; then
        num_occurrences=$((num_occurrences+1))
        subdirs+=("${WE2E_test_subdirs[$j]}")
      fi
    fi
  done

  if [ "${num_occurrences}" -gt 1 ]; then
    print_err_msg_exit "\
The current test (test_name) exists in more than one subdirectory under
the WE2E tests base directory (WE2E_basedir):
  test_name = \"${test_name}\"
  WE2E_basedir = \"${WE2E_basedir}\"
The subdirectories in which this test is found are:
  subdirs = ( $( printf "\"%s\" " "${subdirs[@]}" ))
Please rename the various occurrences of this test so that they have
distinct names and rerun."
  fi

done
#
#-----------------------------------------------------------------------
#
# Loop through all the non-symlinked tests and get their descriptions
# from the configuration files.  These descriptions are included as
# headers in the configuration files.
#
#-----------------------------------------------------------------------
#
for (( i=0; i<=$((num_WE2E_tests-1)); i++ )); do

  test_name="${WE2E_test_names[$i]}"
  subdir=("${WE2E_test_subdirs[$i]}")
  cd_vrfy "${WE2E_basedir}/$subdir"

  config_fn="config.${test_name}.sh"
  test_desc=""
  while { read -r line; } && [ "${line:0:1}" = "#" ]; do
    test_desc="\
${test_desc}$line
"
  done < "${config_fn}"
#
# Remove trailing newline from test_desc.
#
  if [ ! -z "${test_desc}" ]; then
    test_desc="${test_desc:0:-1}"
  fi
#
# Save the test description in the array WE2E_test_descs.
#
  WE2E_test_descs+=("${test_desc}")

done
#
#-----------------------------------------------------------------------
#
# Loop over all the symlinked WE2E tests found above.  For each such
# test, find the name of the test that the target of the symlinked test
# represents.  Then append to the element in the array WE2E_test_names
# (which contains the names of the non-symlinked tests) corresponding
# to the target test the name of the symlink test.  Similarly, append to
# the element in WE2E_test_subdirs (which contains the names of the
# subdirectories under WE2E_basedir in which the non-symlinked tests
# are located) corresponding to the target test the name of the subdirectory
# in which the symlinked test is located.
#
#-----------------------------------------------------------------------
#
#WE2E_test_names[0]="abc  def  ghi"
#set -x
#WE2E_test_names_str="( "$( printf "\"%s\" " "${WE2E_test_names[@]}" )" )"
#eval WE2E_test_names_orig=${WE2E_test_names_str}
#
# Should all array assignments in the workflow be done in this way?
#
WE2E_test_names_orig=( "${WE2E_test_names[@]}" )

num_symlinked_tests="${#WE2E_symlinked_test_names[@]}"
for (( i=0; i<=$((num_symlinked_tests-1)); i++ )); do

  symlinked_test_name="${WE2E_symlinked_test_names[$i]}"
  symlinked_test_subdir=("${WE2E_symlinked_test_subdirs[$i]}")
  target_test_name="${WE2E_symlinked_test_target_test_names[$i]}"

  num_occurrences=0
  for (( j=0; j<=$((num_WE2E_tests-1)); j++ )); do
    if [ "${WE2E_test_names_orig[$j]}" = "${target_test_name}" ]; then
      WE2E_test_names[$j]="${WE2E_test_names[$j]} | ${symlinked_test_name}"
      WE2E_test_subdirs[$j]="${WE2E_test_subdirs[$j]} | ${symlinked_test_subdir}"
      num_occurrences=$((num_occurrences+1))
    fi
  done

  if [ "${num_occurrences}" -ne 1 ]; then
    print_err_msg_exit "\
The current symlinked test (symlinked_test_name) has a target test
(target_test_name) that does not exist in the list of actual WE2E tests:
  symlinked_test_name = \"${symlinked_test_name}\"
  target_test_name = \"${target_test_name}\"
Please correct and rerun."
  fi

done



echo
echo "GGGGGGGGGGGGGGGGGGGGGGGGGG"
printf "%s\n" "${WE2E_test_names[@]}"
echo
echo "HHHHHHHHHHHHHHHHHHHHHHHHHH"
printf "%s\n" "${WE2E_test_subdirs[@]}"
##
##-----------------------------------------------------------------------
##
##
##
##-----------------------------------------------------------------------
##
#tests_to_run=( "dummy01" "dummy02" "regional_001" )
##tests_to_run=( "dummy01" "dummy02" "regional_001" "regional_001" "DOT_OR_USCORE" )
#
#inds_tests_to_run=()
#num_tests_to_run="${#tests_to_run[@]}"
#for (( i=0; i<=$((num_tests_to_run-1)); i++ )); do
#
#  test_to_run="${tests_to_run[$i]}"
#
#  regex_search="[ ]*\|[ ]*"
#  regex_replace=" "
#  for (( j=0; j<=$((num_WE2E_tests-1)); j++ )); do
#
#    primary_test_name_and_alts=$( \
#      printf "%s\n" "${WE2E_test_names[$j]}" | \
#      sed -r -e "s/${regex_search}/${regex_replace}/g" )
#    eval primary_test_name_and_alts=( ${primary_test_name_and_alts} )
#
#    is_element_of "primary_test_name_and_alts" "${test_to_run}" && {
#
#      is_element_of "inds_tests_to_run" "$j" && {
#        primary_test_name_and_alts_str=$(printf "\"%s\" " "${primary_test_name_and_alts[@]}")
#        print_err_msg_exit "\
#The specified test to run (test_to_run) already exists in the list of
#tests to run, either under the same name or an alternate name:
#  test_to_run = \"${test_to_run}\"
#This test has the following primary and possibly one or more alternate
#names:
#  ${primary_test_name_and_alts_str}
#The first item in this list is the primary test name, and the second,
#third, etc are the alternate names.  In order to not repeat the same
#WE2E test (and thus waste computational resources), only one of these
#test names can be specified in the list of tests to run.  Please modify
#the list accordingly and retry."
#      }
#
#      inds_tests_to_run+=("$j")
#      break
#
#    }
#
#  done
#
#done
#
#echo
#echo "KKKKKKKKKKKKKKKKK"
#echo "inds_tests_to_run = ${inds_tests_to_run[@]}"
#echo
#echo "LLLLLLLLLLLLLLLLL"
##exit

}


#get_WE2Etest_names_subdirs_descs "$@"





