#!/bin/sh -l

set -x

cd /gpfs/dell2/emc/modeling/noscrub/${USER}/regional_workflow/rocoto

# Experiment name
EXPT=fv3sartest
# Grid type
GTYPE=regional
# Model domain name
DOMAIN=conus
# First, last, and interval of the workflow cycles
CYCLE_YMDH_BEG="2019071700"
CYCLE_YMDH_END="2019071706"
CYCLE_INT_HH="06"

# The platform the workflow will be run: wcoss_dell_p3, wcoss_cray, theia, jet
MACHINE=wcoss_dell_p3 
# The corresponding site file to use for the workflow
SITE_FILE="sites/${MACHINE}.ent"
# The project to use for submitting the jobs/tasks
CPU_ACCOUNT="HREF-T2O"

# Home directory of the regional_workflow package
HOMEfv3=/gpfs/dell2/emc/modeling/noscrub/${USER}/regional_workflow
# Temporary directory root for the WORK (where the jobs/tasks will be run) directories
STMP=/gpfs/dell1/stmp
# Temporary directory root for the COM (where the products will be delivered) and LOG (where job log files will be) directories
PTMP=/gpfs/dell1/ptmp

# Run the get_input task or not: YES|NO
GET_INPUT=NO
# Directory of the GFS input files
COMgfs=/gpfs/dell1/nco/ops/com/gfs/prod
# An alternative location for COMgfs
COMgfs2=/gpfs/dell3/ptmp/emc.glopara/ROTDIRs/prfv3rt3/vrfyarch

# The workflow files of the experiment
expxml=${EXPT}_${CYCLE_YMDH_BEG}.xml
expdb=${EXPT}_${CYCLE_YMDH_BEG}.db

# Parsing the workflow definition file for the experiment from regional_workflow.xml.in
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
    -e "s|@\[GET_INPUT.*\]|${GET_INPUT}|g" \
    -e "s|@\[COMgfs.*\]|${COMgfs}|g" \
    -e "s|@\[COMgfs2.*\]|${COMgfs2}|g" \
    regional_workflow.xml.in \
    > ${expxml}

# Run the workflow
rocotorun -v 10 -w ${expxml} -d ${expdb}

echo 'job done'

