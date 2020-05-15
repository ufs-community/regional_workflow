#!/bin/ksh
###############################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exfv3cam_post_goes.sh
# Script description:  Runs unified post-processor code to convert FV3 history files
#                      to GRIB2 on a rotated lat/lon grid. Use special version of wgrib2
#                      to interpolate the GRIB2 rotated lat/lon grid to the 3 km HRRR 
#                      lambert conformal grid.
#
# Script history log:
# 2018-10-30  E.Rogers - Modified based on original post script
# 2019-04-12  E.Rogers - Modified Wen's script to post GOES 16/17 brightness temperatures
#
###############################################################################
set -x

if [ $tmmark = tm00 ] ; then
  export NEWDATE=`${NDATE} +${fhr} ${CDATE}`
else
  offset=`echo $tmmark | cut -c 3-4`
  export vlddate=`$NDATE -${offset} ${CDATE}`
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

cp $PARMfv3/nam_micro_lookup.dat           ./eta_micro_lookup.dat
cp $PARMfv3/postxconfig-NT-fv3sar_goes.txt ./postxconfig-NT.txt
cp $PARMfv3/params_grib2_tbl_new           ./params_grib2_tbl_new

#get crtm fix file
#CRTM_FIX from loaded crtm/2.2.x module

for what in "amsre_aqua" "imgr_g11" "imgr_g12" "imgr_g13" \
    "imgr_g15" "imgr_mt1r" "imgr_mt2" "seviri_m10" \
    "ssmi_f13" "ssmi_f14" "ssmi_f15" "ssmis_f16" \
    "ssmis_f17" "ssmis_f18" "ssmis_f19" "ssmis_f20" \
    "tmi_trmm" "v.seviri_m10" "imgr_insat3d" "abi_gr" ; do
    ln -s "${CRTM_FIX}/${what}.TauCoeff.bin" .
    ln -s "${CRTM_FIX}/${what}.SpcCoeff.bin" .
done

for what in 'Aerosol' 'Cloud' ; do
    ln -s "${CRTM_FIX}/${what}Coeff.bin" .
done

for what in  ${CRTM_FIX}/*Emis* ; do
   ln -s $what .
done

# 
# Run the post processor
export pgm=regional_post.x
#JAA . prep_step

#JAA startmsg
${APRUNC} ${POSTGPEXEC} < itag > $pgmout 2>err
#JAA export err=$?; err_chk
export err=$? 

# RUN wgrib2
domain=${dom}

if [ $domain = "conus" ]
then
gridspecs="lambert:262.5:38.5:38.5 237.280:1799:3000 21.138:1059:3000"
elif [ $domain = "ak" ]
then
gridspecs="nps:210:60 185.5:825:5000 44.8:603:5000"
elif [ $domain = "pr" ]
then
gridspecs="latlon 283.41:340:.045 13.5:208:.045"
elif [ $domain = "hi" ]
then
gridspecs="latlon 197.65:223:.045 16.4:170:.045"
elif [ $domain = guam  ]
then
gridspecs="latlon 141.0:223:.045 11.7:170:.045"
fi

compress_type=c3

$WGRIB2 BGGOES${fhr}.${tmmark} -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation neighbor \
     -new_grid ${gridspecs} ${domain}fv3.goestb${fhr}.${tmmark}

mv ${domain}fv3.goestb${fhr}.${tmmark} $COMOUT/${RUN}.t${cyc}z.${dom}goestb.f${fhr}.grib2

echo done > ${INPUT_DATA}/postgoestbdone${fhr}.${tmmark}

exit
