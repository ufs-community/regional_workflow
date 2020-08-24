
if(CMAKE_Fortran_COMPILER_ID MATCHES "^(Intel)$")
  set(CMAKE_Fortran_FLAGS "-g -O2")
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "^(GNU|Clang|AppleClang)$")
  set(CMAKE_Fortran_FLAGS "-g -O2")
endif()


add_executable(mosaic_file mosaic_file.f90)
target_link_libraries(mosaic_file NetCDF::NetCDF_Fortran)
