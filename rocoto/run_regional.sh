#!/bin/sh -l

set -x

cd /gpfs/dell2/emc/modeling/noscrub/${USER}/save/regional_clean/rocoto

EXPT=regional_workflow
SUBEXPT=fv3sar
GTYPE=regional
DOMAIN=conus
CYCLE_YMDH_BEG="2019071700"
CYCLE_YMDH_END="2019071900"
CYCLE_INT_HH="06"
SITE_FILE="sites/wcoss_dell_p3.ent"
CPU_ACCOUNT="HUR-T2O"

USER=${USER}
NOSCRUB=/gpfs/dell2/emc/modeling/noscrub
HOMEfv3=${NOSCRUB}/${USER}/${EXPT}
PTMP=/gpfs/dell1/ptmp
STMP=/gpfs/dell1/stmp

FETCH_INPUT=NO
COMgfs=/gpfs/dell1/nco/ops/com/gfs/prod
COMgfs2=/gpfs/dell3/ptmp/emc.glopara/ROTDIRs/prfv3rt3/vrfyarch

expxml=${SUBEXPT}_${CYCLE_YMDH_BEG}.xml
expdb=${SUBEXPT}_${CYCLE_YMDH_BEG}.db

sed -e "s|@\[USER.*\]|${USER}|g" \
    -e "s|@\[CPU_ACCOUNT.*\]|${CPU_ACCOUNT}|g" \
    -e "s|@\[SITE_FILE.*\]|${SITE_FILE}|g" \
    -e "s|@\[EXPT.*\]|${EXPT}|g" \
    -e "s|@\[SUBEXPT.*\]|${SUBEXPT}|g" \
    -e "s|@\[FETCH_INPUT.*\]|${FETCH_INPUT}|g" \
    -e "s|@\[GTYPE.*\]|${GTYPE}|g" \
    -e "s|@\[DOMAIN.*\]|${DOMAIN}|g" \
    -e "s|@\[CYCLE_YMDH_BEG.*\]|${CYCLE_YMDH_BEG}|g" \
    -e "s|@\[CYCLE_YMDH_END.*\]|${CYCLE_YMDH_END}|g" \
    -e "s|@\[CYCLE_INT_HH.*\]|${CYCLE_INT_HH}|g" \
    -e "s|@\[COMgfs.*\]|${COMgfs}|g" \
    -e "s|@\[COMgfs2.*\]|${COMgfs2}|g" \
    -e "s|@\[NOSCRUB.*\]|${NOSCRUB}|g" \
    -e "s|@\[PTMP.*\]|${PTMP}|g" \
    -e "s|@\[STMP.*\]|${STMP}|g" \
    regional_workflow.xml.in \
    > ${expxml}

rocotorun -v 10 -w ${expxml} -d ${expdb}

echo 'job done'

