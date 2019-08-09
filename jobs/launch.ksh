#!/bin/ksh -l

COMMAND=$1

############################################################
# load modulefile and set up the environment for job running
############################################################


if [ "$machine" = "DELL" ] ; then
  . /usrx/local/prod/lmod/lmod/init/sh
  MODULEFILES=${MODULEFILES:-/gpfs/dell2/emc/modeling/noscrub/${USER}/regional_workflow/modulefiles}
  module use ${MODULEFILES}/wcoss_dell_p3
  module load fv3
  module load prod_util/1.1.0
  module load grib_util/1.0.6
  module load CFP/2.0.1
  module load HPSS/5.0.2.5

elif [ "$machine" = "THEIA" ] ; then
  . /apps/lmod/7.7.18/init/sh
  MODULEFILES=${MODULEFILES:-/scratch4/NCEPDEV/fv3-cam/noscrub/${USER}/regional_workflow/modulefiles}
  echo MODULEFILES is $MODULEFILES
  module use ${MODULEFILES}/theia
  module load fv3
  module load global_chgres
  module load prod_util/1.1.0
  module load grib_util/1.0.6
  module load HPSS/5.0.2.5
  module load netcdf/4.3.0
  module load hdf5/1.8.14

  echo in launch.ksh
  module list
else
  echo "launch.ksh: modulefile is not set up yet for this machine-->${machine}."
  echo "Job abort!"
  exit 1
fi

# print out loaded modules
module list

############################################################
#                                                          #
#    define the name of running directory with job name.   #
#        (NCO: only data.${jobid})                         #
#                                                          #
############################################################
#if [ -n ${rundir_task} ] ; then
#  export DATA=${rundir_task}.${jid}
#fi

$COMMAND
