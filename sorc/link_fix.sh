#!/bin/sh
set -x

source ./machine-setup.sh > /dev/null 2>&1

pwd=$(pwd -P)

if [ ${target} == "wcoss_cray" ]; then
    FIX_DIR="/gpfs/hps3/emc/global/noscrub/emc.glopara/git/fv3gfs/fix"
elif [[ ${target} == "wcoss_dell_p3" || ${target} == "wcoss" ]]; then
    FIX_DIR="/gpfs/dell2/emc/modeling/noscrub/emc.campara/fix_fv3cam"
elif [ ${target} == "theia" ]; then
    FIX_DIR="/scratch4/NCEPDEV/global/save/glopara/git/fv3gfs/fix"
elif [ ${target} == "jet" ]; then
    FIX_DIR="/scratch4/NCEPDEV/global/save/glopara/git/fv3gfs/fix"
else
    echo "Unknown site " ${target}
    exit 1
fi

mkdir -p ${pwd}/../fix
cd ${pwd}/../fix                ||exit 8
for dir in fix_am fix_nest fix_sar ; do
    [[ -d $dir ]] && rm -rf $dir
done
ln -sf $FIX_DIR/* .

exit
