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
# set the links to use the 4 halo grid and orog files
# these are necessary for creating the boundary data
#
ln -sf $FIXsar/${CASE}_grid.tile7.halo4.nc $FIXsar/${CASE}_grid.tile7.nc 
ln -sf $FIXsar/${CASE}_oro_data.tile7.halo4.nc $FIXsar/${CASE}_oro_data.tile7.nc 
ln -sf $FIXsar/${CASE}.vegetation_greenness.tile7.halo4.nc $FIXsar/${CASE}.vegetation_greenness.tile7.nc
ln -sf $FIXsar/${CASE}.soil_type.tile7.halo4.nc $FIXsar/${CASE}.soil_type.tile7.nc
ln -sf $FIXsar/${CASE}.slope_type.tile7.halo4.nc $FIXsar/${CASE}.slope_type.tile7.nc
ln -sf $FIXsar/${CASE}.substrate_temperature.tile7.halo4.nc $FIXsar/${CASE}.substrate_temperature.tile7.nc
ln -sf $FIXsar/${CASE}.facsf.tile7.halo4.nc $FIXsar/${CASE}.facsf.tile7.nc
ln -sf $FIXsar/${CASE}.maximum_snow_albedo.tile7.halo4.nc $FIXsar/${CASE}.maximum_snow_albedo.tile7.nc
ln -sf $FIXsar/${CASE}.snowfree_albedo.tile7.halo4.nc $FIXsar/${CASE}.snowfree_albedo.tile7.nc
ln -sf $FIXsar/${CASE}.vegetation_type.tile7.halo4.nc $FIXsar/${CASE}.vegetation_type.tile7.nc

#
# create namelist and run chgres cube
#
cp ${CHGRESEXEC} .

# NHRS = lentgh of free forecast
# NHRSda = length of DA cyce forecast (always 1-h)
if [ $tmmark = tm00 ]; then
  hour=3
  end_hour=$NHRS
  hour_inc=3
else
  hour=0
  end_hour=$NHRSda
  hour_inc=1
fi

while (test "$hour" -le "$end_hour")
  do
  if [ $hour -lt 10 ]; then
    hour_name='00'$hour
  elif [ $hour -lt 100 ]; then
    hour_name='0'$hour
  else
    hour_name=$hour
  fi

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
 input_type="gaussian"
 tracers="sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"
 tracers_input="spfh","clwmr","o3mr","icmr","rwmr","snmr","grle"
 regional=${REGIONAL}
 halo_bndy=${HALO}
/
EOF

  time ${APRUNC} ./regional_chgres_cube.x
  hour=`expr $hour + $hour_inc`

#
# move output files to save directory
#
  mv gfs.bndy.nc $INPdir/gfs_bndy.tile7.${hour_name}.nc
done


exit 0
