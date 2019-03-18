#!/bin/ksh

###############################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exfv3sar_fcst.sh
# Script description:  Run FV3SAR Forecast for hourly DA cycle or free forecast
#
# Script history log:
# 2018-10-30  Eric Rogers - Modified based on original FV3SAR forecast job
# 2018-11-09  Ben Blake   - Moved various settings into J-job script
#
###############################################################################

set -x

ulimit -s unlimited
ulimit -a

export KMP_AFFINITY=scatter
export OMP_NUM_THREADS=2
export OMP_STACKSIZE=1024m

mkdir -p INPUT RESTART
cp ${NWGES}/anl.${tmmark}/*.nc INPUT

numbndy=`ls -1 INPUT/gfs_bndy.tile7*.nc | wc -l`

#needed for err_exit
export SENDECF=NO

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

cp $FIX_AM/global_solarconstant_noaa_an.txt            solarconstant_noaa_an.txt
cp $FIX_AM/ozprdlos_2015_new_sbuvO3_tclm15_nuchem.f77  INPUT/global_o3prdlos.f77
cp $FIX_AM/global_h2o_pltc.f77                         INPUT/global_h2oprdlos.f77
cp $FIX_AM/ozprdlos_2015_new_sbuvO3_tclm15_nuchem.f77  global_o3prdlos.f77
cp $FIX_AM/global_h2o_pltc.f77                         global_h2oprdlos.f77
cp $FIX_AM/global_sfc_emissivity_idx.txt 	       sfc_emissivity_idx.txt
cp $FIX_AM/global_co2historicaldata_glob.txt           co2historicaldata_glob.txt
cp $FIX_AM/co2monthlycyc.txt             	       co2monthlycyc.txt
cp $FIX_AM/global_climaeropac_global.txt 	       aerosol.dat

cp $FIX_AM/global_glacier.2x2.grb .
cp $FIX_AM/global_maxice.2x2.grb .
cp $FIX_AM/RTGSST.1982.2012.monthly.clim.grb .
cp $FIX_AM/global_snoclim.1.875.grb .
cp $FIX_AM/CFSR.SEAICE.1982.2012.monthly.clim.grb .
cp $FIX_AM/global_soilmgldas.t1534.3072.1536.grb .
cp $FIX_AM/seaice_newland.grb .
cp $FIX_AM/global_shdmin.0.144x0.144.grb .
cp $FIX_AM/global_shdmax.0.144x0.144.grb .

ln -sf $FIXnew/C768.maximum_snow_albedo.tile7.nc C768.maximum_snow_albedo.tile1.nc
ln -sf $FIXnew/C768.snowfree_albedo.tile7.nc C768.snowfree_albedo.tile1.nc
ln -sf $FIXnew/C768.slope_type.tile7.nc C768.slope_type.tile1.nc
ln -sf $FIXnew/C768.soil_type.tile7.nc C768.soil_type.tile1.nc
ln -sf $FIXnew/C768.vegetation_type.tile7.nc C768.vegetation_type.tile1.nc
ln -sf $FIXnew/C768.vegetation_greenness.tile7.nc C768.vegetation_greenness.tile1.nc
ln -sf $FIXnew/C768.substrate_temperature.tile7.nc C768.substrate_temperature.tile1.nc
ln -sf $FIXnew/C768.facsf.tile7.nc C768.facsf.tile1.nc

#
for file in `ls $CO2DIR/global_co2historicaldata* ` ; do
  cp $file $(echo $(basename $file) |sed -e "s/global_//g")
done
#
#copy tile data and orography for regional
#
res=768
ntiles=7
tile=7
while [ $tile -le $ntiles ]; do
  cp $FIXDIR/C${res}/C${res}_grid.tile${tile}.halo3.nc INPUT/.
  cp $FIXDIR/C${res}/C${res}_grid.tile${tile}.halo4.nc INPUT/.
  cp $FIXDIR/C${res}/C${res}_oro_data.tile${tile}.halo0.nc INPUT/.
  cp $FIXDIR/C${res}/C${res}_oro_data.tile${tile}.halo4.nc INPUT/.
  tile=`expr $tile + 1 `
done
cp -p $FIXDIR/C${res}/C${res}_mosaic.nc INPUT/.

cd INPUT
ln -sf C768_mosaic.nc grid_spec.nc
ln -sf C${res}_grid.tile7.halo3.nc C${res}_grid.tile7.nc
ln -sf C${res}_grid.tile7.halo4.nc grid.tile7.halo4.nc
ln -sf C${res}_oro_data.tile7.halo0.nc oro_data.nc
ln -sf C${res}_oro_data.tile7.halo4.nc oro_data.tile7.halo4.nc
##ln -sf sfc_data.tile7.nc sfc_data.nc
##ln -sf gfs_data.tile7.nc gfs_data.nc
cd ..

#remove old files if they are present
rm logf* postdone* phyf*.nc dynf*.nc

# Copy or set up files data_table, diag_table, field_table,
# input.nml, input_nest02.nml, model_configure, and nems.configure
#
if [ $tmmark = tm00 ] ; then
  cp ${CONFIGdir}/diag_table_tmp diag_table_mp.tmp
  cp ${CONFIGdir}/input.nml_gsianl_writecomp input.nml
  cp ${CONFIGdir}/model_configure.tmp_writecomp model_configure.tmp
  export NODES=114
  ncnode=24    #-- 12 tasks per node on Cray
  let nctsk=ncnode/OMP_NUM_THREADS
  let ntasks=1368
  echo nctsk = $nctsk and ntasks = $ntasks
# Submit post manager here
# bsub < $HOMEdir/ecf/run${cyc}_post_manager.sh 
else
  cp ${CONFIGdir}/diag_table_tmp diag_table_mp.tmp
  cp ${CONFIGdir}/input.nml_gsianl_da_hourly_writecomp input.nml
  cp ${CONFIGdir}/model_configure.tmp_writecomp_hourly model_configure.tmp
  export NODES=54
  ncnode=12    #-- 12 tasks per node on Cray
  let nctsk=ncnode/OMP_NUM_THREADS
  let ntasks=648
  echo nctsk = $nctsk and ntasks = $ntasks
fi

cp ${CONFIGdir}/data_table .
cp ${CONFIGdir}/field_table .
cp ${CONFIGdir}/nems.configure .

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
${yr}${mn}${dy}.${hr}Z.${RES}.32bit.non-hydro
$yr $mn $dy $hr 0 0
!

cat temp diag_table_mp.tmp > diag_table

cat model_configure.tmp | sed s/NTASKS/$ntasks/ | sed s/YR/$yr/ | \
    sed s/MN/$mn/ | sed s/DY/$dy/ | sed s/H_R/$hr/ | \
    sed s/NHRS/$NFCSTHRS/ | sed s/NTHRD/$OMP_NUM_THREADS/ | \
    sed s/NCNODE/$ncnode/ | sed s/NRESTART/$NRST/  >  model_configure


export pgm=global_fv3gfs_maxhourly.x
. prep_step

startmsg
mpirun -l -n ${ntasks} $EXECfv3/global_fv3gfs_maxhourly.x >$pgmout 2>err
export err=$?;err_chk

# Copy files needed for next analysis
# use grid_spec.nc file output from model in working directory, 
# NOT the one in the INPUT directory.......

#GUESSdir, ANLdir set in J-job

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
