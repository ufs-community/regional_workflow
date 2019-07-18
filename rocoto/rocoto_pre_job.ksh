#! /bin/sh --login
set -x -u -e
date

. ${HOMEfv3}/rocoto/machine-setup.sh
export MACHINE=${target}

if [ "$MACHINE" = "wcoss_dell_p3" ] ; then
  . /usrx/local/prod/lmod/lmod/init/sh
elif [ "$MACHINE" = "wcoss_cray" ] ; then
  . /opt/modules/default/init/sh
elif [ "$MACHINE" = "theia" ] ; then
  . /apps/lmod/lmod/init/sh
elif [ "$MACHINE" = "jet" ] ; then
  . /apps/lmod/lmod/init/sh
fi

module use ${HOMEfv3}/modulefiles/${MACHINE}
module load regional
module list

exec "$@"
