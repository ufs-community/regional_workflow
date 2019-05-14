#!/bin/sh
set -xu

topdir=$(pwd)
echo $topdir

echo fv3gfs checkout ...
if [[ ! -d fv3gfs.fd ]] ; then
    rm -f ${topdir}/checkout-fv3gfs.log
    git clone --recursive gerrit:NEMSfv3gfs fv3gfs.fd >> ${topdir}/checkout-fv3gfs.log 2>&1
#    cd fv3gfs.fd
#    git checkout nemsfv3gfs_beta_v1.0.12
#    git submodule update --init --recursive
#    cd ${topdir}
else
    echo 'Skip.  Directory fv3gfs.fd already exists.'
fi

echo gsi checkout ...
if [[ ! -d gsi.fd ]] ; then
    rm -f ${topdir}/checkout-gsi.log
    git clone --recursive gerrit:ProdGSI gsi.fd >> ${topdir}/checkout-gsi.fd.log 2>&1
#    cd gsi.fd
#    git checkout fv3da.v1.0.37
#    git submodule update
#    cd ${topdir}
else
    echo 'Skip.  Directory gsi.fd already exists.'
fi

echo EMC_post checkout ...
if [[ ! -d ncep_post.fd ]] ; then
    rm -f ${topdir}/checkout-ncep_post.log
    git clone --recursive gerrit:EMC_post ncep_post.fd >> ${topdir}/checkout-ncep_post.log 2>&1
#    cd ncep_post.fd
#    git checkout ncep_post.v8.0.27
#    cd ${topdir}
else
    echo 'Skip.  Directory ncep_post.fd already exists.'
fi


exit 0
