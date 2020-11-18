#
#-----------------------------------------------------------------------
#
# This script defines MacOS-specific UNIX command-line utilities that 
# mimic the functionality of the GNU equivalents.
#
#-----------------------------------------------------------------------
#
#
#
#-----------------------------------------------------------------------
#
# Check if we are on a Darwin machine; if so we need to use the gnu-like
# equivalent of readlink and sed.
#
#-----------------------------------------------------------------------
#
  if [[ $(uname -s) == Darwin ]]; then
    export READLINK=greadlink
    export SED=gsed
  else
    export READLINK=readlink
    export SED=sed
  fi

