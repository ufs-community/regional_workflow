#!/bin/sh
set -eu
#------------------------------------
# USER DEFINED STUFF:
#
# USE_PREINST_LIBS: set to "true" to use preinstalled libraries.
#                   Anything other than "true"  will use libraries locally.
#------------------------------------

export USE_PREINST_LIBS="true"

#------------------------------------
# END USER DEFINED STUFF
#------------------------------------

build_dir=`pwd`
logs_dir=$build_dir/logs
if [ ! -d $logs_dir  ]; then
  echo "Creating logs folder"
  mkdir $logs_dir
fi

# Check final exec folder exists
if [ ! -d "../exec" ]; then
  echo "Creating ../exec folder"
  mkdir ../exec
fi

#------------------------------------
# INCLUDE PARTIAL BUILD 
#------------------------------------

. ./partial_build.sh

#------------------------------------
# build libraries first
#------------------------------------
#$Build_libs && {
echo " .... Library build not currently supported .... "
#echo " .... Building libraries .... "
#./build_libs.sh > $logs_dir/build_libs.log 2>&1
#}

#------------------------------------
# build fv3
#------------------------------------
$Build_fv3gfs && {
echo " .... Building fv3 .... "
./build_fv3.sh > $logs_dir/build_fv3.log 2>&1
}

#------------------------------------
# build gsi
#------------------------------------
$Build_gsi && {
echo " .... Building gsi .... "
./build_gsi.sh > $logs_dir/build_gsi.log 2>&1
}

#------------------------------------
# build ncep_post
#------------------------------------
$Build_ncep_post && {
echo " .... Building ncep_post .... "
./build_ncep_post.sh > $logs_dir/build_ncep_post.log 2>&1
}

#------------------------------------
# build chgres
#------------------------------------
$Build_chgres && {
echo " .... Building chgres .... "
./build_chgres.sh > $logs_dir/build_chgres.log 2>&1
}

#------------------------------------
# build orog
#------------------------------------
$Build_orog && {
echo " .... Building orog .... "
./build_orog.sh > $logs_dir/build_orog.log 2>&1
}

#------------------------------------
# build fre-nctools
#------------------------------------
$Build_nctools && {
echo " .... Building fre-nctools .... "
./build_fre-nctools.sh > $logs_dir/build_fre-nctools.log 2>&1
}


echo;echo " .... Build system finished .... "

exit 0
