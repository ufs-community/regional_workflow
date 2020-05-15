#! /bin/sh


module purge >& /dev/null

module load ncep
module load craype-sandybridge
module use -a /opt/cray/modulefiles
#not module load -a ../modulefiles/wcoss_cray/hiresw_fv3_module
module load -a ../modulefiles/wcoss_cray/v8.0.0-cray-intel
module list

cd ./regional_sndp.fd

make delete

make

cd ../

