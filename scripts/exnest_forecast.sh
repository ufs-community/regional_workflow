#!/bin/ksh
############################################################################
# Script name:		exfv3cam_nest_fcst.sh
# Script description:	Run the 3-km FV3 nest forecast over the CONUS
#			using the GFDL microphysics scheme.
# Script history log:
#   1) 2018-03-14	Eric Rogers
#			run_nest.tmp retrieved from Eric's run_it directory.	
#   2) 2018-04-03	Ben Blake
#                       Modified from Eric's run_nest.tmp script.
#   3) 2018-04-13	Ben Blake
#			Various settings moved to JFV3_FORECAST J-job
#   4) 2018-07-27       Ben Blake
#                       Ported script to phase 2.
############################################################################
set -eux

ulimit -s unlimited
ulimit -a

if [ ! -d $GUESSdir ]; then
   echo Cannot find $GUESSdir ... exit
   exit
fi

mkdir -p INPUT RESTART
cp ${GUESSdir}/*.nc INPUT

#---------------------------------------------- 
# Copy all the necessary fix files
#---------------------------------------------- 
cp $FIXam/global_solarconstant_noaa_an.txt            solarconstant_noaa_an.txt
cp $FIXam/ozprdlos_2015_new_sbuvO3_tclm15_nuchem.f77  global_o3prdlos.f77
cp $FIXam/global_h2o_pltc.f77                         global_h2oprdlos.f77
cp $FIXam/global_sfc_emissivity_idx.txt               sfc_emissivity_idx.txt
cp $FIXam/global_co2historicaldata_glob.txt           co2historicaldata_glob.txt
cp $FIXam/co2monthlycyc.txt                           co2monthlycyc.txt
cp $FIXam/global_climaeropac_global.txt               aerosol.dat

cp $FIXam/global_glacier.2x2.grb .
cp $FIXam/global_maxice.2x2.grb .
cp $FIXam/RTGSST.1982.2012.monthly.clim.grb .
cp $FIXam/global_snoclim.1.875.grb .
cp $FIXam/CFSR.SEAICE.1982.2012.monthly.clim.grb .
cp $FIXam/global_soilmgldas.t1534.3072.1536.grb .
cp $FIXam/seaice_newland.grb .
cp $FIXam/global_shdmin.0.144x0.144.grb .
cp $FIXam/global_shdmax.0.144x0.144.grb .

ln -sf $FIXnest/${CASE}.maximum_snow_albedo.tile7.nc ${CASE}.maximum_snow_albedo.tile1.nc
ln -sf $FIXnest/${CASE}.snowfree_albedo.tile7.nc ${CASE}.snowfree_albedo.tile1.nc
ln -sf $FIXnest/${CASE}.slope_type.tile7.nc ${CASE}.slope_type.tile1.nc
ln -sf $FIXnest/${CASE}.soil_type.tile7.nc ${CASE}.soil_type.tile1.nc
ln -sf $FIXnest/${CASE}.vegetation_type.tile7.nc ${CASE}.vegetation_type.tile1.nc
ln -sf $FIXnest/${CASE}.vegetation_greenness.tile7.nc ${CASE}.vegetation_greenness.tile1.nc
ln -sf $FIXnest/${CASE}.substrate_temperature.tile7.nc ${CASE}.substrate_temperature.tile1.nc
ln -sf $FIXnest/${CASE}.facsf.tile7.nc ${CASE}.facsf.tile1.nc
 
for file in `ls $FIXco2/global_co2historicaldata* ` ; do
 cp $file $(echo $(basename $file) |sed -e "s/global_//g")
done

#---------------------------------------------- 
# Copy tile data and orography
#---------------------------------------------- 
ntiles=7
tile=1
while [ $tile -le $ntiles ]; do
   cp $FIXnest/${CASE}_oro_data.tile${tile}.nc INPUT/oro_data.tile${tile}.nc
   cp $FIXnest/${CASE}_grid.tile${tile}.nc INPUT/${CASE}_grid.tile${tile}.nc
   let tile=tile+1
done
cp $FIXnest/${CASE}_mosaic.nc INPUT/grid_spec.nc
 
# The next 4 links are a hack GFDL requires for running a nest
 
cd INPUT
ln -sf ${CASE}_grid.tile7.nc grid.nest02.tile7.nc
ln -sf oro_data.tile7.nc oro_data.nest02.tile7.nc
ln -sf gfs_data.tile7.nc gfs_data.nest02.tile7.nc
ln -sf sfc_data.tile7.nc sfc_data.nest02.tile7.nc
cd ..

#-------------------------------------------------------------------
# Copy or set up files data_table, diag_table, field_table,
#   input.nml, input_nest02.nml, model_configure, and nems.configure
#-------------------------------------------------------------------

cp ${PARMfv3}/data_table .
cp ${PARMfv3}/diag_table.tmp .
cp ${PARMfv3}/field_table .
cp ${PARMfv3}/input_global.nml input.nml
cp ${PARMfv3}/input_nest.nml input_nest02.nml
cp ${PARMfv3}/model_configure_nest.tmp model_configure.tmp
cp ${PARMfv3}/nems.configure .

yr=`echo $CDATE | cut -c1-4`
mn=`echo $CDATE | cut -c5-6`
dy=`echo $CDATE | cut -c7-8`

cat > temp << !
${yr}${mn}${dy}.${cyc}Z
$yr $mn $dy $cyc 0 0
!

cat temp diag_table.tmp > diag_table

cat model_configure.tmp | sed s/NTASKS/$TOTAL_TASKS/ | sed s/YR/$yr/ | \
    sed s/MN/$mn/ | sed s/DY/$dy/ | sed s/H_R/$cyc/ | \
    sed s/NHRS/$NHRS/ | sed s/NTHRD/$OMP_NUM_THREADS/ | \
    sed s/NCNODE/$NCNODE/  >  model_configure

#----------------------------------------- 
# Run the forecast
#-----------------------------------------
export pgm=regional_forecast.x
. prep_step

startmsg
${APRUNC} $EXECfv3/regional_forecast.x >$pgmout 2>err
export err=$?;err_chk

exit
