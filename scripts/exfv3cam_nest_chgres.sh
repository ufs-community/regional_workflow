#!/bin/sh
############################################################################
# Script name:		exfv3cam_nest_chgres.sh
# Script description:	Makes ICs on fv3 nested cubed-sphere grid 
#                       using FV3GFS initial conditions.
# Script history log:
#   1) 2016-09-30       Fanglin Yang
#   2) 2017-02-08	Fanglin Yang and George Gayno
#			Use the new CHGRES George Gayno developed.
#   3) 2019-05-02	Ben Blake
#                       Created exfv3cam_nest_chgres.sh script
#			from global_chgres_driver.sh
############################################################################
set -x

# gtype = nest
echo "creating nested ICs"
export ntiles=7

# input data is FV3GFS (ictype is 'pfv3gfs')
export ATMANL=$INIDIR/${CDUMP}.t${cyc}z.atmanl.nemsio
export SFCANL=$INIDIR/${CDUMP}.t${cyc}z.sfcanl.nemsio

export NSTANL="NULL"
export SOILTYPE_INP=statsgo
export VEGTYPE_INP=igbp
export nopdpvv=.true.

LONB_ATM=0	# not used for ops files
LATB_ATM=0
JCAP_CASE=$((CRES*2-2))
LONB_SFC=$((CRES*4))
LATB_SFC=$((CRES*2))
if [ $CRES -gt 768 -o $gtype = nest ]; then
  JCAP_CASE=1534
  LONB_SFC=3072
  LATB_SFC=1536
fi

# to use new albedo, soil/veg type
export CLIMO_FIELDS_OPT=3
export LANDICE_OPT=${LANDICE_OPT:-2}
export IALB=1

export SIGLEVEL=${FIXam}/global_hyblev.l${LEVS}.txt
export FNGLAC=${FIXam}/global_glacier.2x2.grb
export FNMXIC=${FIXam}/global_maxice.2x2.grb
export FNTSFC=${FIXam}/cfs_oi2sst1x1monclim19822001.grb
export FNSNOC=${FIXam}/global_snoclim.1.875.grb
export FNAISC=${FIXam}/cfs_ice1x1monclim19822001.grb
export FNMSKH=${FIXam}/seaice_newland.grb
export FNSMCC=$FIXam/global_soilmgldas.statsgo.t${JCAP_CASE}.${LONB_SFC}.${LATB_SFC}.grb

export FNSOTC=$FIXnest/${CASE}.soil_type.tileX.nc
export SOILTYPE_OUT=statsgo
export FNVETC=$FIXnest/${CASE}.vegetation_type.tileX.nc
export VEGTYPE_OUT=igbp
export FNABSC=$FIXnest/${CASE}.maximum_snow_albedo.tileX.nc
export FNALBC=$FIXnest/${CASE}.snowfree_albedo.tileX.nc
export FNALBC2=$FIXnest/${CASE}.facsf.tileX.nc
export FNZORC=igbp
export FNSLPC=$FIXnest/${CASE}.slope_type.tileX.nc
export FNTG3C=$FIXnest/${CASE}.substrate_temperature.tileX.nc
export FNVEGC=$FIXnest/${CASE}.vegetation_greenness.tileX.nc
export FNVMXC=$FIXnest/${CASE}.vegetation_greenness.tileX.nc
export FNVMNC=$FIXnest/${CASE}.vegetation_greenness.tileX.nc

#------------------------------------
# For REGIONAL=0
# gtype = uniform, stretch, or nest
#------------------------------------

#--------------------------------------------------
# Convert atmospheric file.
#--------------------------------------------------
export CHGRESVARS="use_ufo=.false.,idvc=2,idvt=21,idsl=1,IDVM=0,nopdpvv=$nopdpvv"
export SIGINP=$ATMANL
export SFCINP=NULL
export NSTINP=NULL
export JCAP=$JCAP_CASE
export LATB=$LATB_ATM
export LONB=$LONB_ATM

$CHGRESSH
rc=$?
if [[ $rc -ne 0 ]] ; then
 echo "***ERROR*** rc= $rc"
 exit $rc
fi

mv ${DATA}/gfs_data.tile*.nc $OUTDIR/.
mv ${DATA}/gfs_ctrl.nc       $OUTDIR/.

#---------------------------------------------------
# Convert surface and nst files one tile at a time.
#---------------------------------------------------

export CHGRESVARS="use_ufo=.true.,idvc=2,idvt=21,idsl=1,IDVM=0,nopdpvv=$nopdpvv"
export SIGINP=NULL
export SFCINP=$SFCANL
export NSTINP=$NSTANL
export JCAP=$JCAP_CASE
export LATB=$LATB_SFC
export LONB=$LONB_SFC

tile=1
while [ $tile -le $ntiles ]; do
  export TILE_NUM=$tile
  $CHGRESSH
  rc=$?
  if [[ $rc -ne 0 ]] ; then
    echo "***ERROR*** rc= $rc"
    exit $rc
  fi
  mv ${DATA}/out.sfc.tile${tile}.nc $OUTDIR/sfc_data.tile${tile}.nc
  tile=`expr $tile + 1 `
done

#-----------------------------------------------
# Move files into $INPdir for the forecast job.
#-----------------------------------------------
mv $OUTDIR/gfs*nc $INPdir/.
mv $OUTDIR/sfc*nc $INPdir/.

exit 0
