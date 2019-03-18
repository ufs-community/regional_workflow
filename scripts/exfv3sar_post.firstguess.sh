#!/bin/ksh

###############################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exfv3sar_post.sh
# Script description:  Runs unified post-processor code to convert FV3SAR history files
#                      to GRIB2 on a rotated lat/lon grid. Use special version of wgrib2
#                      to interpolate the GRIB2 rotated lat/lon grid to the 3 km HRRR 
#                      lambert conformal grid.
#
# Script history log:
# 2018-10-30  Eric Rogers - Modified based on original post script
# 2018-11-09  Ben Blake   - Special version for tm06 first guess
#
###############################################################################

set -x

# First guess at tm06 is a 6-h FV3 fcst from tm12

if [ $tmmark = tm00 ] ; then
  export NEWDATE=`${NDATE} +${fhr} $CYCLE`
else
  offset=`echo $tmmark | cut -c 3-4`
  export vlddate=`${NDATE} - ${offset} $CYCLE`
  export NEWDATE=`${NDATE} + ${fhr} $vlddate`
fi
export YY=`echo $NEWDATE | cut -c1-4`
export MM=`echo $NEWDATE | cut -c5-6`
export DD=`echo $NEWDATE | cut -c7-8`
export HH=`echo $NEWDATE | cut -c9-10`

cat > itag <<EOF
$FCSTDIR/dynf0${fhr}.nc
netcdf
grib2
${YY}-${MM}-${DD}_${HH}:00:00
FV3R
${FCSTDIR}/phyf0${fhr}.nc

 &NAMPGB
 KPO=47,PO=1000.,975.,950.,925.,900.,875.,850.,825.,800.,775.,750.,725.,700.,675.,650.,625.,600.,575.,550.,525.,500.,475.,450.,425.,400.,375.,350.,325.,300.,275.,250.,225.,200.,175.,150.,125.,100.,70.,50.,30.,20.,10.,7.,5.,3.,2.,1.,
 /
EOF

cp $PARMdir/nam_micro_lookup.dat ./eta_micro_lookup.dat
cp $PARMdir/postxconfig-NT-fv3sar.txt ./postxconfig-NT.txt
cp $PARMdir/params_grib2_tbl_new ./params_grib2_tbl_new

export POSTGPEXEC=${EXECfv3}/gfs_ncep_post

export pgm=ncep_post
. prep_step

export APRUN="mpirun -l -n 96"
startmsg
${APRUN} ${POSTGPEXEC} < itag > $pgmout 2>err
export err=$?;err_chk

# RUN wgrib2

WGRIB2=$HOMEdir/exec/wgrib2new

domain=conus
gridspecs="lambert:262.5:38.5:38.5 237.280:1799:3000 21.138:1059:3000"
compress_type=c3

if [ $fhr -eq 00 ] ; then

$WGRIB2 BGDAWP${fhr}.${tmmark} | grep -F -f $PARMdir/nam_nests.hiresf_inst.txt | grep ':anl:' | $WGRIB2 -i -grib inputs.grib${domain}_inst BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${domain}_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation neighbor \
     -new_grid ${gridspecs} ${domain}fv3.hiresf${fhr}.${tmmark}.inst

else

$WGRIB2 BGDAWP${fhr}.${tmmark} | grep -F -f $PARMdir/nam_nests.hiresf_inst.txt | grep 'hour fcst' | $WGRIB2 -i -grib inputs.grib${domain}_inst BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${domain}_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation neighbor \
     -new_grid ${gridspecs} ${domain}fv3.hiresf${fhr}.${tmmark}.inst

fi

$WGRIB2 BGDAWP${fhr}.${tmmark} | grep -F -f $PARMdir/nam_nests.hiresf_nn.txt | $WGRIB2 -i -grib inputs.grib${domain} BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${domain} -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv inputs.grib${domain}.uv
$WGRIB2 BGDAWP${fhr}.${tmmark} -match ":(APCP|WEASD|SNOD):" -grib inputs.grib${domain}.uv_budget

$WGRIB2 inputs.grib${domain}.uv -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_interpolation neighbor -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -new_grid ${gridspecs} ${domain}fv3.hiresf${fhr}.${tmmark}.uv
$WGRIB2 ${domain}fv3.hiresf${fhr}.${tmmark}.uv -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv ${domain}fv3.hiresf${fhr}.${tmmark}.nn

$WGRIB2 inputs.grib${domain}.uv_budget -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_interpolation budget -new_grid ${gridspecs} ${domain}fv3.hiresf${fhr}.${tmmark}.budget
cat ${domain}fv3.hiresf${fhr}.${tmmark}.nn ${domain}fv3.hiresf${fhr}.${tmmark}.budget ${domain}fv3.hiresf${fhr}.${tmmark}.inst > ${domain}fv3.hiresf${fhr}.${tmmark}

#####$WGRIB2 ${domain}fv3.hiresf${fhr}.${tmmark} -s > ${domain}fv3.hiresf${fhr}.${tmmark}.idx

mv ${domain}fv3.hiresf${fhr}.${tmmark} $COMOUT/${RUN}.t${cyc}z.conus.tm06ges.grib2
mv BGDAWP${fhr}.${tmmark} $COMOUT/${RUN}.t${cyc}z.conus.natprs.tm06ges.grib2
mv BGRD3D${fhr}.${tmmark} $COMOUT/${RUN}.t${cyc}z.conus.natlev.tm06ges.grib2

exit
