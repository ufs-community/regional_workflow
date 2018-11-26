#!/bin/sh
#

model=$1
cyc=$2
pgm=$model$cyc

set +x
if test "$err" -ne '0'
then
  echo "*******************************************************"
  echo "******  PROBLEM ARCHIVING $pgm RETURN CODE $err  ******"
  echo "*******************************************************"
  msg1="PROBLEM ARCHIVING $pgm RETURN CODE $err"
  sh postmsg "$jlogfile" "$msg1"
else
  echo " --------------------------------------------- "
  echo " ********** COMPLETED ARCHIVE $pgm  **********"
  echo " --------------------------------------------- "
  msg="ARCHIVE of $pgm COMPLETED NORMALLY"
  sh postmsg "$jlogfile" "$msg"
fi

exit
