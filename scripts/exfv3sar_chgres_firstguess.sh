#!/bin/ksh

################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exfv3sar_chgres_firstguess.sh
# Script description:  Gets best available FV3GFS atmf nemsio files to make FV3SAR IC's 
#                      and 3-h BC's for the 6-h forecast from T-12 h to generate the 
#                      first guess at T-6h for the FV3SAR hourly DA cycle
#
# Script history log:
# 2018-10-30  Eric Rogers - Modified based on original chgres job
# 2018-11-09  Ben Blake   - Moved various settings into J-job script
#
################################################################################

set -x
export NODES=1
#
# the following exports can all be set or just will default to what is in global_chgres_driver.sh
#
export CASE=C768                   # resolution of tile: 48, 96, 192, 384, 768, 1152, 3072
export LEVS=65
export LSOIL=4
export NTRAC=7
export nst_anl=.false.             # false or true to include NST analysis

export CDAS=gfs
CRES=`echo $CASE | cut -c 2-`
export OUTDIR=$DATA

if [ $gtype = regional ] ; then
  export REGIONAL=1
  export HALO=4
#
# set the links to use the 4 halo grid and orog files
# these are necessary for creating the boundary data
# no need to do this every time it runs!
#
  ln -sf $FIXfv3/$CASE/${CASE}_grid.tile7.halo4.nc $FIXfv3/$CASE/${CASE}_grid.tile7.nc
  ln -sf $FIXfv3/$CASE/${CASE}_oro_data.tile7.halo4.nc $FIXfv3/$CASE/${CASE}_oro_data.tile7.nc
else
#
# for gtype = uniform, stretch or nest
#
  export REGIONAL=0
fi

#
#execute the chgres driver
#
$USHdir/global_chgres_driver.sh

export res=768            #-- FV3 equivalent to 13-km global resolution
export RES=C$res
export RUN=${RES}_nest_$CDATE

#INPdir is $COMOUT/gfsanl.tm12, set in J-job

mv $OUTDIR/gfs*nc $INPdir/.
mv $OUTDIR/sfc*nc $INPdir/.

#Done with IC's generate boundary conditions
export REGIONAL=2

#NHRSguess comes from JFV3SAR_ENVIR

hour=3
end_hour=$NHRSguess
while (test "$hour" -le "$end_hour")
 do
  if [ $hour -lt 10 ]; then
    hour_name='00'$hour
  elif [ $hour -lt 100 ]; then
    hour_name='0'$hour
  else
    hour_name=$hour
  fi

  if [ $machine = WCOSS_C ]; then
#
#create input file for cfp in order to run multiple copies of global_chgres_driver.sh simultaneously
#
#since we are going to run simulataneously, we want different working directories for each hour
#
    BC_DATA=/gpfs/hps3/ptmp/${LOGNAME}/wrk.chgres.$hour_name
    echo "env REGIONAL=2 bchour=$hour_name DATA=$BC_DATA $BASE_GSM/ush/global_chgres_driver.sh >&out.chgres.$hour_name" >>bcfile.input
  elif [ $machine = THEIA -o $machine = WCOSS -o $machine = DELL ]; then
#
#for now on theia run the BC creation sequentially
#
    export REGIONAL=2
    export HALO=4
    export bchour=$hour_name
    $USHdir/global_chgres_driver_dacycle_hourly.sh
    mv $OUTDIR/gfs_bndy.tile7.${bchour}.nc $INPdir/.
    err=$?
    if [ $err -ne 0 ] ; then
      echo "bndy file not created, abort"
      exit 10
    fi
  fi
  hour=`expr $hour + 3`
done
#
# for WCOSS_C we now run BC creation for all hours simultaneously
#
if [ $machine = WCOSS_C ]; then
  export APRUNC=time
  export OMP_NUM_THREADS_CH=24      #default for openMP threads
  aprun -j 1 -n 28 -N 1 -d 24 -cc depth cfp bcfile.input
  export err=$?;err_chk
  rm bcfile.input
fi

exit
