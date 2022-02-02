#!/bin/bash

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#
. ${GLOBAL_VAR_DEFNS_FP}
. $USHDIR/source_util_funcs.sh
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; set -u -x; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
scrfunc_fn=$( basename "${scrfunc_fp}" )
scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Print message indicating entry into script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
Entering script:  \"${scrfunc_fn}\"
In directory:     \"${scrfunc_dir}\"

This is the ex-script for the task that runs a analysis with FV3 for the
specified cycle.
========================================================================"
#
#-----------------------------------------------------------------------
#
# Specify the set of valid argument names for this script/function.  
# Then process the arguments provided to this script/function (which 
# should consist of a set of name-value pairs of the form arg1="value1",
# etc).
#
#-----------------------------------------------------------------------
#
valid_args=( "CYCLE_DIR" "ANL_WORKDIR" )
process_args valid_args "$@"
#
#-----------------------------------------------------------------------
#
# For debugging purposes, print out values of arguments passed to this
# script.  Note that these will be printed out only if VERBOSE is set to
# TRUE.
#
#-----------------------------------------------------------------------
#
print_input_args valid_args
#
#-----------------------------------------------------------------------
#
# Set and export variables.
#
#-----------------------------------------------------------------------
#
export OMP_NUM_THREADS=1
export OMP_STACKSIZE=2056M
#
#-----------------------------------------------------------------------
#
# Load modules.
#
#-----------------------------------------------------------------------
#
case $MACHINE in
#
"HERA")
  ulimit -s unlimited
  ulimit -a
  APRUN="srun"
  LD_LIBRARY_PATH="${UFS_WTHR_MDL_DIR}/FV3/ccpp/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  ;;
#
esac
#
#-----------------------------------------------------------------------
#
# Extract from CDATE the starting year, month, day, and hour of the
# forecast.  These are needed below for various operations.
#
#-----------------------------------------------------------------------
#
START_DATE=$( echo "${CDATE}" | sed 's/\([[:digit:]]\{2\}\)$/ \1/' )

yyyymmddhh=$( date +%Y%m%d%H -d "${START_DATE}" )
JJJ=$( date +%j -d "${START_DATE}" )

yyyy=${yyyymmddhh:0:4}
mm=${yyyymmddhh:4:2}
dd=${yyyymmddhh:6:2}
hh=${yyyymmddhh:8:2}
yyyymmdd=${yyyymmddhh:0:8}
#
#-----------------------------------------------------------------------
#
# GO TO WOrking directory.
# define fix and background path
#
#-----------------------------------------------------------------------

cd_vrfy ${ANL_WORKDIR}
fixdir=$FIXgsi
fixgriddir=$FIXgsi/${PREDEF_GRID_NAME}
DA_CYCLE_INTERV=${INCR_CYCL_FREQ}
if [ ${BKTYPE} -eq 1 ]; then  # cold start, use background from INPUT
  bkpath=${CYCLE_DIR}/INPUT
else
  YYYYMMDDHHmInterv=$( date +%Y%m%d%H -d "${START_DATE} ${DA_CYCLE_INTERV} hours ago" )
  bkpath=${CYCLE_BASEDIR}/${YYYYMMDDHHmInterv}/RESTART  # cycling, use background from RESTART
fi

print_info_msg "$VERBOSE" "fixdir is $fixdir"
print_info_msg "$VERBOSE" "fixgriddir is $fixgriddir"
print_info_msg "$VERBOSE" "default bkpath is $bkpath"


#-----------------------------------------------------------------------
#
# Make a list of the latest GFS EnKF ensemble
#
#-----------------------------------------------------------------------
if [ ! -z $ENKF_FCST ]; then  
stampcycle=$( date -d "${START_DATE}" +%s )
minHourDiff=100
loops="009"
for loop in $loops; do
  for timelist in $( ls ${ENKF_FCST}/*.gdas.t*z.atmf${loop}s.mem080.nemsio ); do
    availtimeyy=$( basename ${timelist} | cut -c 1-2 )
    availtimeyyyy=20${availtimeyy}
    availtimejjj=$( basename ${timelist} | cut -c 3-5 )
    availtimemm=$( date -d "${availtimeyyyy}0101 +$(( 10#${availtimejjj} - 1 )) days" +%m )
    availtimedd=$( date -d "${availtimeyyyy}0101 +$(( 10#${availtimejjj} - 1 )) days" +%d )
    availtimehh=$( basename ${timelist} | cut -c 6-7 )
    availtime=${availtimeyyyy}${availtimemm}${availtimedd}${availtimehh}
    AVAIL_TIME=$( echo "${availtime}" | sed 's/\([[:digit:]]\{2\}\)$/ \1/' )
    AVAIL_TIME=$( date -d "${AVAIL_TIME}" )

    stamp_avail=$( date -d "${AVAIL_TIME} ${loop} hours" +%s )

    hourDiff=$( echo "($stampcycle - $stamp_avail) / (60 * 60 )" | bc );
    if [[ ${stampcycle} -lt ${stamp_avail} ]]; then
       hourDiff=$( echo "($stamp_avail - $stampcycle) / (60 * 60 )" | bc );
    fi

    if [[ ${hourDiff} -lt ${minHourDiff} ]]; then
       minHourDiff=${hourDiff}
       enkfcstname=${availtimeyy}${availtimejjj}${availtimehh}00.gdas.t${availtimehh}z.atmf${loop}s
    fi
  done
done

size=$( du --apparent-size --block-size=1 --dereference ${ENKF_FCST}/${enkfcstname}.mem001.nemsio | grep -o '..........' | sed -n '1 p' )
ls ${ENKF_FCST}/${enkfcstname}.mem001.nemsio > filelist03

n=2
while [[ $n -le 80 ]] ; do
  
  if [ $n -lt 10  ]; then
    nn=00$n
  else
    nn=0$n
  fi

  size2=$( du --apparent-size --block-size=1 --dereference ${ENKF_FCST}/${enkfcstname}.mem${nn}.nemsio | grep -o '..........' | sed -n '1 p' )

  if [[ $size2 -lt $size ]]; then
    print_info_msg "$VERBOSE"  "Bad GDAS member number ${nn}."
  else
    ls ${ENKF_FCST}/${enkfcstname}.mem${nn}.nemsio >> filelist03
  fi

  n=$((n + 1))

done


#
#-----------------------------------------------------------------------
#
# set default values for namelist
#
#-----------------------------------------------------------------------

cloudanalysistype=0
ifsatbufr=.false.
ifsoilnudge=.false.
beta1_inv=1.0
ifhyb=.false.

# Determine if hybrid option is available
memname='atmf009'
nummem=$( more filelist03 | wc -l )
nummem=$((nummem - 3 ))
if [[ ${nummem} -eq 80 ]]; then
  print_info_msg "$VERBOSE" "Do hybrid with ${memname}"
  beta1_inv=0.15
  ifhyb=.true.
  print_info_msg "$VERBOSE" " Cycle ${yyyymmddhh}: GSI hybrid uses ${memname} with n_ens=${nummem}" 
fi

fi # ENKF ensemble 

# 3dvar, not hybrid
ifhyb=.false.

#
#-----------------------------------------------------------------------
#
# link or copy background and grib configuration files
#
#  Using ncks to add phis (terrain) into cold start input background. 
#           it is better to change GSI to use the terrain from fix file.
#  Adding radar_tten array to fv3_tracer. Should remove this after add this array in
#           radar_tten converting code.
#-----------------------------------------------------------------------

FV3SARPATH=${CYCLE_DIR}
cp_vrfy ${fixgriddir}/fv3_akbk                     fv3_akbk
cp_vrfy ${fixgriddir}/fv3_grid_spec                fv3_grid_spec

if [ ${BKTYPE} -eq 1 ]; then  # cold start uses background from INPUT
  cp_vrfy ${bkpath}/gfs_data.tile7.halo0.nc        gfs_data.tile7.halo0.nc_b
  ncks -A -v  phis ${fixgriddir}/phis.nc        gfs_data.tile7.halo0.nc_b

  cp_vrfy ${bkpath}/sfc_data.tile7.halo0.nc        fv3_sfcdata
  cp_vrfy gfs_data.tile7.halo0.nc_b                fv3_dynvars
  ln_vrfy -s fv3_dynvars                           fv3_tracer

  fv3sar_bg_type=1
else                          # cycle uses background from restart
  if [ ${DA_CYCLE_INTERV} -eq ${FCST_LEN_HRS} ]; then
    restart_prefix=""
  elif [ ${DA_CYCLE_INTERV} -lt ${FCST_LEN_HRS} ]; then
    restart_prefix=${yyyymmdd}.${hh}0000
  else
    print_err_msg_exit "\
    Restart hour should not larger than forecast hour:
    Restart Hour = \"${DA_CYCLE_INTERV}\"
    Forecast Hour = \"${FCST_LEN_HRS}\""    
    exit 1
  fi

#   let us figure out which backgound is available
  
  n=${DA_CYCLE_INTERV}
  while [[ $n -le 6 ]] ; do
    checkfile=${bkpath}/${restart_prefix}.fv_core.res.tile1.nc
    if [ -r "${checkfile}" ]; then
      print_info_msg "$VERBOSE" "Found ${checkfile}; Use it as background for analysis "
      break
    else
      n=$((n + ${DA_CYCLE_INTERV}))
      YYYYMMDDHHmInterv=$( date +%Y%m%d%H -d "${START_DATE} ${n} hours ago" )
      bkpath=${CYCLE_BASEDIR}/${YYYYMMDDHHmInterv}/RESTART  # cycling, use background from RESTART
      print_info_msg "$VERBOSE" "Trying this path: ${bkpath}"
    fi
  done
#
  checkfile=${bkpath}/${restart_prefix}.fv_core.res.tile1.nc
  if [ -r "${checkfile}" ]; then
    cp_vrfy  ${bkpath}/${restart_prefix}.fv_core.res.tile1.nc             fv3_dynvars
    cp_vrfy  ${bkpath}/${restart_prefix}.fv_tracer.res.tile1.nc           fv3_tracer
    cp_vrfy  ${bkpath}/${restart_prefix}.sfc_data.nc                      fv3_sfcdata
  else
    print_info_msg_exit "$VERBOSE" "Error: cannot find background: ${checkfile}"
  fi
  fv3sar_bg_type=0
fi

# update times in coupler.res to current cycle time
cp_vrfy ${fixgriddir}/fv3_coupler.res          coupler.res.tmp
cat coupler.res.tmp  | sed "s/yyyy/${yyyy}/" > coupler.res.newY
cat coupler.res.newY | sed "s/mm/${mm}/"     > coupler.res.newM
cat coupler.res.newM | sed "s/dd/${dd}/"     > coupler.res.newD
cat coupler.res.newD | sed "s/hh/${hh}/"     > coupler.res.newH
mv coupler.res.newH coupler.res
rm coupler.res.newY coupler.res.newM coupler.res.newD

#
#-----------------------------------------------------------------------
#
# link observation files
# copy observation files to working directory 
#
#-----------------------------------------------------------------------

obs_files_source[0]=${OBSPATH}/${yyyymmddhh}.rap.t${hh}z.prepbufr.tm00
obs_files_target[0]=prepbufr

obs_files_source[1]=${OBSPATH}/${yyyymmddhh}.rap.t${hh}z.satwnd.tm00.bufr_d
obs_files_target[1]=satwndbufr

obs_files_source[2]=${OBSPATH}/${yyyymmddhh}.rap.t${hh}z.nexrad.tm00.bufr_d
obs_files_target[2]=l2rwbufr

obs_files_source[3]=${PMPATH}/${yyyymmdd}/pm25.airnow.${yyyymmddhh}.bufr
obs_files_target[3]=pm25bufr

obs_number=${#obs_files_source[@]}
for (( i=0; i<${obs_number}; i++ ));
do
  obs_file=${obs_files_source[$i]}
  obs_file_t=${obs_files_target[$i]}
  if [ -r "${obs_file}" ]; then
    ln -s "${obs_file}" "${obs_file_t}"
  else
    print_info_msg "$VERBOSE" "Warning: ${obs_file} does not exist!"
  fi
done
ln -sf ${AODPATH}/j01/${yyyymmddhh}/VIIRS.AOD.EVENT.Prepbufr.${hh}H.QC1 aod.j01.bufr1
ln -sf ${AODPATH}/j01/${yyyymmddhh}/VIIRS.AOD.Prepbufr.${hh}H.QC1       aod.j01.bufr2
ln -sf ${AODPATH}/npp/${yyyymmddhh}/VIIRS.AOD.EVENT.Prepbufr.${hh}H.QC1 aod.npp.bufr1
ln -sf ${AODPATH}/npp/${yyyymmddhh}/VIIRS.AOD.Prepbufr.${hh}H.QC1       aod.npp.bufr2

#-----------------------------------------------------------------------
#
# Create links to fix files in the FIXgsi directory.
# Set fixed files
#   berror   = forecast model background error statistics
#   specoef  = CRTM spectral coefficients
#   trncoef  = CRTM transmittance coefficients
#   emiscoef = CRTM coefficients for IR sea surface emissivity model
#   aerocoef = CRTM coefficients for aerosol effects
#   cldcoef  = CRTM coefficients for cloud effects
#   satinfo  = text file with information about assimilation of brightness temperatures
#   satangl  = angle dependent bias correction file (fixed in time)
#   pcpinfo  = text file with information about assimilation of prepcipitation rates
#   ozinfo   = text file with information about assimilation of ozone data
#   errtable = text file with obs error for conventional data (regional only)
#   convinfo = text file with information about assimilation of conventional data
#   bufrtable= text file ONLY needed for single obs test (oneobstest=.true.)
#   bftab_sst= bufr table for sst ONLY needed for sst retrieval (retrieval=.true.)
#
#-----------------------------------------------------------------------

# anavinfo_fv3lam_cmaq: individual aerosol species
# anavinfo_cvijk_fv3lam_cmaq: CV total mass per mode
#anavinfo=${fixdir}/anavinfo_fv3lam_cmaq
anavinfo=${fixdir}/anavinfo_cvijk_fv3lam_cmaq

#BERROR=${fixdir}/berror_stats_fv3lam_cmaq
BERROR=${fixdir}/fv3lamcmaq-gsi_be_big_endian.gcv

SATINFO=${fixdir}/global_satinfo.txt
CONVINFO=${fixgriddir}/regional_convinfo_fv3lam_cmaq
OZINFO=${fixdir}/global_ozinfo.txt
PCPINFO=${fixdir}/global_pcpinfo.txt
AEROINFO=${fixdir}/aeroinfo
OBERROR=${fixdir}/nam_errtable.r3dv
ATMS_BEAMWIDTH=${fixdir}/atms_beamwidth.txt

# Fixed fields
cp_vrfy "${anavinfo}" "anavinfo"
cp_vrfy "${BERROR}"   "berror_stats"
cp_vrfy $SATINFO  satinfo
cp_vrfy $CONVINFO convinfo
cp_vrfy $OZINFO   ozinfo
cp_vrfy $PCPINFO  pcpinfo
cp_vrfy $AEROINFO aeroinfo
cp_vrfy $OBERROR  errtable
cp_vrfy $ATMS_BEAMWIDTH atms_beamwidth.txt

cp_vrfy ${fixdir}/hybens_info_rrfs hybens_info

# Get aircraft reject list and surface uselist
cp_vrfy ${AIRCRAFT_REJECT}/current_bad_aircraft.txt current_bad_aircraft

sfcuselists=gsd_sfcobs_uselist.txt
sfcuselists_path=${SFCOBS_USELIST}
cp_vrfy ${sfcuselists_path}/${sfcuselists} gsd_sfcobs_uselist.txt
cp_vrfy ${fixdir}/gsd_sfcobs_provider.txt gsd_sfcobs_provider.txt


#-----------------------------------------------------------------------
#
# CRTM Spectral and Transmittance coefficients
#
#-----------------------------------------------------------------------
CRTMFIX=${FIXcrtm}
emiscoef_IRwater=${CRTMFIX}/Nalli.IRwater.EmisCoeff.bin
emiscoef_IRice=${CRTMFIX}/NPOESS.IRice.EmisCoeff.bin
emiscoef_IRland=${CRTMFIX}/NPOESS.IRland.EmisCoeff.bin
emiscoef_IRsnow=${CRTMFIX}/NPOESS.IRsnow.EmisCoeff.bin
emiscoef_VISice=${CRTMFIX}/NPOESS.VISice.EmisCoeff.bin
emiscoef_VISland=${CRTMFIX}/NPOESS.VISland.EmisCoeff.bin
emiscoef_VISsnow=${CRTMFIX}/NPOESS.VISsnow.EmisCoeff.bin
emiscoef_VISwater=${CRTMFIX}/NPOESS.VISwater.EmisCoeff.bin
emiscoef_MWwater=${CRTMFIX}/FASTEM6.MWwater.EmisCoeff.bin
cldcoef=${CRTMFIX}/CloudCoeff.bin
if [ ${AOD_LUTS} -eq 1 ]; then
   aercoef=${CRTMFIX}/AerosolCoeff.GOCART-GEOS5.bin
else
   aercoef=${CRTMFIX}/AerosolCoeff.bin
fi

ln -s $aercoef  .
ln -s ${CRTMFIX}/v.viirs-m_j1.SpcCoeff.bin .
ln -s ${CRTMFIX}/v.viirs-m_j1.TauCoeff.bin .
ln -s ${emiscoef_IRwater} Nalli.IRwater.EmisCoeff.bin
ln -s $emiscoef_IRice ./NPOESS.IRice.EmisCoeff.bin
ln -s $emiscoef_IRsnow ./NPOESS.IRsnow.EmisCoeff.bin
ln -s $emiscoef_IRland ./NPOESS.IRland.EmisCoeff.bin
ln -s $emiscoef_VISice ./NPOESS.VISice.EmisCoeff.bin
ln -s $emiscoef_VISland ./NPOESS.VISland.EmisCoeff.bin
ln -s $emiscoef_VISsnow ./NPOESS.VISsnow.EmisCoeff.bin
ln -s $emiscoef_VISwater ./NPOESS.VISwater.EmisCoeff.bin
ln -s $emiscoef_MWwater ./FASTEM6.MWwater.EmisCoeff.bin
ln -s $cldcoef  ./CloudCoeff.bin


# Copy CRTM coefficient files based on entries in satinfo file
for file in $( awk '{if($1!~"!"){print $1}}' ./satinfo | sort | uniq ) ;do
   ln -s ${CRTMFIX}/${file}.SpcCoeff.bin ./
   ln -s ${CRTMFIX}/${file}.TauCoeff.bin ./
done



## satellite bias correction
#if [ ${FULLCYC} -eq 1 ]; then
#   latest_bias=${DATAHOME_PBK}/satbias/satbias_out_latest
#   latest_bias_pc=${DATAHOME_PBK}/satbias/satbias_pc.out_latest
#   latest_radstat=${DATAHOME_PBK}/satbias/radstat.rap_latest
#fi

# cp $latest_bias ./satbias_in
# cp $latest_bias_pc ./satbias_pc
# cp $latest_radstat ./radstat.rap
# listdiag=$( tar xvf radstat.rap | cut -d' ' -f2 | grep _ges )
# for type in $listdiag; do
#       diag_file=$( echo $type | cut -d',' -f1 )
#       fname=$( echo $diag_file | cut -d'.' -f1 )
#       date=$( echo $diag_file | cut -d'.' -f2 )
#       gunzip $diag_file
#       fnameanl=$(echo $fname|sed 's/_ges//g')
#       mv $fname.$date $fnameanl
# done
#
#mv radstat.rap  radstat.rap.for_this_cycle

#-----------------------------------------------------------------------
#
# Build namelist and run GSI
#
#-----------------------------------------------------------------------
# Link the AMV bufr file
ifsatbufr=.false.

# Set some parameters for use by the GSI executable and to build the namelist
grid_ratio=1
cloudanalysistype=0


# Build the GSI namelist on-the-fly
. ${fixgriddir}/gsiparm.anl.sh
cat << EOF > gsiparm.anl
$gsi_namelist
EOF

#
#-----------------------------------------------------------------------
#
# Copy the GSI executable to the run directory.
#
#-----------------------------------------------------------------------
#
GSI_EXEC="${EXECDIR}/gsi.x"

if [ -f $GSI_EXEC ]; then
  print_info_msg "$VERBOSE" "
Copying the GSI executable to the run directory..."
  cp_vrfy ${GSI_EXEC} ${ANL_WORKDIR}/gsi.x
else
  print_err_msg_exit "\
The GSI executable specified in GSI_EXEC does not exist:
  GSI_EXEC = \"$GSI_EXEC\"
Build GSI and rerun."
fi
#
#-----------------------------------------------------------------------
#
# Run the GSI.  Note that we have to launch the forecast from
# the current cycle's run directory because the GSI executable will look
# for input files in the current directory.
#
#-----------------------------------------------------------------------
#
# comment out for testing
$APRUN ./gsi.x < gsiparm.anl > stdout 2>&1 || print_err_msg_exit "\
Call to executable to run GSI returned with nonzero exit code."


#-----------------------------------------------------------------------
#
# Copy analysis results to INPUT for model forecast.
#
#-----------------------------------------------------------------------
#

if [ ${BKTYPE} -eq 1 ]; then  # cold start, put analysis back to current INPUT 
  cp ${ANL_WORKDIR}/fv3_dynvars ${CYCLE_DIR}/INPUT/gfs_data.tile7.halo0.nc
  cp ${ANL_WORKDIR}/fv3_sfcdata ${CYCLE_DIR}/INPUT/sfc_data.tile7.halo0.nc

else                          # cycling, generate INPUT from previous cycle RESTART and GSI analysis
  cp_vrfy ${bkpath}/${restart_prefix}.fv_tracer.res.tile1.nc    ${bkpath}/${restart_prefix}.fv_tracer.res.tile1.nc.org
  cp_vrfy ${ANL_WORKDIR}/fv3_tracer                             ${bkpath}/${restart_prefix}.fv_tracer.res.tile1.nc          

  # for warm start               
  #cp_vrfy ${bkpath}/${restart_prefix}.coupler.res               ${CYCLE_DIR}/INPUT/coupler.res
  #cp_vrfy ${bkpath}/${restart_prefix}.fv_core.res.nc            ${CYCLE_DIR}/INPUT/fv_core.res.nc
  #cp_vrfy ${bkpath}/${restart_prefix}.fv_srf_wnd.res.tile1.nc   ${CYCLE_DIR}/INPUT/fv_srf_wnd.res.tile1.nc
  #cp_vrfy ${bkpath}/${restart_prefix}.phy_data.nc               ${CYCLE_DIR}/INPUT/phy_data.nc
  #cp_vrfy ${ANL_WORKDIR}/fv3_dynvars                            ${CYCLE_DIR}/INPUT/fv_core.res.tile1.nc
  #cp_vrfy ${ANL_WORKDIR}/fv3_tracer                             ${CYCLE_DIR}/INPUT/fv_tracer.res.tile1.nc
  #cp_vrfy ${ANL_WORKDIR}/fv3_sfcdata                            ${CYCLE_DIR}/INPUT/sfc_data.nc
  #cp_vrfy ${CYCLE_BASEDIR}/${YYYYMMDDHHmInterv}/INPUT/gfs_ctrl.nc  ${CYCLE_DIR}/INPUT/gfs_ctrl.nc

fi


#-----------------------------------------------------------------------
# Loop over first and last outer loops to generate innovation
# diagnostic files for indicated observation types (groups)
#
# NOTE:  Since we set miter=2 in GSI namelist SETUP, outer
#        loop 03 will contain innovations with respect to 
#        the analysis.  Creation of o-a innovation files
#        is triggered by write_diag(3)=.true.  The setting
#        write_diag(1)=.true. turns on creation of o-g
#        innovation files.
#-----------------------------------------------------------------------
#

netcdf_diag=${netcdf_diag:-".false."}
binary_diag=${binary_diag:-".true."}

loops="01 03"
for loop in $loops; do

case $loop in
  01) string=ges;;
  03) string=anl;;
   *) string=$loop;;
esac

#  Collect diagnostic files for obs types (groups) below
if [ $binary_diag = ".true." ]; then
   listall="conv hirs2_n14 msu_n14 sndr_g08 sndr_g11 sndr_g11 sndr_g12 sndr_g13 sndr_g08_prep sndr_g11_prep sndr_g12_prep sndr_g13_prep sndrd1_g11 sndrd2_g11 sndrd3_g11 sndrd4_g11 sndrd1_g12 sndrd2_g12 sndrd3_g12 sndrd4_g12 sndrd1_g13 sndrd2_g13 sndrd3_g13 sndrd4_g13 hirs3_n15 hirs3_n16 hirs3_n17 amsua_n15 amsua_n16 amsua_n17 amsub_n15 amsub_n16 amsub_n17 hsb_aqua airs_aqua amsua_aqua imgr_g08 imgr_g11 imgr_g12 pcp_ssmi_dmsp pcp_tmi_trmm sbuv2_n16 sbuv2_n17 sbuv2_n18 omi_aura ssmi_f13 ssmi_f14 ssmi_f15 hirs4_n18 hirs4_metop-a amsua_n18 amsua_metop-a mhs_n18 mhs_metop-a amsre_low_aqua amsre_mid_aqua amsre_hig_aqua ssmis_las_f16 ssmis_uas_f16 ssmis_img_f16 ssmis_env_f16 iasi_metop-a"
   for type in $listall; do
      count=$( ls pe*.${type}_${loop} | wc -l )
      if [[ $count -gt 0 ]]; then
         $( cat pe*.${type}_${loop} > diag_${type}_${string}.${yyyymmddhh} )
      fi
   done
fi

if [ $netcdf_diag = ".true." ]; then
   listallnc="conv_ps conv_q conv_t conv_uv"

   CAT_EXEC="${EXECDIR}/ncdiag_cat.x"

   if [ -f $CAT_EXEC ]; then
      print_info_msg "$VERBOSE" "
        Copying the ncdiag_cat executable to the run directory..."
      cp_vrfy ${CAT_EXEC} ${ANL_WORKDIR}/ncdiag_cat.x
   else
      print_err_msg_exit "\
        The ncdiag_cat executable specified in CAT_EXEC does not exist:
        CAT_EXEC = \"$CAT_EXEC\"
        Build GSI and rerun."
   fi

   for type in $listallnc; do
      count=$( ls pe*.${type}_${loop}.nc4 | wc -l )
      if [[ $count -gt 0 ]]; then
         ./ncdiag_cat.x -o ncdiag_${type}_${string}.nc4.${yyyymmddhh} pe*.${type}_${loop}.nc4
      fi
   done
fi

done

#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
ANALYSIS GSI completed successfully!!!

Exiting script:  \"${scrfunc_fn}\"
In directory:    \"${scrfunc_dir}\"
========================================================================"
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/func-
# tion.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1

