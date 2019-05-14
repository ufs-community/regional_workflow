#!/bin/ksh
set -ex

#--make symbolic links for EMC installation and hardcopies for NCO delivery

RUN_ENVIR=${1}
machine=${2}

if [ $# -lt 2 ]; then
    echo '***ERROR*** must specify two arguements: (1) RUN_ENVIR, (2) machine'
    echo ' Syntax: link_fv3gfs.sh ( nco | emc ) ( cray | dell | theia )'
    exit 1
fi

if [ $RUN_ENVIR != emc -a $RUN_ENVIR != nco ]; then
    echo 'Syntax: link_fv3gfs.sh ( nco | emc ) ( cray | dell | theia )'
    exit 1
fi
if [ $machine != cray -a $machine != theia -a $machine != dell ]; then
    echo 'Syntax: link_fv3gfs.sh ( nco | emc ) ( cray | dell | theia )'
    exit 1
fi

LINK="ln -fs"
SLINK="ln -fs"
[[ $RUN_ENVIR = nco ]] && LINK="cp -rp"

pwd=$(pwd -P)

#------------------------------
#--model fix fields
#------------------------------
if [ $machine == "cray" ]; then
    FIX_DIR="/gpfs/hps3/emc/global/noscrub/emc.glopara/git/fv3gfs/fix"
elif [ $machine = "dell" ]; then
    FIX_DIR="/gpfs/dell2/emc/modeling/noscrub/emc.campara/fix_fv3cam"
elif [ $machine = "theia" ]; then
    FIX_DIR="/scratch4/NCEPDEV/global/save/glopara/git/fv3gfs/fix"
fi
cd ${pwd}/../fix                ||exit 8
for dir in fix_am fix_nest fix_sar ; do
    [[ -d $dir ]] && rm -rf $dir
done
$LINK $FIX_DIR/* .

#------------------------------
#--link executables 
#------------------------------

cd $pwd/../exec
[[ -s fv3_gfs.x ]] && rm -f fv3_gfs.x
cp ../sorc/fv3gfs.fd/NEMS/exe/fv3_gfs.x .

[[ -s ncep_post ]] && rm -f ncep_post
cp ../sorc/ncep_post.fd/exec/ncep_post .



#for gsiexe in  global_gsi.x global_enkf.x calc_increment_ens.x  getsfcensmeanp.x  getsigensmeanp_smooth.x  getsigensstatp.x  recentersigp.x oznmon_horiz.x oznmon_time.x radmon_angle radmon_bcoef radmon_bcor radmon_time ;do
#    [[ -s $gsiexe ]] && rm -f $gsiexe
#    cp ../sorc/gsi.fd/exec/$gsiexe .
#done


#------------------------------
#--link source code directories
#------------------------------

#cd ${pwd}/../sorc   ||   exit 8
#    $SLINK gsi.fd/util/EnKF/gfs/src/calc_increment_ens.fd                                  calc_increment_ens.fd
#    $SLINK gsi.fd/util/EnKF/gfs/src/getsfcensmeanp.fd                                      getsfcensmeanp.fd
#    $SLINK gsi.fd/util/EnKF/gfs/src/getsigensmeanp_smooth.fd                               getsigensmeanp_smooth.fd
#    $SLINK gsi.fd/util/EnKF/gfs/src/getsigensstatp.fd                                      getsigensstatp.fd
#    $SLINK gsi.fd/src                                                                      global_enkf.fd
#    $SLINK gsi.fd/src                                                                      global_gsi.fd
#    $SLINK gsi.fd/util/Ozone_Monitor/nwprod/oznmon_shared.v2.0.0/sorc/oznmon_horiz.fd      oznmon_horiz.fd
#    $SLINK gsi.fd/util/Ozone_Monitor/nwprod/oznmon_shared.v2.0.0/sorc/oznmon_time.fd       oznmon_time.fd
#    $SLINK gsi.fd/util/Radiance_Monitor/nwprod/radmon_shared.v3.0.0/sorc/verf_radang.fd    radmon_angle.fd
#    $SLINK gsi.fd/util/Radiance_Monitor/nwprod/radmon_shared.v3.0.0/sorc/verf_radbcoef.fd  radmon_bcoef.fd
#    $SLINK gsi.fd/util/Radiance_Monitor/nwprod/radmon_shared.v3.0.0/sorc/verf_radbcor.fd   radmon_bcor.fd 
#    $SLINK gsi.fd/util/Radiance_Monitor/nwprod/radmon_shared.v3.0.0/sorc/verf_radtime.fd   radmon_time.fd 
#    $SLINK gsi.fd/util/EnKF/gfs/src/recentersigp.fd                                        recentersigp.fd


#------------------------------
#--choose dynamic config.base for EMC installation 
#--choose static config.base for NCO installation 
#cd $pwd/../parm/config
#[[ -s config.base ]] && rm -f config.base 
#if [ $RUN_ENVIR = nco ] ; then
# cp -p config.base.nco.static config.base
#else
# cp -p config.base.emc.dyn config.base
#fi
#------------------------------


exit 0



