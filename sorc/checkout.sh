#!/bin/sh
set -xue

echo "INFO: Clone and Check out the regional_workflow external components."
echo "INFO: If the directory of an external component already exist, will pull the latest updates from the corresponding branch."

if [[ $# -ge 1 ]]; then
  if [[ $1 = "-c" ]]; then
    echo "WARNING: You are using the '-c' commandline option."
    echo "WARNING: This will conduct a fresh checkout of all the workflow external components."
    echo "WARNING: This will delete all the existing regional_*.fd directores for the workflow external components."
    echo "WARNING: Any local changes in these regional_*.fd directores will be deleted."
    read -p "WARNING: Do you really want to proceed? [Y/N]" yn
    if [[ $yn = "Y" ]]; then
      rm -rf regional_utils.fd
      rm -rf regional_forecast.fd
      rm -rf regional_post.fd
      rm -rf regional_gsi.fd
    else
      echo "Do nothing, exiting ..."
      exit
    fi
  fi
fi

topdir=$(pwd)
echo $topdir

echo NEMSfv3gfs checkout ...
if [[ ! -d regional_forecast.fd ]] ; then
    git clone https://github.com/ufs-community/ufs-weather-model.git regional_forecast.fd
    cd regional_forecast.fd
    git submodule update --init --recursive
    cd ${topdir}
else
    echo 'Directory regional_forecast.fd already exists. Pull the latest updates from the corresponding branch.'
    cd regional_forecast.fd
    git pull
    git submodule update --init --recursive
    cd ${topdir}
fi

echo EMC_post checkout ...
if [[ ! -d regional_post.fd ]] ; then
    git clone -b support/regional https://github.com/hafs-community/EMC_post.git regional_post.fd
else
    echo 'Directory regional_post.fd already exists. Pull the latest updates from the corresponding branch.'
    cd regional_post.fd
    git checkout support/regional
    git pull
    cd ${topdir}
fi

echo UFS_UTILS checkout ...
if [[ ! -d regional_utils.fd ]] ; then
    git clone -b support/regional https://github.com/hafs-community/UFS_UTILS.git regional_utils.fd
else
    echo 'Directory regional_utils.fd already exists. Pull the latest updates from the corresponding branch.'
    cd regional_utils.fd
    git checkout support/regional
    git pull
    cd ${topdir}
fi

echo ProdGSI checkout ...
if [[ ! -d regional_gsi.fd ]] ; then
    git clone --recursive gerrit:ProdGSI regional_gsi.fd
    cd regional_gsi.fd
    git submodule update --init --recursive
    cd ${topdir}
else
    echo 'Directory regional_gsi.fd already exists. Pull the latest updates from the corresponding branch.'
    cd regional_gsi.fd
    git submodule update --init --recursive
    git pull
    cd ${topdir}
fi

exit
