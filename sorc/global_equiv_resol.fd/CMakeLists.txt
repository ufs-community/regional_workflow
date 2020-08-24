
if(CMAKE_Fortran_COMPILER_ID MATCHES "^(Intel)$")
  set(CMAKE_Fortran_FLAGS "-g -O2")
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "^(GNU|Clang|AppleClang)$")
  set(CMAKE_Fortran_FLAGS "-g -O2")
endif()


add_executable(global_equiv_resol global_equiv_resol.f90)
target_link_libraries(global_equiv_resol NetCDF::NetCDF_Fortran)
