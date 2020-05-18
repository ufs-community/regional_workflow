#! /usr/bin/env bash
set -eux

source ./machine-setup.sh > /dev/null 2>&1
cwd=`pwd`

USE_PREINST_LIBS=${USE_PREINST_LIBS:-"true"}
if [ $USE_PREINST_LIBS = true ]; then
  export MOD_PATH=/scratch3/NCEPDEV/nwprod/lib/modulefiles
else
  export MOD_PATH=${cwd}/lib/modulefiles
fi

# Check final exec folder exists
if [ ! -d "../exec" ]; then
  mkdir ../exec
fi

cd EMC_post

if [ "$target" = "jet" ] ; then
  ./compile jet
elif [ "$target" = "hera" ] ; then
  ./compile hera
elif [ "$target" = "wcoss_cray" ] ; then
  ./compile wcross_cray
elif [ "$target" = "wcoss_dell_p3" ] ; then
  ./compile wcoss_dell_p3
elif [ "$target" = "wcoss" ] ; then
  ./compile wcoss
elif [ "$target" = "cheyenne" ] ; then
  #Definitely need to make this bit machine-agnostic in the future...
  . /glade/u/apps/ch/opt/lmod/8.1.7/lmod/8.1.7/init/sh
  moduledir=$(readlink -f ../../modulefiles/)
  module use $moduledir
  module load cheyenne.default
  ./configure << EOT
4
EOT
  ./compile
elif [ "$target" = "gaea" ] ; then
    echo "Not doing anything for 'gaea', if statement reserved for future use"
elif [ "$target" = "odin" ] ; then
    echo "Not doing anything for 'odin', if statement reserved for future use"
else
    echo WARNING: UNKNOWN PLATFORM 1>&2
fi
