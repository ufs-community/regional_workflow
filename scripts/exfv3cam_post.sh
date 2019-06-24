#!/bin/ksh
############################################################################
# Script name:		exfv3cam_post.sh
# Script description:	Run the post processor jobs to create grib2 output.
# Script history log:
#   1) 2018-08-20	Eric Aligo / Hui-Ya Chuang
#                       Created script to post process output 
#                       from the SAR-FV3.
#   2) 2018-08-23	Ben Blake
#                       Adapted script into EE2-compliant Rocoto workflow.
############################################################################
set -x

if [ $tmmark = tm00 ] ; then
  export NEWDATE=`${NDATE} +${fhr} $CDATE`
else
  offset=`echo $tmmark | cut -c 3-4`
  export vlddate=`${NDATE} -${offset} $CDATE`
  export NEWDATE=`${NDATE} +${fhr} $vlddate`
fi
export YYYY=`echo $NEWDATE | cut -c1-4`
export MM=`echo $NEWDATE | cut -c5-6`
export DD=`echo $NEWDATE | cut -c7-8`
export HH=`echo $NEWDATE | cut -c9-10`

cat > itag <<EOF
${INPUT_DATA}/dynf0${fhr}.nc
netcdf
grib2
${YYYY}-${MM}-${DD}_${HH}:00:00
FV3R
${INPUT_DATA}/phyf0${fhr}.nc

 &NAMPGB
 KPO=47,PO=1000.,975.,950.,925.,900.,875.,850.,825.,800.,775.,750.,725.,700.,675.,650.,625.,600.,575.,550.,525.,500.,475.,450.,425.,400.,375.,350.,325.,300.,275.,250.,225.,200.,175.,150.,125.,100.,70.,50.,30.,20.,10.,7.,5.,3.,2.,1.,
 /
EOF

rm -f fort.*

# copy flat files
cp ${PARMfv3}/nam_micro_lookup.dat      ./eta_micro_lookup.dat
cp ${PARMfv3}/postxconfig-NT-fv3sar.txt ./postxconfig-NT.txt
cp ${PARMfv3}/params_grib2_tbl_new      ./params_grib2_tbl_new

# Run the post processor
export pgm=ncep_post
. prep_step

startmsg
mpirun ${POSTGPEXEC} < itag > $pgmout 2> err
export err=$?; err_chk

# Run wgrib2
domain=conus
gridspecs="lambert:262.5:38.5:38.5 237.280:1799:3000 21.138:1059:3000"
compress_type=c3

if [ $fhr -eq 00 ] ; then
  ${WGRIB2} BGDAWP${fhr}.${tmmark} | grep -F -f ${PARMfv3}/nam_nests.hiresf_inst.txt | grep ':anl:' | ${WGRIB2} -i -grib inputs.grib${domain}_inst BGDAWP${fhr}.${tmmark}
  ${WGRIB2} inputs.grib${domain}_inst -set_bitmap 1 -set_grib_type ${compress_type} \
    -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
    -new_grid_interpolation neighbor \
    -new_grid ${gridspecs} ${domain}${RUN}.f${fhr}.${tmmark}.inst
else
  ${WGRIB2} BGDAWP${fhr}.${tmmark} | grep -F -f ${PARMfv3}/nam_nests.hiresf_inst.txt | grep 'hour fcst' | ${WGRIB2} -i -grib inputs.grib${domain}_inst BGDAWP${fhr}.${tmmark}
  ${WGRIB2} inputs.grib${domain}_inst -set_bitmap 1 -set_grib_type ${compress_type} \
    -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
    -new_grid_interpolation neighbor \
    -new_grid ${gridspecs} ${domain}${RUN}.f${fhr}.${tmmark}.inst
fi

${WGRIB2} BGDAWP${fhr}.${tmmark} | grep -F -f ${PARMfv3}/nam_nests.hiresf_nn.txt | ${WGRIB2} -i -grib inputs.grib${domain} BGDAWP${fhr}.${tmmark}
${WGRIB2} inputs.grib${domain} -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv inputs.grib${domain}.uv
${WGRIB2} BGDAWP${fhr}.${tmmark} -match ":(APCP|WEASD|SNOD):" -grib inputs.grib${domain}.uv_budget

${WGRIB2} inputs.grib${domain}.uv -set_bitmap 1 -set_grib_type ${compress_type} \
  -new_grid_winds grid -new_grid_interpolation neighbor -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
  -new_grid ${gridspecs} ${domain}${RUN}.f${fhr}.${tmmark}.uv
${WGRIB2} ${domain}${RUN}.f${fhr}.${tmmark}.uv -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
  -submsg_uv ${domain}${RUN}.f${fhr}.${tmmark}.nn

${WGRIB2} inputs.grib${domain}.uv_budget -set_bitmap 1 -set_grib_type ${compress_type} \
  -new_grid_winds grid -new_grid_interpolation budget \
  -new_grid ${gridspecs} ${domain}${RUN}.f${fhr}.${tmmark}.budget
cat ${domain}${RUN}.f${fhr}.${tmmark}.nn ${domain}${RUN}.f${fhr}.${tmmark}.budget ${domain}${RUN}.f${fhr}.${tmmark}.inst > ${domain}${RUN}.f${fhr}.${tmmark}

export err=$?; err_chk


# Generate files for FFaIR

#${WGRIB2} BGDAWP${fhr}.${tmmark} | grep -F -f ${PARMfv3}/nam_nests.hiresf_ffair.txt | ${WGRIB2} -i -grib inputs.grib${domain}_ffair BGDAWP${fhr}.${tmmark}
#${WGRIB2} inputs.grib${domain}_ffair -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv inputs.grib${domain}.uv_ffair
#${WGRIB2} inputs.grib${domain}.uv_ffair -set_bitmap 1 -set_grib_type ${compress_type} \
#  -new_grid_winds grid -new_grid_interpolation neighbor -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
#  -new_grid ${gridspecs} ${domain}${RUN}.f${fhr}.${tmmark}.uv_ffair
#${WGRIB2} ${domain}${RUN}.f${fhr}.${tmmark}.uv_ffair -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
#  -submsg_uv ${domain}${RUN}.f${fhr}.${tmmark}.ffair
#cat ${domain}${RUN}.f${fhr}.${tmmark}.ffair ${domain}${RUN}.f${fhr}.${tmmark}.budget > ${domain}${RUN}.f${fhr}.${tmmark}.ffair

#export err=$?; err_chk

if [ $SENDCOM = YES ]
then
  if [ $tmmark = tm00 ] ; then
    mv ${domain}${RUN}.f${fhr}.${tmmark} ${COMOUT}/${RUN}.t${cyc}z.${domain}.f${fhr}.grib2
#    mv ${domain}${RUN}.f${fhr}.${tmmark}.ffair ${COMOUT}/${RUN}.t${cyc}z.${domain}.ffair.f${fhr}.grib2
    mv BGDAWP${fhr}.${tmmark} ${COMOUT}/${RUN}.t${cyc}z.${domain}.natprs.f${fhr}.grib2
    mv BGRD3D${fhr}.${tmmark} ${COMOUT}/${RUN}.t${cyc}z.${domain}.natlev.f${fhr}.grib2
  else
    mv ${domain}${RUN}.f${fhr}.${tmmark} ${COMOUT}/${RUN}.t${cyc}z.${domain}.f${fhr}.${tmmark}.grib2
    mv BGDAWP${fhr}.${tmmark} ${COMOUT}/${RUN}.t${cyc}z.${domain}.natprs.f${fhr}.${tmmark}.grib2
    mv BGRD3D${fhr}.${tmmark} ${COMOUT}/${RUN}.t${cyc}z.${domain}.natlev.f${fhr}.${tmmark}.grib2
  fi
fi

echo done > ${INPUT_DATA}/postdone${fhr}.${tmmark}

exit
