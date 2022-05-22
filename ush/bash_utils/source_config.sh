#
#-----------------------------------------------------------------------
# This file defines function that sources a config file (yaml/json etc)
# into the calling shell script
#-----------------------------------------------------------------------
#

function config_to_str() {
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
  local scrfunc_fp=$( $READLINK -f "${BASH_SOURCE[0]}" )
  local scrfunc_fn=$( basename "${scrfunc_fp}" )
  local scrfunc_dir=$( dirname "${scrfunc_fp}" )

#
#-----------------------------------------------------------------------
# Source the config file
#-----------------------------------------------------------------------
#
  local ushdir=${scrfunc_dir%/*}

  cd $ushdir
  if [ $# -eq 1 ]; then
    python3 -W ignore -m python_utils.config_parser -c $1 -o shell -f
  else
    python3 -W ignore -m python_utils.config_parser -c $1 -o shell -f --keys "${@: 2}"
  fi
  cd $scrfunc_dir

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

function source_config() {

  source <( config_to_str "$@" )

}

