#!/bin/sh
export GLOBAL_VAR_DEFNS_FP="${EXPTDIR}/var_defns.sh"
set -x
source ${GLOBAL_VAR_DEFNS_FP}
export CDATE=${DATE_FIRST_CYCL}${CYCL_HRS}
export CYCLE_DIR=${EXPTDIR}/${CDATE}

# get the ICS files
export ICS_OR_LBCS="ICS"
export EXTRN_MDL_NAME=${EXTRN_MDL_NAME_ICS}
${JOBSDIR}/JREGIONAL_GET_EXTRN_MDL_FILES

