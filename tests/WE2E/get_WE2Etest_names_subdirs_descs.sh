#!/bin/bash

#
#-----------------------------------------------------------------------
#
# This file defines a function that searches the base directory containing 
# the WE2E test workflow configuration files as well as a set of 
# subdirectories under this base directory for all such configuration 
# files in order to compile (and return to the calling script or function) 
# information about these tests.  The base diretory is specified by the 
# input argument 
#
#   WE2E_test_config_basedir
#
# and the set of subdirectories (which we refer to here as category 
# subdirectories because they are used to group the tests into categories 
# for clarity) are specified by the input array argument
#
#   WE2E_category_subdirs
#
# This function assumes that any file or symlink with a name of the form
#
#   config.${test_name}.sh
#
# is a test configuration file, and it takes the name of the test to be
# given by whatever test_name in the above name happens to be.
#
# For each configuration file (which may be a regular file or a symlink)
# having a name of the form specified above, this function saves in the 
# arrays with names specified by the input arguments
#
#   output_varname_WE2E_test_names
#   output_varname_WE2E_test_subdirs
#   output_varname_WE2E_test_descs
#
# the list of all WE2E test names (including alternate test names, which
# are test names derived from symlinks pointing to regular test 
# configuration files), the category subdirectories in which the test
# configuration files are located (including the subdirectories of the
# symlinks that point to the primary test configuration file, if any), 
# and the test descriptions.  
#
# If the input argument generate_csv_file is set to "TRUE", this function 
# also generates a CSV (comma-separated value) file containing the all 
# information about the WE2E tests that can be read into a spreadsheet 
# in Google Sheets.  This file is placed in the directory specified by
# the input argument WE2E_basedir.
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
    "WE2E_basedir" \
    "WE2E_test_configs_basedir" \
    "WE2E_category_subdirs" \
    "generate_csv_file" \
    "output_varname_WE2E_test_names" \
    "output_varname_WE2E_test_subdirs" \
    "output_varname_WE2E_test_descs" \
    )
  process_args "valid_args" "$@"
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
#
#-----------------------------------------------------------------------
#
# Declare local variables.
#
#-----------------------------------------------------------------------
#
  local all_items \
        alt_test_names \
        alt_test_names_subdirs \
        alt_test_subdirs \
        column_titles \
        config_fn \
        crnt_item \
        csv_delimiter \
        csv_fn \
        csv_fp \
        cwd \
        delimiter_char \
        delimiter_str \
        hash_or_null \
        i \
        j \
        line \
        num_alt_names \
        num_items \
        num_occurrences \
        num_symlinked_tests \
        num_WE2E_category_subdirs \
        num_WE2E_tests \
        primary_and_alt_test_names \
        primary_and_alt_test_subdirs \
        primary_test_name \
        primary_test_subdir \
        regex_search \
        row_content \
        stripped_line \
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
        WE2E_test_descs_esc_sq \
        WE2E_test_descs_str \
        WE2E_test_names \
        WE2E_test_names_orig \
        WE2E_test_names_str \
        WE2E_test_subdirs \
        WE2E_test_subdirs_str
#
#-----------------------------------------------------------------------
#
# Loop through all category subdirectories under the base directory for
# the WE2E test configuration files.  This base directory is specified
# by WE2E_test_configs_basedir while the subdirectories are specified in
# the array WE2E_category_subdirs.  Note that if one of the elements of
# WE2E_category_subdirs is ".", then one of these "subdirectories" will
# be the base directory itself.
#
# In each category subdirectory, consider all items that have names of
# the form
#
#   config.${test_name}.sh
#
# and that are either files or symlinks to existing files that themselves
# have names of the form above (but not items that are directories or
# other more exotic entities).  For each item that is a file, save the
# corresponding test name and the category subdirectory in which the
# file is located in the arrays
#
#   WE2E_test_names
#   WE2E_test_subdirs
#
# respectively.  For each item that is a symlink to an existing file
# (which itself must have a name of the form above), save the test name
# corresponding to the symlink name (which is considered an alternate
# name for the test; the primary test name is assumed to be the one
# derived from the name of the symlink's target file), the category
# subdirectory in which the symlink is located, and the test name derived
# from the name of the symlink's target (i.e. the primary test name) in
# the arrays
#
#   WE2E_symlinked_test_names
#   WE2E_symlinked_test_subdirs
#   WE2E_symlinked_test_target_test_names
#
# respectively.
#
#-----------------------------------------------------------------------
#
  WE2E_test_names=()
  WE2E_test_subdirs=()

  WE2E_symlinked_test_names=()
  WE2E_symlinked_test_subdirs=()
  WE2E_symlinked_test_target_test_names=()

  num_WE2E_category_subdirs="${#WE2E_category_subdirs[@]}"
  for (( i=0; i<=$((num_WE2E_category_subdirs-1)); i++ )); do

    subdir="${WE2E_category_subdirs[$i]}"
    cd_vrfy "${WE2E_test_configs_basedir}/$subdir"
#
# Get the contents of the current subdirectory.  We consider each item
# that has a name of the form
#
#   config.${test_name}.sh
#
# to be a WE2E test configuration file, and we take the name of the test 
# to be whatever test_name in the above expression corresponds to.  We 
# ignore all other items in the subdirectory.
#
    all_items=( $(ls -1) )
    num_items="${#all_items[@]}"
    for (( j=0; j<=$((num_items-1)); j++ )); do

      crnt_item="${all_items[$j]}"
#
# Try to extract the name of the test from the name of the current item
# and place the result in test_name_or_null.  test_name_or_null will
# contain the name of the test only if the item has a name of the form
# "config.${test_name}.sh", in which case it will be equal to ${test_name}.
# Otherwise, it will be a null string.
#
      regex_search="^config\.(.*)\.sh$"
      test_name_or_null=$( printf "%s\n" "${crnt_item}" | \
                           sed -n -r -e "s/${regex_search}/\1/p" )
#
#-----------------------------------------------------------------------
#
# Take further action for this item only if it has a name of the form
# above expected for a WE2E test configuration file, which will be the
# case only if test_name_or_null is not a null string.
#
#-----------------------------------------------------------------------
#
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
# it to the array WE2E_symlinked_test_names.  Also, append the category
# subdirectory under WE2E_test_configs_basedir in which the symlink is
# located to the array WE2E_symlinked_test_subdirs.
#
          WE2E_symlinked_test_names+=("${test_name_or_null}")
          WE2E_symlinked_test_subdirs+=("$subdir")
#
# Get the full path to the target of the symlink.
#
          target_fp=$( readlink -f "${crnt_item}" )
#
# Now use bash's -f conditional operator to check whether the target is
# a "regular" file (as defined by bash).  Note that this test will return
# false if the target is a directory or does not exist and true otherwise.
# Thus, the negation of this test used on the target (i.e. ! -f) that we
# use below will be true if the target is not an existing file.  In this
# case, we print out an error message and exit.
#
# Note that the -f operator recursively follows symlinks passed to it as
# an argument.  Thus, in the if-statement below, we could have used the
# name of the symlink (crnt_item) instead of the full path to the target
# (target_fp).  However, since below the full path to the target is needed
# for other uses as well, for clarity we simply use it.
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
WE2E test configuration file.  Please either point the symlink to such a 
file or remove it, then rerun."
          fi
#
# Get the name of the directory in which the target (after resolving all
# symlinks in the path) is located.
#
          target_dir=$( dirname "${target_fp}" )
#
# Next, check whether the directory in which the target is located is
# under the base directory of the WE2E test configuration files (i.e.
# WE2E_test_configs_basedir).  We require that the target be located in
# one of the subdirectories under WE2E_test_configs_basedir (or directly
# under WE2E_test_configs_basedir itself) because we don't want to deal
# with tests that may be located anywhere in the file system; we want
# all tests to be placed somewhere under WE2E_test_configs_basedir.
#
# Note that the bash parameter expansion ${var/search/replace} returns
# $var but with the first instance of "search" replaced by "replace" if
# the former is found in $var.  Otherwise, it returns the original $var.
# If "replace" is omitted, then "search" is simply deleted.  Thus, in
# the if-statement below, if ${target_dir/${WE2E_test_configs_basedir}/}
# returns ${target_dir} without changes (in which case the test in the
# if-statment will evaluate to true), it means ${WE2E_test_configs_basedir}
# was not found within ${target_dir}.  That in turn means ${target_dir}
# is not a location under ${WE2E_test_configs_basedir}.  In this case,
# print out a warning and exit.
#
          if [ "${target_dir}" = "${target_dir/${WE2E_test_configs_basedir}/}" ]; then
            cwd="$(pwd)"
            print_err_msg_exit "\
The symlink (crnt_item) in the current directory (cwd) has a target
(target_fp) located in a directory (target_dir) that is not somewhere
under the WE2E tests base directory (WE2E_test_configs_basedir):
  cwd = \"${cwd}\"
  crnt_item = \"${crnt_item}\"
  target_fn = \"${target_fn}\"
  target_dir = \"${target_dir}\"
  WE2E_test_configs_basedir = \"${WE2E_test_configs_basedir}\"
For clarity, we require all WE2E test configuration files to be located 
somewhere under WE2E_test_configs_basedir (either directly in this base 
directory on in a subdirectory).  Please correct and rerun."
          fi
#
# Finally, check whether the name of the target file is in the expected
# format "config.${test_name}.sh" for a WE2E test configuration file.  
# If not, print out a warning and exit.
#
          target_fn=$( basename "${target_fp}" )
          target_test_name_or_null=$( printf "%s\n" "${target_fn}" | \
                                      sed -n -r -e "s/${regex_search}/\1/p" )
          if [ -z "${target_test_name_or_null}" ]; then
            cwd="$(pwd)"
            print_err_msg_exit "\
The symlink (crnt_item) in the current directory (cwd) has a target
(target_fn; located in the directory target_dir) with a name that is
not in the form \"config.[test_name].sh\" expected for a WE2E test
configuration file:
  cwd = \"${cwd}\"
  crnt_item = \"${crnt_item}\"
  target_dir = \"${target_dir}\"
  target_fn = \"${target_fn}\"
Please either rename the target to have the form specified above or
remove the symlink, then rerun."
          fi
#
# Now that all the checks above have succeeded, for later use save the
# name of the WE2E test that the target represents in the array
# WE2E_symlinked_test_target_test_names
#
          WE2E_symlinked_test_target_test_names+=("${target_test_name_or_null}")
#
#-----------------------------------------------------------------------
#
# If the current item is not a symlink...
#
#-----------------------------------------------------------------------
#
        else
#
# Check if the current item is a "regular" file.  In this context, we
# are really checking to ensure that the item is not a directory.  If it
# is a regular file (and thus not a directory), save the corresponding
# WE2E test name and the subdirectory under the WE2E tests base directory
# in which it is located (which may be the base directory itself, i.e.
# ".") in the arrays WE2E_test_names and WE2E_subdirs, respectively.
# Otherwise, print out a warning and exit.
#
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
specifically, it must be a WE2E test configuration file).  Please correct 
and rerun."
          fi

        fi

      fi

    done

  done
#
#-----------------------------------------------------------------------
#
# Loop over all the non-symlinked WE2E tests found above and make sure
# that the test configuration file corresponding to each test is found
# only once in the directory tree under the base directory of the WE2E
# test configuration files (WE2E_test_configs_basedir).  In other words,
# there cannot be two or more tests with the same name in the category
# subdirectories under WE2E_test_configs_basedir (including directly
# under that base directory).
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
the WE2E test configuration files base directory (WE2E_test_configs_basedir):
  test_name = \"${test_name}\"
  WE2E_test_configs_basedir = \"${WE2E_test_configs_basedir}\"
The subdirectories in which this test is found are:
  subdirs = ( $( printf "\"%s\" " "${subdirs[@]}" ))
Please rename the various occurrences of this test so that they have
distinct names and rerun."
    fi

  done
#
#-----------------------------------------------------------------------
#
# Loop through all the WE2E tests with test configuration files that are
# regular files (i.e. not symlinks).  For each such test, extract the
# test purpose/description [which is assumed to be a section of (bash)
# comments at the top of the configuration file] and save it in the array
# WE2E_test_descs.  Note that we assume the first non-commented line at
# the top of the configuration file indicates the end of the comment.
#
#-----------------------------------------------------------------------
#
  WE2E_test_descs=()

  for (( i=0; i<=$((num_WE2E_tests-1)); i++ )); do

    test_name="${WE2E_test_names[$i]}"
    subdir=("${WE2E_test_subdirs[$i]}")
    cd_vrfy "${WE2E_test_configs_basedir}/$subdir"
#
# Keep reading lines from the current test's configuration line until
# a line is encountered that does not start with zero or more spaces,
# followed by the hash symbol (which is the bash comment character)
# possibly followed by a single space character.
#
# In the while-loop below, we read in every such line, strip it of any
# leading spaces, the hash symbol, and possibly another space and append
# what remains to the local variable test_desc.
#
    config_fn="config.${test_name}.sh"
    test_desc=""
    while read -r line; do

      regex_search="^[ ]*(#)([ ]{0,1})(.*)"
      hash_or_null=$( printf "%s" "${line}" | \
                      sed -n -r -e "s/${regex_search}/\1/p" )
#
# If the current line is part of the file header containing the test
# description, then...
#
      if [ "${hash_or_null}" = "#" ]; then
#
# Strip from the current line any leading whitespace followed by the
# hash symbol possibly followed by a single space.  If what remains is
# empty, it means there are no comments on that line and it is just a
# separator line.  In that case, simply add a newline to test_desc.
# Otherwise, append what remains after stripping to what test_desc
# already contains, followed by a single space in preparation for
# appending the next (stripped) line.
#
        stripped_line=$( printf "%s" "${line}" | \
                         sed -n -r -e "s/${regex_search}/\3/p" )
        if [ -z "${stripped_line}" ]; then
          test_desc="\
${test_desc}

"
        else
          test_desc="\
${test_desc}${stripped_line} "
        fi
#
# If the current line is not part of the file header containing the test
# description, break out of the while-loop (and thus stop reading the
# file).
#
      else
        break
      fi

    done < "${config_fn}"
#
# At this point, test_desc contains a description of the current test.
# Note that:
#
# 1) It will be empty if the configuration file for the current test 
#    does not contain a header describing the test.
# 2) It will contain newlines if the description header contained lines
#    that start with the hash symbol and contain no other characters.
#    These are used to delimit paragraphs within the description.
# 3) It may contain leading and trailing whitespace.
#
# Next, for clarity, we remove any leading and trailing whitespace using
# bash's pattern matching syntax.
#
# Note that the right-hand sides of the following two lines are NOT
# regular expressions.  They are expressions that use bash's pattern
# matching syntax (gnu.org/software/bash/manual/html_node/Pattern-Matching.html,
# wiki.bash-hackers.org/syntax/pattern) used in substring removal
# (tldp.org/LDP/abs/html/string-manipulation.html).  For example,
#
#   ${var%%[![:space:]]*}
#
# says "remove from var its longest substring that starts with a non-
# space character".
#
# First remove leading whitespace.
#
    test_desc="${test_desc#"${test_desc%%[![:space:]]*}"}"
#
# Now remove trailing whitespace.
#
    test_desc="${test_desc%"${test_desc##*[![:space:]]}"}"
#
# Finally, save the description of the current test as the next element
# of the array WE2E_test_descs.
#
    WE2E_test_descs+=("${test_desc}")

  done
#
#-----------------------------------------------------------------------
#
# Loop over all tests whose workflow configuration "files" are in fact 
# symlinks having targets are actual files (i.e. not symlinks).  For 
# brevity, here we will refer to the former as symlinked tests.  We
# consider the test name derived from the target name as the primary
# test name, and we consider the test name derived from the symlink name
# as an alternate test name.  For each symlinked test found above (and
# saved in WE2E_symlinked_test_names), we find the element in the array
# WE2E_test_names that is identical to the primary test name corresponding
# to the symlinked test and append to that element the name of the
# symlinked test (preceded by a delimiter string).  These appended names
# represent the alternate names for the test.  (A given test with a
# primary name in WE2E_test_names may have zero or more alternate names.)
# Similarly, we append the category subdirectory in which the symlinked
# test is located to the element in WE2E_test_subdirs containing the
# subdirectory in which the target of the symlink is located (i.e. the
# subdirectory in which the primary test configuration file is found),
# preceded by a delimiter string.  Here, we use the string ", " as the
# delimiter.
#
# As an example, the final result for the array WE2E_test_names may be
# something like the following:
#
#   WE2E_test_names[0]="test1"
#   WE2E_test_names[1]="test2, test2_alt_name1, test2_alt_name2"
#   WE2E_test_names[2]="test3"
#   WE2E_test_names[3]="test4, test4_alt_name1"
#   ...
#
# Similarly, the final result for WE2E_test_subdirs may be something
# like the following:
#
#   WE2E_test_subdirs[0]="subdirA"
#   WE2E_test_subdirs[1]="subdirB, subdirA, subdirC"
#   WE2E_test_subdirs[2]="subdirD"
#   WE2E_test_subdirs[3]="subdirE, subdirB"
#   ...
#
# This means that:
#
# * config.test1.sh is an actual file in subdirA.
# * config.test2.sh is an actual file in subdirB.
# * config.test2_alt_name1.sh is a symlink in subdirA that points to
#   config.test2.sh in subdirB.
# * config.test2_alt_name2.sh is a symlink in subdirC that points to
#   config.test2.sh in subdirB.
# * config.test3.sh is an actual file in subdirD.
# * config.test4.sh is an actual file in subdirE.
# * config.test4_alt_name1.sh is a symlink in subdirB that points to
#   config.test4.sh in subdirE.
#
# Thus, after the code below executes, the arrays WE2E_test_names and
# WE2E_test_subdirs will contain information about all primary test
# names, all alternate test names, and the subdirectories in which the
# configuration files/symlinks corresponding to the primary/alternate
# test names are located.
#
#-----------------------------------------------------------------------
#
  delimiter_char=","
  delimiter_str="${delimiter_char} "
  WE2E_test_names_orig=( "${WE2E_test_names[@]}" )

  num_symlinked_tests="${#WE2E_symlinked_test_names[@]}"
  for (( i=0; i<=$((num_symlinked_tests-1)); i++ )); do

    symlinked_test_name="${WE2E_symlinked_test_names[$i]}"
    symlinked_test_subdir=("${WE2E_symlinked_test_subdirs[$i]}")
    target_test_name="${WE2E_symlinked_test_target_test_names[$i]}"

    num_occurrences=0
    for (( j=0; j<=$((num_WE2E_tests-1)); j++ )); do
      if [ "${WE2E_test_names_orig[$j]}" = "${target_test_name}" ]; then
        WE2E_test_names[$j]="${WE2E_test_names[$j]}${delimiter_str}${symlinked_test_name}"
        WE2E_test_subdirs[$j]="${WE2E_test_subdirs[$j]}${delimiter_str}${symlinked_test_subdir}"
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
#
#-----------------------------------------------------------------------
#
# If generate_csv_file is set to "TRUE", generate a CSV (comma-separated
# value) file containing information about the WE2E tests.  This file
# can be opened in a spreadsheet in Google Sheets (and maybe Excel) to
# view information about all the tests.
#
#-----------------------------------------------------------------------
#
  if [ "${generate_csv_file}" = "TRUE" ]; then

    csv_fn="WE2E_test_info.csv"
    csv_fp="${WE2E_basedir}/${csv_fn}"
    rm_vrfy -f "${csv_fp}"

    csv_delimiter="|"
    column_titles="\
\"Test Name (Subdirectory)\" ${csv_delimiter} \
\"Alternate Test Names (Subdirectories)\" ${csv_delimiter} \
\"Test Purpose/Description\""
    printf "%s\n" "${column_titles}" >> "${csv_fp}"

    for (( i=0; i<=$((num_WE2E_tests-1)); i++ )); do
#
# Get the primary test name and alternate test names (if any) of the
# current test.  Note that the variable containing the alternate test
# names will be an array (an empty one if the test has no alternate
# names).
#
      primary_and_alt_test_names="${WE2E_test_names[$i]}"

      regex_search="^[ ]*([^ ${delimiter_char}]*).*"
      primary_test_name=$( printf "%s" "${primary_and_alt_test_names}" | \
                           sed -n -r -e "s/${regex_search}/\1/p" )

      regex_search="^[ ]*([^ ${delimiter_char}]*)[ ]*${delimiter_char}[ ]*(.*)"
      alt_test_names=$( printf "%s" "${primary_and_alt_test_names}" | \
                        sed -n -r -e "s/${regex_search}/\2/p" )
      alt_test_names=( $( printf "%s" "${alt_primary_and_alt_test_names}" | \
                          sed -r -e "s/${delimiter_char}/ /g" ) )
#
# Get the category subdirectories in which the configuration file
# corresponding to the primary test name as well as the category
# subdirectories in which the configuration symlinks corresponding to
# the alternate test names are located (which for brevity we refer to as
# the alternate subdirectories).  Note that the variable containing the
# alternate subdirectories will be an array (an empty one if the test
# has no alternate names).
#
      primary_and_alt_test_subdirs="${WE2E_test_subdirs[$i]}"

      regex_search="^[ ]*([^ ${delimiter_char}]*).*"
      primary_test_subdir=$( printf "%s" "${primary_and_alt_test_subdirs}" | \
                             sed -n -r -e "s/${regex_search}/\1/p" )

      regex_search="^[ ]*([^ ${delimiter_char}]*)[ ]*${delimiter_char}[ ]*(.*)"
      alt_test_subdirs=$( printf "%s" "${primary_and_alt_test_subdirs}" | \
                          sed -n -r -e "s/${regex_search}/\2/p" )
      alt_test_subdirs=( $( printf "%s" "${alt_primary_and_alt_test_subdirs}" | \
                            sed -r -e "s/${delimiter_char}/ /g" ) )
#
# Loop through all the alternate names of the current test.  Save on
# separate lines in the variable alt_test_names_subdirs each alternate
# name followed by the corresponding subdirectory (in parentheses).
# We save each such set on a separate line in alt_test_names_subdirs
# because we want each to appear on a separate line of the same cell in
# the spreadsheet.
#
      alt_test_names_subdirs=""
      num_alt_names="${#alt_test_names[@]}"
      for (( j=0; j<=$((num_alt_names-1)); j++ )); do
        alt_test_names_subdirs="\
${alt_test_names_subdirs}
${alt_test_names[$j]} (${alt_test_subdirs[$j]})"
      done
#
# Get the test description.
#
      test_desc="${WE2E_test_descs[$i]}"
#
# Replace any double-quotes in the test description with two double-quotes
# since this is the way a double-quote is escaped in a CSV file, at least
# a CSV file that is read in by Google Sheets.
#
      test_desc=$( printf "%s" "${test_desc}" | sed -r -e "s/\"/\"\"/g" )
#
# Write a line to the CSV file representing a single row of the spreadsheet.  
# This row contains the following columns:
#
# Column 1: 
# The primary test name followed by the category subdirectory it is 
# located in (the latter in parentheses).
#
# Column 2:
# The alternate test names (if any) followed by their subdirectories 
# (in parentheses).
#
# Column 3: 
# The test purpose/description.
#
      row_content="\
\"${primary_test_name} (${primary_test_subdir})\" ${csv_delimiter} \
\"${alt_test_names_subdirs}\" ${csv_delimiter} \
\"${test_desc}\""
      printf "%s\n" "${row_content}" >> "${csv_fp}"

    done

  fi
#
#-----------------------------------------------------------------------
#
# Use the eval function to set this function's output variables.  Note
# that each of these is set only if the corresponding input variable
# specifying the name to use for the output variable is not empty.
#
#-----------------------------------------------------------------------
#
  if [ ! -z "${output_varname_WE2E_test_names}" ]; then
    WE2E_test_names_str="( "$( printf "\"%s\" " "${WE2E_test_names[@]}" )")"
    eval ${output_varname_WE2E_test_names}="${WE2E_test_names_str}"
  fi

  if [ ! -z "${output_varname_WE2E_test_subdirs}" ]; then
    WE2E_test_subdirs_str="( "$( printf "\"%s\" " "${WE2E_test_subdirs[@]}" )")"
    eval ${output_varname_WE2E_test_subdirs}="${WE2E_test_subdirs_str}"
  fi

  if [ ! -z "${output_varname_WE2E_test_descs}" ]; then
#
# We want to treat all characters in the test descriptions literally
# when evaluating the array specified by output_varname_WE2E_test_descs
# below using the eval function because otherwise, characters such as
# "$", "(", ")", etc will be interpreted as indicating the value of a
# variable, the start of an array, the end of an array, etc, and lead to
# errors.  Thus, below, when forming the array that will be passed to
# eval, we will surround each element of the local array WE2E_test_descs
# in single quotes.  However, the test descriptions themselves may
# include single quotes (e.g. when a description contains a phrase such
# as "Please see the User's Guide for...").  In order to treat these
# single quotes literally (as opposed to as delimiters indicating the
# start or end of array elements), we have to pass them as separate
# strings by replacing each single quote with the following series of
# characters:
#
#   '"'"'
#
# In this, the first single quote indicates the end of the previous
# single-quoted string, the "'" indicates a string containing a literal
# single quote, and the last single quote inidicates the start of the
# next single-quoted string.
#
# For example, let's assume there are only two WE2E tests to consider.
# Assume the description of the first is
#
#   Please see the User's Guide.
#
# and that of the second is:
#
#   See description of ${DOT_OR_USCORE} in the configuration file.
#
# Then, if output_varname_WE2E_test_descs is set to "some_array", the
# exact string we want to pass to eval is:
#
#   some_array=('Please see the User'"'"'s Guide.' 'See description of ${DOT_OR_USCORE} in the configuration file.')
#
    WE2E_test_descs_esc_sq=()
    for (( i=0; i<=$((num_WE2E_tests-1)); i++ )); do
      WE2E_test_descs_esc_sq[$i]=$( printf "%s" "${WE2E_test_descs[$i]}" | \
                                    sed -r -e "s/'/'\"'\"'/g" )
    done
    WE2E_test_descs_str="( "$( printf "'%s' " "${WE2E_test_descs_esc_sq[@]}" )")"
    eval ${output_varname_WE2E_test_descs}="${WE2E_test_descs_str}"
  fi
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/function.
#
#-----------------------------------------------------------------------
#
  { restore_shell_opts; } > /dev/null 2>&1

}

