#!/bin/sh
############################################################################
# Script name:		exfv3cam_sar_chgres.sh
# Script description:	Makes ICs on fv3 stand-alone regional grid 
#                       using FV3GFS initial conditions.
# Script history log:
#   1) 2016-09-30       Fanglin Yang
#   2) 2017-02-08	Fanglin Yang and George Gayno
#			Use the new CHGRES George Gayno developed.
#   3) 2019-05-02	Ben Blake
#			Created exfv3cam_sar_chgres.sh script
#			from global_chgres_driver.sh
############################################################################
set -ax

# gtype = regional
echo "creating standalone regional BCs"
export ntiles=1
export TILE_NUM=7

#
# create namelist and run chgres cube
#
cp ${CHGRESEXEC} .

hour_name='0'$bchr

cat <<EOF >fort.41
&config
 mosaic_file_target_grid="$FIXsar/${CASE}_mosaic.nc"
 fix_dir_target_grid="$FIXsar"
 orog_dir_target_grid="$FIXsar"
 orog_files_target_grid="${CASE}_oro_data.tile7.halo4.nc"
 vcoord_file_target_grid="${FIXam}/global_hyblev.l${LEVS}.txt"
 mosaic_file_input_grid="NULL"
 orog_dir_input_grid="NULL"
 orog_files_input_grid="NULL"
 data_dir_input_grid="${INIDIR}"
 atm_files_input_grid="gfs.t${cyc}z.atmf${hour_name}.nemsio"
 sfc_files_input_grid="gfs.t${cyc}z.sfcanl.nemsio"
 cycle_mon=$month
 cycle_day=$day
 cycle_hour=$cyc
 convert_atm=.true.
 convert_sfc=.false.
 convert_nst=.false.
 input_type="gaussian_nemsio"
 tracers="sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"
 tracers_input="spfh","clwmr","o3mr","icmr","rwmr","snmr","grle"
 regional=${REGIONAL}
 halo_bndy=${HALO}
 halo_blend=10
/
EOF

time ${APRUNC} ./regional_chgres_cube.x

#
# move output files to save directory
#
mv gfs.bndy.nc $INPdir/gfs_bndy.tile7.${hour_name}.nc


exit 0
