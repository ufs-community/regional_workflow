#!/bin/sh
set -xu

topdir=$(pwd)
echo $topdir

echo UFS_UTILS checkout ...
if [[ ! -d regional_utils.fd ]] ; then
    rm -f ${topdir}/checkout-utils.log
    git clone --recursive gerrit:UFS_UTILS regional_utils.fd >> ${topdir}/checkout-utils.log 2>&1
	cd regional_utils.fd
#	git checkout develop
	git checkout feature/HAFS
    cd ${topdir}
else
    echo 'Skip.  Directory regional_utils.fd already exists.'
fi

echo NEMSfv3gfs checkout ...
if [[ ! -d regional_forecast.fd ]] ; then
    rm -f ${topdir}/checkout-forecast.log
    git clone --recursive gerrit:NEMSfv3gfs regional_forecast.fd >> ${topdir}/checkout-forecast.log 2>&1
    cd regional_forecast.fd
#    git checkout nemsfv3gfs_beta_v1.0.12
    git checkout regional
    git submodule update --init --recursive
    cd ${topdir}
else
    echo 'Skip.  Directory regional_forecast.fd already exists.'
fi

echo EMC_post checkout ...
if [[ ! -d regional_post.fd ]] ; then
    rm -f ${topdir}/checkout-post.log
    git clone --recursive gerrit:EMC_post regional_post.fd >> ${topdir}/checkout-post.log 2>&1
    cd regional_post.fd
#    git checkout ncep_post.v8.0.27
    git checkout regional
    cd ${topdir}
else
    echo 'Skip.  Directory regional_post.fd already exists.'
fi

echo ProdGSI checkout ...
if [[ ! -d regional_gsi.fd ]] ; then
    rm -f ${topdir}/checkout-gsi.log
    git clone --recursive gerrit:ProdGSI regional_gsi.fd >> ${topdir}/checkout-gsi.log 2>&1
#    cd regional_gsi.fd
#    git checkout fv3da.v1.0.37
#    git submodule update
#    cd ${topdir}
    cp ../parm/anavinfo_fv3_64 regional_gsi.fd/fix
else
    echo 'Skip.  Directory regional_gsi.fd already exists.'
fi

exit 0
