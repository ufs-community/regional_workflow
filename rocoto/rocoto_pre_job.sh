#!/bin/sh --login
set -x -u -e
date

. ${HOMEfv3}/rocoto/machine-setup.sh
export machine=${target}

if [ "$machine" = "wcoss_dell_p3" ] ; then
  . /usrx/local/prod/lmod/lmod/init/sh
elif [ "$machine" = "wcoss_cray" ] ; then
  . /opt/modules/default/init/sh
elif [ "$machine" = "hera" ] ; then
  . /apps/lmod/lmod/init/sh
elif [ "$machine" = "theia" ] ; then
  . /apps/lmod/lmod/init/sh
elif [ "$machine" = "jet" ] ; then
  . /apps/lmod/lmod/init/sh
fi

module use ${HOMEfv3}/modulefiles/${machine}
jobpre=$(echo ${job} | cut -c1-17)
if [ "${jobpre}" = "regional_forecast" ]; then
  module load fv3
else
  module load regional
fi
module list

exec "$@"
