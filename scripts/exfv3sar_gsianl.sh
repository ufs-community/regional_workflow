#!/bin/ksh

###############################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exfv3sar_gsianl.sh
# Script description:  Runs FV3SAR GSI analysis for the hourly DA cycle
#                      Uses RAP observations and Fv3GDAS EnKF files for the hybrid
#                      analysis. Create conventional and radiance stat files for monitoring
#
# Script history log:
# 2018-10-30  Eric Rogers - Modified based on original GSI script
# 2018-11-09  Ben Blake   - Moved various settings into J-job script
#
###############################################################################

set -x

offset=`echo $tmmark | cut -c 3-4`

case $tmmark in
  tm06) export tmmark_prev=tm06;;
  tm05) export tmmark_prev=tm06;;
  tm04) export tmmark_prev=tm05;;
  tm03) export tmmark_prev=tm04;;
  tm02) export tmmark_prev=tm03;;
  tm01) export tmmark_prev=tm02;;
  tm00) export tmmark_prev=tm01;;
esac

# Set runtime and save directories
export endianness=Big_Endian

# Set variables used in script
#   ncp is cp replacement, currently keep as /bin/cp
ncp=/bin/cp

export HYB_ENS=".true."

# We expect 81 total files to be present (80 enkf + 1 mean)
export nens=81

# Not using FGAT or 4DEnVar, so hardwire nhr_assimilation to 3
export nhr_assimilation=03
##typeset -Z2 nhr_assimilation

python $UTIL/getbest_EnKF_FV3GDAS.py -v $vlddate --exact=no --minsize=${nens} -d ${COMINgfspll}/enkfgdas -o filelist${nhr_assimilation} --o3fname=gfs_sigf${nhr_assimilation} --gfs_nemsio=yes

#Check to see if ensembles were found 
numfiles=`cat filelist03 | wc -l`
cp filelist03 $COMOUT/${RUN}.t${CYCrun}z.filelist03.${tmmark}

if [ $numfiles -ne 81 ]; then
  echo "Ensembles not found - turning off HYBENS!"
  export HYB_ENS=".false."
else
  # we have 81 files, figure out if they are all the right size
  # if not, set HYB_ENS=false
  . $UTIL/check_enkf_size.sh
fi

echo "HYB_ENS=$HYB_ENS" > $COMOUT/${RUN}.t${CYCrun}z.hybens.${tmmark}

nens=`cat filelist03 | wc -l`

# Set parameters
export USEGFSO3=.false.
export nhr_assimilation=3.
export vs=1.
export fstat=.false.
export i_gsdcldanal_type=0
use_gfs_nemsio=.true.,

# Make gsi namelist
cat << EOF > gsiparm.anl

 &SETUP
   miter=2,niter(1)=50,niter(2)=50,niter_no_qc(1)=20,
   write_diag(1)=.true.,write_diag(2)=.false.,write_diag(3)=.true.,
   gencode=78,qoption=2,
   factqmin=0.0,factqmax=0.0,
   iguess=-1,use_gfs_ozone=${USEGFSO3},
   oneobtest=.false.,retrieval=.false.,
   nhr_assimilation=${nhr_assimilation},l_foto=.false.,
   use_pbl=.false.,gpstop=30.,
   use_gfs_nemsio=.true.,
   print_diag_pcg=.true.,
   newpc4pred=.true., adp_anglebc=.true., angord=4,
   passive_bc=.true., use_edges=.false., emiss_bc=.true.,
   diag_precon=.true., step_start=1.e-3,
 /
 &GRIDOPTS
   fv3_regional=.true.,grid_ratio_fv3_regional=3.0,nvege_type=20,
 /
 &BKGERR
   hzscl=0.373,0.746,1.50,
   vs=${vs},bw=0.,fstat=${fstat},
 /
 &ANBKGERR
   anisotropic=.false.,
 /
 &JCOPTS
 /
 &STRONGOPTS
   nstrong=0,
 /
 &OBSQC
   dfact=0.75,dfact1=3.0,noiqc=.false.,c_varqc=0.02,
   vadfile='prepbufr',njqc=.false.,vqc=.true.,
   aircraft_t_bc=.true.,biaspredt=1000.0,upd_aircraft=.true.,cleanup_tail=.true.,
 /
 &OBS_INPUT
   dmesh(1)=120.0,time_window_max=1.5,ext_sonde=.true.,
 /
OBS_INPUT::
!  dfile          dtype       dplat       dsis                  dval    dthin  dsfcalc
   prepbufr       ps          null        ps                  0.0     0     0
   prepbufr       t           null        t                   0.0     0     0
   prepbufr_profl t           null        t                   0.0     0     0
   prepbufr       q           null        q                   0.0     0     0
   prepbufr_profl q           null        q                   0.0     0     0
   prepbufr       pw          null        pw                  0.0     0     0
   prepbufr       uv          null        uv                  0.0     0     0
   prepbufr_profl uv          null        uv                  0.0     0     0
   satwndbufr     uv          null        uv                  0.0     0     0
   prepbufr       spd         null        spd                 0.0     0     0
   prepbufr       dw          null        dw                  0.0     0     0
   l2rwbufr       rw          null        l2rw                0.0     0     0
   prepbufr       sst         null        sst                 0.0     0     0
   nsstbufr       sst         nsst        sst                 0.0     0     0
   gpsrobufr      gps_bnd     null        gps                 0.0     0     0
   hirs3bufr      hirs3       n17         hirs3_n17           0.0     1     0
   hirs4bufr      hirs4       metop-a     hirs4_metop-a       0.0     1     1
   gimgrbufr      goes_img    g11         imgr_g11            0.0     1     0
   gimgrbufr      goes_img    g12         imgr_g12            0.0     1     0
   airsbufr       airs        aqua        airs281SUBSET_aqua  0.0     1     1
   amsuabufr      amsua       n15         amsua_n15           0.0     1     1
   amsuabufr      amsua       n18         amsua_n18           0.0     1     1
   amsuabufr      amsua       metop-a     amsua_metop-a       0.0     1     1
   airsbufr       amsua       aqua        amsua_aqua          0.0     1     1
   amsubbufr      amsub       n17         amsub_n17           0.0     1     1
   mhsbufr        mhs         n18         mhs_n18             0.0     1     1
   mhsbufr        mhs         metop-a     mhs_metop-a         0.0     1     1
   ssmitbufr      ssmi        f14         ssmi_f14            0.0     1     0
   ssmitbufr      ssmi        f15         ssmi_f15            0.0     1     0
   amsrebufr      amsre_low   aqua        amsre_aqua          0.0     1     0
   amsrebufr      amsre_mid   aqua        amsre_aqua          0.0     1     0
   amsrebufr      amsre_hig   aqua        amsre_aqua          0.0     1     0
   ssmisbufr      ssmis       f16         ssmis_f16           0.0     1     0
   ssmisbufr      ssmis       f17         ssmis_f17           0.0     1     0
   ssmisbufr      ssmis       f18         ssmis_f18           0.0     1     0
   ssmisbufr      ssmis       f19         ssmis_f19           0.0     1     0
   gsnd1bufr      sndrd1      g12         sndrD1_g12          0.0     1     0
   gsnd1bufr      sndrd2      g12         sndrD2_g12          0.0     1     0
   gsnd1bufr      sndrd3      g12         sndrD3_g12          0.0     1     0
   gsnd1bufr      sndrd4      g12         sndrD4_g12          0.0     1     0
   gsnd1bufr      sndrd1      g11         sndrD1_g11          0.0     1     0
   gsnd1bufr      sndrd2      g11         sndrD2_g11          0.0     1     0
   gsnd1bufr      sndrd3      g11         sndrD3_g11          0.0     1     0
   gsnd1bufr      sndrd4      g11         sndrD4_g11          0.0     1     0
   gsnd1bufr      sndrd1      g13         sndrD1_g13          0.0     1     0
   gsnd1bufr      sndrd2      g13         sndrD2_g13          0.0     1     0
   gsnd1bufr      sndrd3      g13         sndrD3_g13          0.0     1     0
   gsnd1bufr      sndrd4      g13         sndrD4_g13          0.0     1     0
   iasibufr       iasi        metop-a     iasi616_metop-a     0.0     1     1
   omibufr        omi         aura        omi_aura            0.0     2     0
   hirs4bufr      hirs4       n19         hirs4_n19           0.0     1     1
   amsuabufr      amsua       n19         amsua_n19           0.0     1     1
   mhsbufr        mhs         n19         mhs_n19             0.0     1     1
   tcvitl         tcp         null        tcp                 0.0     0     0
   seviribufr     seviri      m08         seviri_m08          0.0     1     0
   seviribufr     seviri      m09         seviri_m09          0.0     1     0
   seviribufr     seviri      m10         seviri_m10          0.0     1     0
   hirs4bufr      hirs4       metop-b     hirs4_metop-b       0.0     1     1
   amsuabufr      amsua       metop-b     amsua_metop-b       0.0     1     1
   mhsbufr        mhs         metop-b     mhs_metop-b         0.0     1     1
   iasibufr       iasi        metop-b     iasi616_metop-b     0.0     1     1
   atmsbufr       atms        npp         atms_npp            0.0     1     0
   crisbufr       cris        npp         cris_npp            0.0     1     0
   gsnd1bufr      sndrd1      g14         sndrD1_g14          0.0     1     0
   gsnd1bufr      sndrd2      g14         sndrD2_g14          0.0     1     0
   gsnd1bufr      sndrd3      g14         sndrD3_g14          0.0     1     0
   gsnd1bufr      sndrd4      g14         sndrD4_g14          0.0     1     0
   gsnd1bufr      sndrd1      g15         sndrD1_g15          0.0     1     0
   gsnd1bufr      sndrd2      g15         sndrD2_g15          0.0     1     0
   gsnd1bufr      sndrd3      g15         sndrD3_g15          0.0     1     0
   gsnd1bufr      sndrd4      g15         sndrD4_g15          0.0     1     0
   oscatbufr      uv          null        uv                  0.0     0     0
   mlsbufr        mls30       aura        mls30_aura          0.0     0     0
   avhambufr      avhrr       metop-a     avhrr3_metop-a      0.0     1     0
   avhpmbufr      avhrr       n18         avhrr3_n18          0.0     1     0
   prepbufr       mta_cld     null        mta_cld             1.0     0     0     
   prepbufr       gos_ctp     null        gos_ctp             1.0     0     0     
   lgycldbufr     larccld     null        larccld             1.0     0     0
   lghtnbufr      lghtn       null        lghtn               1.0     0     0
::
 &SUPEROB_RADAR
   del_azimuth=5.,del_elev=.25,del_range=5000.,del_time=.5,elev_angle_max=5.,minnum=50,range_max=100000.,
   l2superob_only=.false.,
 /
 &LAG_DATA
 /
 &HYBRID_ENSEMBLE
   l_hyb_ens=$HYB_ENS,
   n_ens=$nens,
   uv_hyb_ens=.true.,
   beta_s0=0.25,
   s_ens_h=300,
   s_ens_v=5,
   generate_ens=.false.,
   regional_ensemble_option=1,
   aniso_a_en=.false.,
   nlon_ens=0,
   nlat_ens=0,
   jcap_ens=574,
   l_ens_in_diff_time=.true.,
   jcap_ens_test=0,
   full_ensemble=.true.,pwgtflg=.true.,
   ensemble_path="",
 /
 &RAPIDREFRESH_CLDSURF
   i_gsdcldanal_type=${i_gsdcldanal_type},
   dfi_radar_latent_heat_time_period=20.0,
   l_use_hydroretrieval_all=.false.,
   metar_impact_radius=10.0,
   metar_impact_radius_lowCloud=4.0,
   l_gsd_terrain_match_surfTobs=.false.,
   l_sfcobserror_ramp_t=.false.,
   l_sfcobserror_ramp_q=.false.,
   l_PBL_pseudo_SurfobsT=.false.,
   l_PBL_pseudo_SurfobsQ=.false.,
   l_PBL_pseudo_SurfobsUV=.false.,
   pblH_ration=0.75,
   pps_press_incr=20.0,
   l_gsd_limit_ocean_q=.false.,
   l_pw_hgt_adjust=.false.,
   l_limit_pw_innov=.false.,
   max_innov_pct=0.1,
   l_cleanSnow_WarmTs=.false.,
   r_cleanSnow_WarmTs_threshold=5.0,
   l_conserve_thetaV=.false.,
   i_conserve_thetaV_iternum=3,
   l_cld_bld=.false.,
   cld_bld_hgt=1200.0,
   build_cloud_frac_p=0.50,
   clear_cloud_frac_p=0.1,
   iclean_hydro_withRef=1,
   iclean_hydro_withRef_allcol=0,
 /
 &CHEM
 /
 &SINGLEOB_TEST
 /
 &NST
 /

EOF

anavinfo=$fixgsi/anavinfo_fv3_64
berror=$fixgsi/$endianness/nam_glb_berror.f77.gcv
emiscoef_IRwater=$fixcrtm/Nalli.IRwater.EmisCoeff.bin
emiscoef_IRice=$fixcrtm/NPOESS.IRice.EmisCoeff.bin
emiscoef_IRland=$fixcrtm/NPOESS.IRland.EmisCoeff.bin
emiscoef_IRsnow=$fixcrtm/NPOESS.IRsnow.EmisCoeff.bin
emiscoef_VISice=$fixcrtm/NPOESS.VISice.EmisCoeff.bin
emiscoef_VISland=$fixcrtm/NPOESS.VISland.EmisCoeff.bin
emiscoef_VISsnow=$fixcrtm/NPOESS.VISsnow.EmisCoeff.bin
emiscoef_VISwater=$fixcrtm/NPOESS.VISwater.EmisCoeff.bin
emiscoef_MWwater=$fixcrtm/FASTEM6.MWwater.EmisCoeff.bin
aercoef=$fixcrtm/AerosolCoeff.bin
cldcoef=$fixcrtm/CloudCoeff.bin
#satinfo=$fixgsi/nam_regional_satinfo.txt
satinfo=$PARMdir/fv3sar_satinfo.txt
scaninfo=$fixgsi/global_scaninfo.txt
satangl=$fixgsi/nam_global_satangbias.txt
atmsbeamdat=$fixgsi/atms_beamwidth.txt
pcpinfo=$fixgsi/nam_global_pcpinfo.txt
ozinfo=$fixgsi/nam_global_ozinfo.txt
errtable=$fixgsi/nam_errtable.r3dv
convinfo=$fixgsi/nam_regional_convinfo.txt
mesonetuselist=$fixgsi/nam_mesonet_uselist.txt
stnuselist=$fixgsi/nam_mesonet_stnuselist.txt

# Copy executable and fixed files to $DATA
$ncp $gsiexec ./gsi.x

$ncp $anavinfo ./anavinfo
$ncp $berror   ./berror_stats
$ncp $emiscoef_IRwater ./Nalli.IRwater.EmisCoeff.bin
$ncp $emiscoef_IRice ./NPOESS.IRice.EmisCoeff.bin
$ncp $emiscoef_IRsnow ./NPOESS.IRsnow.EmisCoeff.bin
$ncp $emiscoef_IRland ./NPOESS.IRland.EmisCoeff.bin
$ncp $emiscoef_VISice ./NPOESS.VISice.EmisCoeff.bin
$ncp $emiscoef_VISland ./NPOESS.VISland.EmisCoeff.bin
$ncp $emiscoef_VISsnow ./NPOESS.VISsnow.EmisCoeff.bin
$ncp $emiscoef_VISwater ./NPOESS.VISwater.EmisCoeff.bin
$ncp $emiscoef_MWwater ./FASTEM6.MWwater.EmisCoeff.bin
$ncp $aercoef  ./AerosolCoeff.bin
$ncp $cldcoef  ./CloudCoeff.bin
$ncp $satangl  ./satbias_angle
$ncp $atmsbeamdat  ./atms_beamwidth.txt
$ncp $satinfo  ./satinfo
$ncp $scaninfo ./scaninfo
$ncp $pcpinfo  ./pcpinfo
$ncp $ozinfo   ./ozinfo
$ncp $convinfo ./convinfo
$ncp $errtable ./errtable
$ncp $mesonetuselist ./mesonetuselist
$ncp $stnuselist ./mesonet_stnuselist
$ncp $fixgsi/prepobs_prep.bufrtable ./prepobs_prep.bufrtable

# Copy CRTM coefficient files based on entries in satinfo file
for file in `awk '{if($1!~"!"){print $1}}' ./satinfo | sort | uniq` ;do
    $ncp $fixcrtm/${file}.SpcCoeff.bin ./
    $ncp $fixcrtm/${file}.TauCoeff.bin ./
done

###export nmmb_nems_obs=${COMINnam}/nam.${PDYrun}
export nmmb_nems_obs=${COMINrap}/rap.${PDYa}
export nmmb_nems_bias=${COMINbias}

# Copy observational data to $tmpdir
$ncp $nmmb_nems_obs/rap.t${cya}z.prepbufr.tm00  ./prepbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.prepbufr.acft_profiles.tm00 prepbufr_profl
$ncp $nmmb_nems_obs/rap.t${cya}z.satwnd.tm00.bufr_d ./satwndbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.1bhrs3.tm00.bufr_d ./hirs3bufr
$ncp $nmmb_nems_obs/rap.t${cya}z.1bhrs4.tm00.bufr_d ./hirs4bufr
$ncp $nmmb_nems_obs/rap.t${cya}z.mtiasi.tm00.bufr_d ./iasibufr
$ncp $nmmb_nems_obs/rap.t${cya}z.1bamua.tm00.bufr_d ./amsuabufr
$ncp $nmmb_nems_obs/rap.t${cya}z.esamua.tm00.bufr_d ./amsuabufrears
$ncp $nmmb_nems_obs/rap.t${cya}z.1bamub.tm00.bufr_d ./amsubbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.1bmhs.tm00.bufr_d  ./mhsbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.goesnd.tm00.bufr_d ./gsnd1bufr
$ncp $nmmb_nems_obs/rap.t${cya}z.airsev.tm00.bufr_d ./airsbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.cris.tm00.bufr_d ./crisbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.atms.tm00.bufr_d ./atmsbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.sevcsr.tm00.bufr_d ./seviribufr
$ncp $nmmb_nems_obs/rap.t${cya}z.radwnd.tm00.bufr_d ./radarbufr
$ncp $nmmb_nems_obs/rap.t${cya}z.nexrad.tm00.bufr_d ./l2rwbufr

export GDAS_SATBIAS=NO

if [ $GDAS_SATBIAS = NO ] ; then

$ncp $nmmb_nems_bias/${RUN}.t${CYCrun}z.satbias.${tmmark_prev} ./satbias_in
err1=$?
if [ $err1 -ne 0 ] ; then
  cp $GESROOT_HOLD/satbias_in ./satbias_in
fi
$ncp $nmmb_nems_bias/${RUN}.t${CYCrun}z.satbias_pc.${tmmark_prev} ./satbias_pc
err2=$?
if [ $err2 -ne 0 ] ; then
  cp $GESROOT_HOLD/satbias_pc ./satbias_pc
fi
$ncp $nmmb_nems_bias/${RUN}.t${CYCrun}z.radstat.${tmmark_prev}    ./radstat.gdas
err3=$?
if [ $err3 -ne 0 ] ; then
  cp $GESROOT_HOLD/radstat.nam ./radstat.gdas
fi

else

cp $GESROOT_HOLD/gdas.satbias_out ./satbias_in
cp $GESROOT_HOLD/gdas.satbias_pc ./satbias_pc
cp $GESROOT_HOLD/gdas.radstat_out ./radstat.gdas

fi

#Aircraft bias corrections always cycled through 6-h DA

$ncp $nmmb_nems_bias/${RUN}.t${CYCrun}z.abias_air.${tmmark_prev} ./aircftbias_in
err1=$?
if [ $err1 -ne 0 ] ; then
  cp $GESROOT_HOLD/gdas.airbias ./aircftbias_in
fi

cp $COMINrtma/rtma2p5.${PDYa}/rtma2p5.t${cya}z.w_rejectlist ./w_rejectlist
cp $COMINrtma/rtma2p5.${PDYa}/rtma2p5.t${cya}z.t_rejectlist ./t_rejectlist
cp $COMINrtma/rtma2p5.${PDYa}/rtma2p5.t${cya}z.p_rejectlist ./p_rejectlist
cp $COMINrtma/rtma2p5.${PDYa}/rtma2p5.t${cya}z.q_rejectlist ./q_rejectlist

export fv3_case=$GUESSdir

#  INPUT FILES FV3 NEST (single tile)

#   This file contains time information
cp $fv3_case/${PDY}.${CYC}0000.coupler.res coupler.res
#   This file contains vertical weights for defining hybrid volume hydrostatic pressure interfaces 
cp $fv3_case/${PDY}.${CYC}0000.fv_core.res.nc fv3_akbk
#   This file contains horizontal grid information
cp $fv3_case/grid_spec.nc fv3_grid_spec
#   This file contains 3d fields u,v,w,dz,T,delp, and 2d sfc geopotential phis
cp $fv3_case/${PDY}.${CYC}0000.fv_core.res.tile1.nc fv3_dynvars
#   This file contains 3d tracer fields sphum, liq_wat, o3mr
cp $fv3_case/${PDY}.${CYC}0000.fv_tracer.res.tile1.nc fv3_tracer
#   This file contains surface fields (vert dims of 3, 4, and 63)
cp $fv3_case/${PDY}.${CYC}0000.sfc_data.nc fv3_sfcdata

# Run gsi under Parallel Operating Environment (poe) on NCEP IBM

export pgm=gsi.x
. prep_step

startmsg
mpirun -l -n 240 gsi.x < gsiparm.anl > $pgmout 2> stderr
export err=$?;err_chk

mv fort.201 fit_p1
mv fort.202 fit_w1
mv fort.203 fit_t1
mv fort.204 fit_q1
mv fort.205 fit_pw1
mv fort.207 fit_rad1
mv fort.209 fit_rw1

cat fit_p1 fit_w1 fit_t1 fit_q1 fit_pw1 fit_rad1 fit_rw1 > $COMOUT/${RUN}.t${CYCrun}z.fits.${tmmark}
cat fort.208 fort.210 fort.211 fort.212 fort.213 fort.220 > $COMOUT/${RUN}.t${CYCrun}z.fits2.${tmmark}

cp satbias_out $GESROOT_HOLD/satbias_in
cp satbias_out $COMOUT/${RUN}.t${CYCrun}z.satbias.${tmmark}
cp satbias_pc.out $GESROOT_HOLD/satbias_pc
cp satbias_pc.out $COMOUT/${RUN}.t${CYCrun}z.satbias_pc.${tmmark}

cp aircftbias_out $COMOUT/${RUN}.t${CYCrun}z.abias_air.${tmmark}
cp aircftbias_out $GESROOT_HOLD/gdas.airbias

RADSTAT=${COMOUT}/${RUN}.t${CYCrun}z.radstat.${tmmark}
CNVSTAT=${COMOUT}/${RUN}.t${CYCrun}z.cnvstat.${tmmark}

# Set up lists and variables for various types of diagnostic files.
ntype=1

diagtype[0]="conv"
diagtype[1]="hirs2_n14 msu_n14 sndr_g08 sndr_g11 sndr_g12 sndr_g13 sndr_g08_prep sndr_g11_prep sndr_g12_prep sndr_g13_prep sndrd1_g11 sndrd2_g11 sndrd3_g11 sndrd4_g11 sndrd1_g12 sndrd2_g12 sndrd3_g12 sndrd4_g12 sndrd1_g13 sndrd2_g13 sndrd3_g13 sndrd4_g13 sndrd1_g14 sndrd2_g14 sndrd3_g14 sndrd4_g14 sndrd1_g15 sndrd2_g15 sndrd3_g15 sndrd4_g15 hirs3_n15 hirs3_n16 hirs3_n17 amsua_n15 amsua_n16 amsua_n17 amsub_n15 amsub_n16 amsub_n17 hsb_aqua airs_aqua amsua_aqua imgr_g08 imgr_g11 imgr_g12 imgr_g14 imgr_g15 ssmi_f13 ssmi_f14 ssmi_f15 hirs4_n18 hirs4_metop-a amsua_n18 amsua_metop-a mhs_n18 mhs_metop-a amsre_low_aqua amsre_mid_aqua amsre_hig_aqua ssmis_las_f16 ssmis_uas_f16 ssmis_img_f16 ssmis_env_f16 ssmis_las_f17 ssmis_uas_f17 ssmis_img_f17 ssmis_env_f17 ssmis_las_f18 ssmis_uas_f18 ssmis_img_f18 ssmis_env_f18 ssmis_las_f19 ssmis_uas_f19 ssmis_img_f19 ssmis_env_f19 ssmis_las_f20 ssmis_uas_f20 ssmis_img_f20 ssmis_env_f20 iasi_metop-a hirs4_n19 amsua_n19 mhs_n19 seviri_m08 seviri_m09 seviri_m10 cris_npp atms_npp hirs4_metop-b amsua_metop-b mhs_metop-b iasi_metop-b gome_metop-b"

diaglist[0]=listcnv
diaglist[1]=listrad

diagfile[0]=$CNVSTAT
diagfile[1]=$RADSTAT

numfile[0]=0
numfile[1]=0

# Set diagnostic file prefix based on lrun_subdirs variable
   prefix="pe*"

# Compress and tar diagnostic files.

loops="01 03"
for loop in $loops; do
   case $loop in
     01) string=ges;;
     03) string=anl;;
      *) string=$loop;;
   esac
   n=-1
   while [ $((n+=1)) -le $ntype ] ;do
      for type in `echo ${diagtype[n]}`; do
         count=`ls ${prefix}${type}_${loop}* | wc -l`
         if [ $count -gt 0 ]; then
            cat ${prefix}${type}_${loop}* > diag_${type}_${string}.${SDATE}
            echo "diag_${type}_${string}.${SDATE}*" >> ${diaglist[n]}
            numfile[n]=`expr ${numfile[n]} + 1`
         fi
      done
   done
done


#  compress diagnostic files
   for file in `ls diag_*${SDATE}`; do
      gzip $file
   done

# If requested, create diagnostic file tarballs
   n=-1
   while [ $((n+=1)) -le $ntype ] ;do
      TAROPTS="-uvf"
      if [ ! -s ${diagfile[n]} ]; then
         TAROPTS="-cvf"
      fi
      if [ ${numfile[n]} -gt 0 ]; then
         tar $TAROPTS ${diagfile[n]} `cat ${diaglist[n]}`
      fi
   done

#  Restrict CNVSTAT
   chmod 750 $CNVSTAT
   chgrp rstprod $CNVSTAT

if [ $tmmark != tm00 ] ; then 
  cp $RADSTAT ${GESROOT_HOLD}/radstat.nam
fi

# Put analysis files in ANLdir (defined in J-job)
mv fv3_akbk $ANLdir/fv_core.res.nc
mv coupler.res $ANLdir/coupler.res
mv fv3_dynvars $ANLdir/fv_core.res.tile1.nc
mv fv3_tracer $ANLdir/fv_tracer.res.tile1.nc
mv fv3_sfcdata $ANLdir/sfc_data.nc
cp $COMOUT/gfsanl.tm12/gfs_ctrl.nc $ANLdir/.

exit
