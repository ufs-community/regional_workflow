#!/bin/ksh -l

COMMAND=$1

#############################################################
# load modulefile and set up the environment for job runnning
#############################################################

MODULEFILES=${MODULEFILES:-/gpfs/dell2/emc/modeling/noscrub/${USER}/fv3sar_workflow/modulefiles}

if [ "$machine" = "DELL" ] ; then
  . /usrx/local/prod/lmod/lmod/init/sh
  module use ${MODULEFILES}/wcoss_dell_p3
  module load fv3
  module load prod_util/1.1.0

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
