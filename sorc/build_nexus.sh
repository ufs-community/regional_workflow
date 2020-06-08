#!/bin/sh
set -eux
#
# Check for input argument: this should be the "platform" if it exists.
#
if [ $# -eq 0 ]; then
  echo
  echo "No 'platform' argument supplied"
  echo "Using directory structure to determine machine settings"
  platform=''
else 
  platform=$1
fi
#
source ./machine-setup.sh $platform > /dev/null 2>&1
if [ $platform = "wcoss_cray" ]; then
  platform="cray"
fi
#
# Set the name of the package.  This will also be the name of the execu-
# table that will be built.
#
package_name="arl_nexus"
#
# Make an exec folder if it doesn't already exist.
#
mkdir -p ../exec
#
# Change directory to where the source code is located.
# 
cd ${package_name}.fd/
home_dir=`pwd`/../..
srcDir=`pwd`
#
# Load modules.
#
set +x
source config/modulefiles.${platform}
#
MPICH_UNEX_BUFFER_SIZE=256m
MPICH_MAX_SHORT_MSG_SIZE=64000
MPICH_PTL_UNEX_EVENTS=160k
KMP_STACKSIZE=2g
F_UFMTENDIAN=big
#
# HDF5 and NetCDF directories.
#
if [ $platform = "cray" ]; then
  HDF5=${HDF5_DIR}
  NETCDF=${NETCDF_DIR}
elif [ $platform = "theia" ]; then
  HDF5_DIR=$HDF5
  NETCDF_DIR=$NETCDF
elif [ $platform = "hera" ]; then
  HDF5_DIR=$HDF5
  NETCDF_DIR=$NETCDF
elif [ $platform = "cheyenne" ]; then
  NETCDF_DIR=$NETCDF
  HDF5_DIR=$NETCDF #HDF5 resides with NETCDF on Cheyenne
  export HDF5=$NETCDF     #HDF5 used in Makefile_cheyenne
elif [ $platform = "jet" ]; then
  HDF5_DIR=$HDF5
  NETCDF_DIR=$NETCDF
fi

#build the file

export COMPILER=${COMPILER:-intel}
export CMAKE_Platform=linux.${COMPILER}
export CMAKE_C_COMPILER=${CMAKE_C_COMPILER:-mpicc}
export CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER:-mpicxx}
export CMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER:-mpif90}

cmake CMakeLists.txt
make -j ${BUILD_JOBS:-4}

exit
