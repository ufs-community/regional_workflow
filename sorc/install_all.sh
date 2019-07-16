#!/bin/sh
set -xeu

build_dir=`pwd`

CP='cp -rp'

# Check final exec folder exists
if [ ! -d "../exec" ]; then
  echo "Creating ../exec folder"
  mkdir ../exec
fi

#------------------------------------
# install forecast
#------------------------------------
${CP} regional_forecast.fd/NEMS/exe/NEMS.x ../exec/regional_forecast.x

#------------------------------------
# install gsi
#------------------------------------
${CP} regional_gsi.fd/exec/global_gsi.x  ../exec/regional_gsi.x
${CP} regional_gsi.fd/exec/global_enkf.x ../exec/regional_enkf.x

#------------------------------------
# install post
#------------------------------------
${CP} regional_post.fd/exec/ncep_post ../exec/regional_post.x

#------------------------------------
# install chgres
#------------------------------------
${CP} regional_utils.fd/exec/global_chgres ../exec/regional_chgres.x

#------------------------------------
# install chgres_cube
#------------------------------------
${CP} regional_utils.fd/exec/chgres_cube.exe ../exec/regional_chgres_cube.x

#------------------------------------
# install orog
#------------------------------------
${CP} regional_utils.fd/exec/orog.x ../exec/regional_orog.x

#------------------------------------
# install fre-nctools
#------------------------------------
${CP} regional_utils.fd/exec/make_hgrid                  ../exec/regional_make_hgrid.x
#${CP} regional_utils.fd/exec/make_hgrid_parallel         ../exec/regional_make_hgrid_parallel.x
${CP} regional_utils.fd/exec/make_solo_mosaic            ../exec/regional_make_solo_mosaic.x
${CP} regional_utils.fd/exec/fregrid                     ../exec/regional_fregrid.x
#${CP} regional_utils.fd/exec/fregrid_parallel            ../exec/regional_fregrid_parallel.x
${CP} regional_utils.fd/exec/filter_topo                 ../exec/regional_filter_topo.x
${CP} regional_utils.fd/exec/shave.x                     ../exec/regional_shave.x

echo;echo " .... Install system finished .... "

exit 0
