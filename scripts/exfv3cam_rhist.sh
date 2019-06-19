#!/bin/ksh 
 
####################################################################

cd $DATA

#####################################################################
#
# RUNHISTORY JOB
#
# This job uses script rhist_savedir.sh to tar up and save a specified
# operational directory in the appropriate directory under /hsmprod
# on the HPSS server, ncos70a.
#
# Directories /nwprod and /com/eta will be tarred first and saved under 
# the previous day (day minus 1).  Then, data from day minus 2 will be
# saved.
#
#####################################################################

########################################
set -x
msg="JOB $job HAS BEGUN"
postmsg "$jlogfile" "$msg"
##########################################

# Run setpdy and initialize PDY variables
errsum=0

   case $job in

   jrun_history00_${RUN})

      $USHfv3/rhist_save${model}.sh ${COMOUT} ${PDY}00
      export err=$?;let errsum=errsum+err;$USHfv3/rhist_errchk.sh fv3 00
      ;;

#   jrun_history12_fv3sar)

#      $USHfv3/rhist_savefv3sar.sh /gpfs/dell2/ptmp/Eric.Rogers/com/fv3sar/para/fv3sar.${PDY}/12 ${PDY}12
#      export err=$?;let errsum=errsum+err;$USHfv3/rhist_errchk.sh fv3 12     
#      ;;

   *)
      echo " Job=$job not recognized by script exrunhist.sh.ecf." 
      ;;
   esac

#
#  check if any the tarfiles were missed, and abort if so.
#
err=$errsum; err_chk

#####################################################################

# GOOD RUN
set +x
echo "**************JOB RHIST COMPLETED NORMALLY ON THE IBM"
echo "**************JOB RHIST COMPLETED NORMALLY ON THE IBM"
echo "**************JOB RHIST COMPLETED NORMALLY ON THE IBM"
set -x

msg="JOB $job HAS COMPLETED NORMALLY."
echo $msg
postmsg "$jlogfile" "$msg"

############## END OF SCRIPT #######################
