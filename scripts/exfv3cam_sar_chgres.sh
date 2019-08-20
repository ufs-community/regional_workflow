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
set -x

# gtype = regional
echo "creating standalone regional ICs"
export ntiles=1
export TILE_NUM=7

if [ $tmmark = tm00 ] ; then
  # input data is FV3GFS (ictype is 'pfv3gfs')
  export ATMANL=$INIDIR/${CDUMP}.t${cyc}z.atmanl.nemsio
  export SFCANL=$INIDIR/${CDUMP}.t${cyc}z.sfcanl.nemsio
fi
if [ $tmmark = tm12 ] ; then
  # input data is FV3GFS (ictype is 'pfv3gfs')
  export ATMANL=$INIDIRtm12/${CDUMP}.t${cycguess}z.atmanl.nemsio
  export SFCANL=$INIDIRtm12/${CDUMP}.t${cycguess}z.sfcanl.nemsio
fi

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
export FNSMCC=${FIXam}/global_soilmgldas.statsgo.t${JCAP_CASE}.${LONB_SFC}.${LATB_SFC}.grb

export FNSOTC=${FIXsar}/${CASE}.soil_type.tileX.nc
export SOILTYPE_OUT=statsgo
export FNVETC=${FIXsar}/${CASE}.vegetation_type.tileX.nc
export VEGTYPE_OUT=igbp
export FNABSC=${FIXsar}/${CASE}.maximum_snow_albedo.tileX.nc
export FNALBC=${FIXsar}/${CASE}.snowfree_albedo.tileX.nc
export FNALBC2=${FIXsar}/${CASE}.facsf.tileX.nc
export FNZORC=igbp
export FNSLPC=${FIXsar}/${CASE}.slope_type.tileX.nc
export FNTG3C=${FIXsar}/${CASE}.substrate_temperature.tileX.nc
export FNVEGC=${FIXsar}/${CASE}.vegetation_greenness.tileX.nc
export FNVMXC=${FIXsar}/${CASE}.vegetation_greenness.tileX.nc
export FNVMNC=${FIXsar}/${CASE}.vegetation_greenness.tileX.nc

#
# For a regional run, if REGIONAL=2 (generate boundary data only) this script is called multiple times
# so that each boundary time other than hour 0 will be done individually. This allows multiple instances
# of chgres to execute simultaneously.
#

if [ $REGIONAL -eq 1 ]; then	# REGIONAL -eq 1 is for ICs and regional hour 0

#--------------------------------------------------
# Convert atmospheric file.
#--------------------------------------------------
  export CHGRESVARS="use_ufo=.false.,idvc=2,nvcoord=2,idvt=21,idsl=1,IDVM=0,nopdpvv=$nopdpvv"
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
  mv ${DATA}/gfs_bndy.tile7.nc $OUTDIR/gfs_bndy.tile7.000.nc

#---------------------------------------------------
# Convert surface and nst files one tile at a time.
#---------------------------------------------------
  export CHGRESVARS="use_ufo=.true.,idvc=2,nvcoord=2,idvt=21,idsl=1,IDVM=0,nopdpvv=$nopdpvv"
  export SIGINP=NULL
  export SFCINP=$SFCANL
  export NSTINP=$NSTANL
  export JCAP=$JCAP_CASE
  export LATB=$LATB_SFC
  export LONB=$LONB_SFC

  $CHGRESSH
  mv ${DATA}/out.sfc.tile${TILE_NUM}.nc $OUTDIR/sfc_data.tile${TILE_NUM}.nc
  rc=$?
  if [[ $rc -ne 0 ]] ; then
    echo "***ERROR*** rc= $rc"
    exit $rc
  fi

else # REGIONAL = 2, just generate boundary data

  export CHGRESVARS="use_ufo=.false.,nst_anl=$nst_anl,idvc=2,nvcoord=2,idvt=21,idsl=1,IDVM=0,nopdpvv=$nopdpvv"

  # VDATE here needs to be valid date of GFS BC file
  if [ $tmmark = tm12 ] ; then
    export VDATE=`${NDATE} ${bchour} ${CYCLEGUESS}`
  else
    export VDATE=`${NDATE} ${bchour} ${CDATE}`
  fi
  export PDY=`echo $VDATE | cut -c 1-8`
  echo $tmmark

# force tm00 to get ontime FV3GFS run
  if [ $tmmark != tm00 ] ; then
    $GETGES -t natcur -v $VDATE -e prod atmf${bchour}.nemsio
  else
    export PDYgfs=`echo $CDATE | cut -c 1-8`
    export CYCgfs=`echo $CDATE | cut -c 9-10`
    cp $COMINgfs/gfs.${PDYgfs}/${CYCgfs}/gfs.t${CYCgfs}z.atmf${bchour}.nemsio atmf${bchour}.nemsio
    FV3GFSfile=$COMINgfs/gfs.${PDYgfs}/${CYCgfs}/gfs.t${CYCgfs}z.atmf${bchour}.nemsio
    if [ -s atmf${bchour}.nemsio ] ; then
      echo "$cyc FV3GFS at $bchour hour is available, check file size"
      export sizefile=`du -b atmf${bchour}.nemsio | cut -c 1-11`
      if [ $sizefile = 16986972692 ] ; then
        echo "file size OK"
        echo $FV3GFSfile >> $OUTDIR/filelist.ges${bchour}
      else
        cp $GBCOMINgfs/gfs.${PDYgfs}/${CYCgfs}/gfs.t${CYCgfs}z.atmf${bchour}.nemsio atmf${bchour}.nemsio
        FV3GFSfile=$GBCOMINgfs/gfs.${PDYgfs}/${CYCgfs}/gfs.t${CYCgfs}z.atmf${bchour}.nemsio
        export sizefile=`du -b atmf${bchour}.nemsio | cut -c 1-11`
        if [ $sizefile = 16986972692 ] ; then
          echo "file size OK"
          echo "$cyc FV3GFS at $bchour hour is available from FV3GFS location"
          echo $FV3GFSfile >> $OUTDIR/filelist.ges${bchour}
        else        
          $GETGES -t natcur -v $VDATE -e prod atmf${bchour}.nemsio
          mv filelist.ges $OUTDIR/filelist.ges${bchour}
        fi
      fi
    else
      cp $GBCOMINgfs/gfs.${PDYgfs}/${CYCgfs}/gfs.t${CYCgfs}z.atmf${bchour}.nemsio atmf${bchour}.nemsio
      FV3GFSfile=$GBCOMINgfs/gfs.${PDYgfs}/${CYCgfs}/gfs.t${CYCgfs}z.atmf${bchour}.nemsio
      if [ -s atmf${bchour}.nemsio ] ; then
        echo "$cyc FV3GFS at $bchour hour is available from FV3GFS location"
        echo $FV3GFSfile >> $OUTDIR/filelist.ges${bchour}
      else        
        $GETGES -t natcur -v $VDATE -e prod atmf${bchour}.nemsio
        mv filelist.ges $OUTDIR/filelist.ges${bchour}
      fi
    fi
  fi

# Need to fix this code above, job fails when ATMANL=atmf${bchour}.nemsio
  if [ $tmmark = tm00 ] ; then
    export ATMANL=$INIDIR/${CDUMP}.t${cyc}z.atmf${bchour}.nemsio
  else
    export ATMANL=atmf${bchour}.nemsio
  fi
  export SIGINP=$ATMANL
  export SFCIMP=NULL
 # export NSTINP=NULL
  export LATB=$LATB_ATM
  export LONB=$LONB_ATM

  $CHGRESSH
  rc=$?
  if [[ $rc -ne 0 ]] ; then
    echo "***ERROR*** rc= $rc"
    exit $rc
  fi
  
  if [ -r ${DATA}/gfs_bndy.tile7.nc ]; then
    mv ${DATA}/gfs_bndy.tile7.nc $OUTDIR/gfs_bndy.tile7.${bchour}.nc
  else
    echo "FATAL ERROR: Boundary file was not created successfully."
    err_exit
  fi

fi

exit 0
