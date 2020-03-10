#!/bin/sh -l
set -x

module use /contrib/modulefiles
module load anaconda/latest
#module load met/9.0_beta3_anacondal

export METPLUS_PATH=/contrib/METplus/METplus-3.0-beta3
export METPLUS_CONF=/scratch2/BMC/det/jwolff/HIWT/add_metplus/regional_workflow/ush/templates/parm/metplus

#export PYTHONPATH=/usr/bin/python3:${METPLUS_PATH}/ush:${METPLUS_PATH}/parm

echo `which python` 
echo 'Actual output starts here:'
CDATE=2019101112
INIT=${CDATE}
export INIT

export ccpapath=/scratch2/BMC/det/harrold/data_pull/ccpa/reorg
export polydir=/contrib/met/9.0_beta3/share/met/poly

wrkdir=/scratch2/BMC/det/jwolff/HIWT/expt_dirs/test_metplus/${INIT}/metprd

if [ -d $wrkdir ]
then
  rm -f $wrkdir/*
else
  mkdir -p $wrkdir
fi
cd $wrkdir

# Set necessary command line arguments for CCPA reorganization script
 

# Run CCPA organization script
/scratch2/BMC/det/jwolff/HIWT/add_metplus/regional_workflow/scripts/reorganize_ccpa.ksh

export acc="01h" # for stats output prefix in GridStatConfig

# 1h ctc/sl1l2 scores:

export MODEL="FV3_GSD_SAR_GSD_HRRR3km"
export modpath=/scratch2/BMC/det/jwolff/HIWT/expt_dirs/test_metplus/${INIT}/postprd
${METPLUS_PATH}/ush/master_metplus.py \
  -c ${METPLUS_CONF}/common_hera.conf \
  -c ${METPLUS_CONF}/APCP_${acc}.conf

