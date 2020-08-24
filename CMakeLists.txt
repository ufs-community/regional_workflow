cmake_minimum_required(VERSION 3.15)

project(regional_workflow LANGUAGES Fortran)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/Modules")

find_package(NetCDF COMPONENTS Fortran)

add_subdirectory(sorc)


