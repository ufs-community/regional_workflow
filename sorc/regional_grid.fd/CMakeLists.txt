
if(CMAKE_Fortran_COMPILER_ID MATCHES "^(Intel)$")
  set(CMAKE_Fortran_FLAGS "-g -O2")
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "^(GNU|Clang|AppleClang)$")
  set(CMAKE_Fortran_FLAGS "-g -O2")
endif()

set(src_files pkind.f90 pietc.f90 pmat.f90 pmat4.f90 pmat5.f90 psym2.f90 gen_schmidt.f90 hgrid_ak.f90 regional_grid.f90)

add_executable(regional_grid ${src_files})
target_link_libraries(regional_grid NetCDF::NetCDF_Fortran)


install(
  TARGETS regional_grid
  RUNTIME DESTINATION bin
  )
