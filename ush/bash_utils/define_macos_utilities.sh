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
    command -v $SED >/dev/null 2>&1 || { echo >&2 "For Darwin-based operating systems (MacOS), the `$SED` utility is required to run the UFS SRW Application. Reference the User's Guide for more information about platform requirements. Aborting."; exit 1; }
    command -v $READLINK >/dev/null 2>&1 || { echo >&2 "For Darwin-based operating systems (MacOS), the `$READLINK` utility is required to run the UFS SRW Application. Reference the User's Guide for more information about platform requirements. Aborting."; exit 1; }
  else
    export READLINK=readlink
    export SED=sed
  fi

