#!/bin/bash

module purge
#module load intel/18.1.163
#module load netcdf/4.6.1
#module load hdf5/1.10.4
module load ips/18.0.1.163
module load impi/18.0.1
module load NCO/4.7.0
module load HDF5-serial/1.10.1
module load NetCDF/4.5.0
module load ESMF/7_1_0r
module list

module load w3nco/2.0.6
module load bacio/2.0.2
module load jasper/1.900.1
module load libpng/1.2.59
module load zlib/1.2.11
module load g2/3.1.0


#export FCOMP=ifort
export FC=ifort
export FFLAGS="-O0 -i4"


#export FFLAGS="-O3 -fp-model=precise -g -traceback -r8 -i4 -convert big_endian"


#make -f Makefile_dell_p3
cp Makefile_dell_p3 Makefile
make clean
make 
