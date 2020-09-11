set(ENV{CC} "icc")
set(ENV{CXX} "icpc")
set(ENV{FC} "mpiifort")

cmake_minimum_required (VERSION 2.8)

project(FVCOM_to_FV3 Fortran)

set(NETCDFINC $ENV{NETCDF}/include)
SET(NETCDF_LIB "-L$ENV{NETCDF}/lib/ -lnetcdf -lnetcdff")
include_directories( ${NETCDFINC} )
SET(Fortran_FLAGS "-O0 -g -I -I$ENV{NETCDF}/include/")

file(GLOB src_all ./*.f90)
set_source_files_properties( ${src_all} PROPERTIES COMPILE_FLAGS ${Fortran_FLAGS} )

set(EXE fvcom_to_FV3.exe)
add_executable(${EXE} ${src_all})
set_target_properties( ${EXE} PROPERTIES COMPILE_FLAGS ${Fortran_FLAGS} )
target_link_libraries( ${EXE} ${NETCDF_LIB} ${LIBW3EMC_UPP} ${LIBW3NCO_UPP} ${LIBBACIO} ${LIBBUFR})
