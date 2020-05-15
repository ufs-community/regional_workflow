#!/bin/sh -l
#SBATCH -A fv3-cam
#SBATCH -e err.ufs.%j
#SBATCH -o out.ufs.%j
#SBATCH -N 1 --ntasks-per-node=8
#SBATCH -qbatch
#SBATCH -p orion
#SBATCH --job-name=ufs
#SBATCH -t 00:20:00
#SBATCH --exclusive
#SBATCH --cpus-per-task=1
set -x

export PATH=$PATH:/apps/contrib/rocoto/1.3.1/bin

# Home directory of the regional_workflow package

HOMEfv3=/work/noaa/fv3-cam/${USER}/regional_workflow

cd ${HOMEfv3}/rocoto

# if want a non-CONUS domain, export DOMAIN here

# export DOMAIN=pr

source ./config.workflow.defaults

# Machine and project account
machine=orion
SITE_FILE="sites/${machine}.ent"
CPU_ACCOUNT=fv3-cam

# Experiment name
EXPT=fv3sartest
# First, last, and interval of the workflow cycles
CYCLE_YMDH_BEG="2020012300"
CYCLE_YMDH_END="2020012300"
CYCLE_INT_HH="06"

GET_INPUT=NO
COMINgfs=/work/noaa/fv3-cam/${USER}/datain
STMP=/work/noaa/fv3-cam/${USER}/stmp/${EXPT}
PTMP=/work/noaa/fv3-cam/${USER}/ptmp/${EXPT}

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
#jaa (sequential scripts )

# rocotorun -v 10 -w ${expxml} -d ${expdb}
source ../scripts/exregional_make_bc.sh 

echo 'job done'

