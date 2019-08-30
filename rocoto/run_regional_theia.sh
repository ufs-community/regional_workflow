#!/bin/sh -l

set -x

# Home directory of the regional_workflow package

HOMEfv3=/scratch4/NCEPDEV/fv3-cam/noscrub/Matthew.Pyle/regional_workflow

cd ${HOMEfv3}/rocoto

# if want a non-CONUS domain, export DOMAIN here

export DOMAIN=pr

source ./config.workflow.defaults

# Machine and project account
machine=theia
SITE_FILE="sites/${machine}.ent"
CPU_ACCOUNT=fv3-cam

# Experiment name
EXPT=fv3sartest
# First, last, and interval of the workflow cycles
CYCLE_YMDH_BEG="2019050200"
CYCLE_YMDH_END="2019050200"
CYCLE_INT_HH="06"

GET_INPUT=NO
COMINgfs=/scratch3/NCEPDEV/hwrf/noscrub/hafs-input/COMGFS
STMP=/scratch4/NCEPDEV/stmp3/${USER}/${EXPT}
PTMP=/scratch4/NCEPDEV/stmp3/${USER}/${EXPT}

# The workflow files of the experiment
expxml=${EXPT}_${CYCLE_YMDH_BEG}.xml
expdb=${EXPT}_${CYCLE_YMDH_BEG}.db

# Generate the workflow definition file by parsing regional_workflow.xml.in
sed -e "s|@\[EXPT.*\]|${EXPT}|g" \
    -e "s|@\[GTYPE.*\]|${GTYPE}|g" \
    -e "s|@\[DOMAIN.*\]|${DOMAIN}|g" \
    -e "s|@\[CYCLE_YMDH_BEG.*\]|${CYCLE_YMDH_BEG}|g" \
    -e "s|@\[CYCLE_YMDH_END.*\]|${CYCLE_YMDH_END}|g" \
    -e "s|@\[CYCLE_INT_HH.*\]|${CYCLE_INT_HH}|g" \
    -e "s|@\[USER.*\]|${USER}|g" \
    -e "s|@\[CPU_ACCOUNT.*\]|${CPU_ACCOUNT}|g" \
    -e "s|@\[SITE_FILE.*\]|${SITE_FILE}|g" \
    -e "s|@\[HOMEfv3.*\]|${HOMEfv3}|g" \
    -e "s|@\[PTMP.*\]|${PTMP}|g" \
    -e "s|@\[STMP.*\]|${STMP}|g" \
    -e "s|@\[MAKE_GRID_OROG.*\]|${MAKE_GRID_OROG}|g" \
    -e "s|@\[MAKE_SFC_CLIMO.*\]|${MAKE_SFC_CLIMO}|g" \
    -e "s|@\[GET_INPUT.*\]|${GET_INPUT}|g" \
    -e "s|@\[COMINgfs.*\]|${COMINgfs}|g" \
    regional_workflow.xml.in \
    > ${expxml}

# Run the workflow for the experiment
rocotorun -v 10 -w ${expxml} -d ${expdb}

echo 'job done'

