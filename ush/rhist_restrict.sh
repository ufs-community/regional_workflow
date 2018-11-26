#!/bin/sh

################################################################3
#
#  This script checks a RunHistory tar file specified as the first
#  argument ($1) to see if it contains any restricted files belonging
#  to the "rstprod" group.  If it does, the tar file is put in the 
#  rstprod group and the access permissions are set to 640.
#
#  Usage:  rhist_restrict.sh HPSStarfile
#
################################################################3
set -x

if [ $# -ne 1 ]
then
  echo "Usage: rhist_restrict.sh HPSStarfile"
  exit 1
fi 

#
#   Set group id number for rstprod in HPSS
#
#rstprodgid=$(awk ' BEGIN {FS=":"} { if ( $1 == "rstprod" ) {print $3;exit} }' /etc/group)
rstprodgid=245
myid=$(id -u)

file=$1

#
#  If on Stratus:
#  Use htar to check if any file in the tar file
#  contains a file belonging to rstprod group.
#
if [ $TSM_FLAG = 'NO' ]
then
  num=`htar -tvf ${file} | awk ' { print $3 } ' | grep -c rstprod`
  if  [ $num -ne 0 ]
  then
     #
     #   Tar file contains restricted data.  chmod and chgrp
     #   tar file and index file
     #
     echo " $file contains RESTRICTED data."
     hsi "chmod 640 ${file}"
     hsi "chgrp $rstprodgid ${file}"
     #hpsschmod ${file}.idx 640
     #hpsschown ${file}.idx $myid $rstprodgid
  else
     echo " $file DOES NOT contain RESTRICTED data."
  fi
elif [ $TSM_FLAG = 'YES' ]
then
  num=`ssh ibmtsm1.ncep.noaa.gov gtar -tvf ${file} | awk ' { print $2 } ' | grep -c rstprod`
  if  [ $num -ne 0 ]
  then
     #
     #   Tar file contains restricted data.  chmod and chgrp
     #   tar file and index file
     #
     echo " $file contains RESTRICTED data."
     ssh ibmtsm1.ncep.noaa.gov "chmod 640 ${file}; chgrp rstprod ${file}"
  else
     echo " $file DOES NOT contain RESTRICTED data."
  fi
fi

  
exit
