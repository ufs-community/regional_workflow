#!/bin/sh
############################################################################
# Script name:		run_regional_gfdlmp.sh
# Script description:	Run the 3-km FV3 regional forecast over the CONUS
#			using the GFDL microphysics scheme.
# Script history log:
#   1) 2018-03-14	Eric Rogers
#			run_nest.tmp retrieved from Eric's run_it directory.	
#   2) 2018-04-03	Ben Blake
#                       Modified from Eric's run_nest.tmp script.
#   3) 2018-04-13	Ben Blake
#			Various settings moved to JFV3_FORECAST J-job
#   4) 2018-06-19       Ben Blake
#                       Adapted for stand-alone regional configuration
############################################################################
set -eux

ulimit -s unlimited
ulimit -a

mkdir -p INPUT RESTART
cp ${NWGES}/anl.${dom}.${tmmark}/*.nc INPUT

numbndy=`ls -l INPUT/gfs_bndy.tile7*.nc | wc -l`
let "numbndy_check=$NHRS/3+1"

if [ $tmmark = tm00 ] ; then
  if [ $numbndy -ne $numbndy_check ] ; then
    export err=13
    echo "Don't have all BC files at tm00, abort run"
    err_exit "Don't have all BC files at tm00, abort run"
  fi
else
  if [ $numbndy -ne 2 ] ; then
    export err=2
    echo "Don't have both BC files at ${tmmark}, abort run"
    err_exit "Don't have all BC files at ${tmmark}, abort run"
  fi
fi

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

ln -sf $FIXsar/C768.maximum_snow_albedo.tile7.nc C768.maximum_snow_albedo.tile1.nc
ln -sf $FIXsar/C768.snowfree_albedo.tile7.nc C768.snowfree_albedo.tile1.nc
ln -sf $FIXsar/C768.slope_type.tile7.nc C768.slope_type.tile1.nc
ln -sf $FIXsar/C768.soil_type.tile7.nc C768.soil_type.tile1.nc
ln -sf $FIXsar/C768.vegetation_type.tile7.nc C768.vegetation_type.tile1.nc
ln -sf $FIXsar/C768.vegetation_greenness.tile7.nc C768.vegetation_greenness.tile1.nc
ln -sf $FIXsar/C768.substrate_temperature.tile7.nc C768.substrate_temperature.tile1.nc
ln -sf $FIXsar/C768.facsf.tile7.nc C768.facsf.tile1.nc


for file in `ls $FIXco2/global_co2historicaldata* ` ; do
  cp $file $(echo $(basename $file) |sed -e "s/global_//g")
done

#---------------------------------------------- 
# Copy tile data and orography for regional
#---------------------------------------------- 
ntiles=1
tile=7
cp $FIXsar/${CASE}_grid.tile${tile}.halo3.nc INPUT/.
cp $FIXsar/${CASE}_grid.tile${tile}.halo4.nc INPUT/.
cp $FIXsar/${CASE}_oro_data.tile${tile}.halo0.nc INPUT/.
cp $FIXsar/${CASE}_oro_data.tile${tile}.halo4.nc INPUT/.
cp $FIXsar/${CASE}_mosaic.nc INPUT/.
  
cd INPUT
ln -sf ${CASE}_mosaic.nc grid_spec.nc
ln -sf ${CASE}_grid.tile7.halo3.nc ${CASE}_grid.tile7.nc
ln -sf ${CASE}_grid.tile7.halo4.nc grid.tile7.halo4.nc
ln -sf ${CASE}_oro_data.tile7.halo0.nc oro_data.nc
ln -sf ${CASE}_oro_data.tile7.halo4.nc oro_data.tile7.halo4.nc
# Initial Conditions are needed for SAR but not SAR-DA
if [ $model = fv3sar ] ; then
  ln -sf sfc_data.tile7.nc sfc_data.nc
  ln -sf gfs_data.tile7.nc gfs_data.nc
fi
cd ..

#-------------------------------------------------------------------
# Copy or set up files data_table, diag_table, field_table,
#   input.nml, input_nest02.nml, model_configure, and nems.configure
#-------------------------------------------------------------------
CCPP=${CCPP:-"false"}
CCPP_SUITE=${CCPP_SUITE:-"FV3_GFS_2017_gfdlmp_regional"}

if [ $tmmark = tm00 ] ; then
# Free forecast with DA (warm start)
  if [ $model = fv3sar_da ] ; then
    cp ${PARMfv3}/input_sar_da.nml input.nml 
# Free forecast without DA (cold start)
  elif [ $model = fv3sar ] ; then 
    if [ $CCPP  = true ] || [ $CCPP = TRUE ] ; then
      cp ${PARMfv3}/input_sar_${dom}_ccpp.nml input.nml.tmp
      cat input.nml.tmp | sed s/CCPP_SUITE/\'$CCPP_SUITE\'/ >  input.nml
      cp ${PARMfv3}/suite_${CCPP_SUITE}.xml suite_${CCPP_SUITE}.xml
    else
      cp ${PARMfv3}/input_sar_${dom}.nml input.nml
    fi
  fi
  cp ${PARMfv3}/model_configure_sar.tmp_${dom} model_configure.tmp

else
  cp ${PARMfv3}/input_sar_da_hourly.nml input.nml
  cp ${PARMfv3}/model_configure_sar_da_hourly.tmp model_configure.tmp
fi

cp ${PARMfv3}/d* .
cp ${PARMfv3}/field_table .
cp ${PARMfv3}/nems.configure .

if [ $CCPP  = true ] || [ $CCPP = TRUE ] ; then
   if [ -f "${PARMfv3}/field_table_ccpp" ] ; then
    cp -f ${PARMfv3}/field_table_ccpp field_table
   fi
fi

yr=`echo $CYCLEanl | cut -c1-4`
mn=`echo $CYCLEanl | cut -c5-6`
dy=`echo $CYCLEanl | cut -c7-8`
hr=`echo $CYCLEanl | cut -c9-10`

if [ $tmmark = tm00 ] ; then
  NFCSTHRS=$NHRS
  NRST=12
else
  NFCSTHRS=$NHRSda
  NRST=01
fi

cat > temp << !
${yr}${mn}${dy}.${hr}Z.${CASE}.32bit.non-hydro
$yr $mn $dy $hr 0 0
!

cat temp diag_table.tmp > diag_table

cat model_configure.tmp | sed s/NTASKS/$TOTAL_TASKS/ | sed s/YR/$yr/ | \
    sed s/MN/$mn/ | sed s/DY/$dy/ | sed s/H_R/$hr/ | \
    sed s/NHRS/$NFCSTHRS/ | sed s/NTHRD/$OMP_NUM_THREADS/ | \
    sed s/NCNODE/$NCNODE/ | sed s/NRESTART/$NRST/  >  model_configure

#----------------------------------------- 
# Run the forecast
#-----------------------------------------
export pgm=regional_forecast.x
. prep_step

startmsg
${APRUNC} $EXECfv3/regional_forecast.x >$pgmout 2>err
export err=$?;err_chk

# Copy files needed for next analysis
# use grid_spec.nc file output from model in working directory,
# NOT the one in the INPUT directory......

# GUESSdir, ANLdir set in J-job

if [ $tmmark != tm00 ] ; then
  cp grid_spec.nc $GUESSdir/.
  cd RESTART
  mv ${PDYfcst}.${CYCfcst}0000.coupler.res $GUESSdir/.
  mv ${PDYfcst}.${CYCfcst}0000.fv_core.res.nc $GUESSdir/.
  mv ${PDYfcst}.${CYCfcst}0000.fv_core.res.tile1.nc $GUESSdir/.
  mv ${PDYfcst}.${CYCfcst}0000.fv_tracer.res.tile1.nc $GUESSdir/.
  mv ${PDYfcst}.${CYCfcst}0000.sfc_data.nc $GUESSdir/.

# These are not used in GSI but are needed to warmstart FV3
# so they go directly into ANLdir
  mv ${PDYfcst}.${CYCfcst}0000.phy_data.nc $ANLdir/phy_data.nc
  mv ${PDYfcst}.${CYCfcst}0000.fv_srf_wnd.res.tile1.nc $ANLdir/fv_srf_wnd.res.tile1.nc
fi

exit
