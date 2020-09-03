#!/bin/bash 

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#
. ${GLOBAL_VAR_DEFNS_FP}
. $USHDIR/source_util_funcs.sh
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; set -u +x; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
scrfunc_fn=$( basename "${scrfunc_fp}" )
scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Print message indicating entry into script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
Entering script:  \"${scrfunc_fn}\"
In directory:     \"${scrfunc_dir}\"

This is the ex-script for the task that copies/fetches to a local direc-
tory (either from disk or HPSS) the external model files from which ini-
tial or boundary condition files for the FV3 will be generated.
========================================================================"
#
#-----------------------------------------------------------------------
#
# Specify the set of valid argument names for this script/function.  
# Then process the arguments provided to this script/function (which 
# should consist of a set of name-value pairs of the form arg1="value1",
# etc).
#
#-----------------------------------------------------------------------
#
valid_args=()
process_args valid_args "$@"
#
#-----------------------------------------------------------------------
#
# For debugging purposes, print out values of arguments passed to this
# script.  Note that these will be printed out only if VERBOSE is set to
# TRUE.
#
#-----------------------------------------------------------------------
#
#print_input_args valid_args
#
#-----------------------------------------------------------------------
#
# We first check whether the external model output files exist on the 
# system disk (and are older than a certain age).  If so, we simply copy
# them from the system disk to the location specified by EXTRN_MDL_-
# FILES_DIR.  If not, we try to fetch them from HPSS.
#
# Start by setting EXTRN_MDL_FPS to the full paths that the external mo-
# del output files would have if they existed on the system disk.  Then
# count the number of such files that actually exist on disk (i.e. have
# not yet been scrubbed) and are older than a specified age (to make 
# sure that they are not still being written to).
#
#-----------------------------------------------------------------------
#
cyc="00" #"${PDY:8:2}"
yyyymmdd="${PDY:0:8}"
mm=$(date -d "$yyyymmdd" +"%m")

CHEM_BOUNDARY_CONDITION_FILE=gfs_bndy_chem_${mm}.tile7.000.nc

case $MACHINE in

"HERA")

boundary_file_loc=/scratch2/NAGAPE/arl/Barry.Baker/boundary_conditions

;;

"WCOSS_DELL_P3")

module load  NCL/6.4.0   

module list

#export Pre_cyc=$CYCLE_DIR/../
#export CYC_1=`$NDATE -6 ${DATE_FIRST_CYCL}$CYCL_HRS`  
#export CYC_2=`$NDATE -12 ${DATE_FIRST_CYCL}$CYCL_HRS`  
#export CYC_3=`$NDATE -18 ${DATE_FIRST_CYCL}$CYCL_HRS`  
#export PDYm1=`$NDATE -24 ${DATE_FIRST_CYCL}$CYCL_HRS | cut -c1-8`  


boundary_file_loc=/gpfs/dell2/emc/modeling/noscrub/$USER/boundary_conditions

;;
esac

FULL_CHEMICAL_BOUNDARY_FILE=${boundary_file_loc}/${CHEM_BOUNDARY_CONDITION_FILE}
if [ -f ${FULL_CHEMICAL_BOUNDARY_FILE} ]; then
    #Copy the boundary condition file to the current location
    cp ${FULL_CHEMICAL_BOUNDARY_FILE} .
else
    CHEM_BOUNDARY_CONDITION_FILE=LBCS/${CHEM_BOUNDARY_CONDITION_FILE}
    print_info_msg "
Fetching chemical lateral boundary condition filesfrom HPSS:
  AQM_ARCHIVE = ${AQM_ARCHIVE}
  CHEM_BOUNDARY_CONDITION_FILE = ${CHEM_BOUNDARY_CONDITION_FILE}
  "
    htar -xvf ${AQM_ARCHIVE} ${CHEM_BOUNDARY_CONDITION_FILE}
fi

#
export hr=0
while [ $hr -le ${FCST_LEN_HRS} ]; do
#    typeset -Z3 hr
    if [ $hr -le 9 ]; then
      new_lbc=${CYCLE_DIR}/INPUT/gfs_bndy.tile7.00${hr}.nc 
    elif [ $hr -le 99 ]; then
      new_lbc=${CYCLE_DIR}/INPUT/gfs_bndy.tile7.0${hr}.nc
    else
      new_lbc=${CYCLE_DIR}/INPUT/gfs_bndy.tile7.${hr}.nc
    fi
#   ncks -A ${CHEM_BOUNDARY_CONDITION_FILE} ${CYCLE_DIR}/INPUT/gfs_bndy.tile7.${hr}.nc
    ncks -A ${CHEM_BOUNDARY_CONDITION_FILE} ${new_lbc}
    let "hr=hr+6"
done
#
# added by J. Huang  09/02/2020

echo "hjp111"
case $MACHINE in

"WCOSS_C" | "WCOSS" | "WCOSS_DELL_P3")

#below added by J.Huang on 9/2/2020
#source ~/.bashrc

module load prod_util/1.1.0

export cyc=$CYCL_HRS
export cycle=t${cyc}z

setpdy.sh

. PDY

echo "hjp222=",$PDY
;;
esac

export COMIN=/gpfs/dell1/ptmp/$USER/rcmaq/${PDY}
export COMINm1=/gpfs/dell1/ptmp/$USER/rcmaq/${PDYm1}
export COMINm2=/gpfs/dell1/ptmp/$USER/rcmaq/${PDYm2}
  

case $cyc in
 00) restart_file1=$COMINm1/18/dynf006.nc
     restart_log1=$COMINm1/rcmaq.t18z.log
     restart_file2=$COMINm1/12/dynf012.nc
     restart_log2=$COMINm1/rcmaq.t12z.log
     restart_file3=$COMINm1/06/dynf018.nc
     restart_log3=$COMINm1/rcmaq.t06z.log
     restart_file4=$COMINm1/00/dynf024.nc
     restart_log4=$COMINm1/rcmaq.t00z.log
     restart_file5=$COMINm2/18/dynf030.nc
     restart_log5=$COMINm2/aqm.t18z.log;;
 06) restart_file1=$COMIN/00/dynf006.nc
     restart_log1=$COMIN/rcmaq.t00z.log
     restart_file2=$COMINm1/18/dynf012.nc
     restart_log2=$COMINm1/rcmaq.t18z.log
     restart_file3=$COMINm1/12/dynf018.nc
     restart_log3=$COMINm1/rcmaq.t12z.log
     restart_file4=$COMINm1/06/dynf024.nc
     restart_log4=$COMINm1/rcmaq.t06z.log
     restart_file5=$COMINm1/00/dynf030.nc
     restart_log5=$COMINm1/aqm.t00z.log;;
 12) restart_file1=$COMIN/06/dynf006.nc
     restart_log1=$COMIN/rcmaq.t06z.log
     restart_file2=$COMIN/00/dynf012.nc
     restart_log2=$COMIN/rcmaq.t00z.log
     restart_file3=$COMINm1/18/dynf018.nc
     restart_log3=$COMINm1/rcmaq.t18z.log
     restart_file4=$COMINm1/12/dynf024.nc
     restart_log4=$COMINm1/rcmaq.t12z.log
     restart_file5=$COMINm1/18/dynf030.nc
     restart_log5=$COMINm1/aqm.t18z.log;;
 18) restart_file1=$COMIN/12/dynf006.nc
     restart_log1=$COMIN/rcmaq.t12z.log
     restart_file2=$COMIN/06/dynf012.nc
     restart_log2=$COMIN/rcmaq.t06z.log
     restart_file3=$COMIN/00/dynf018.nc
     restart_log3=$COMIN/rcmaq.t00z.log
     restart_file4=$COMINm1/18/dynf024.nc
     restart_log4=$COMINm1/rcmaq.t18z.log
     restart_file5=$COMINm1/12/dynf030.nc
     restart_log5=$COMINm1/aqm.t12z.log;;
esac

if [ -s "$restart_file1" ]
then
  restart_file=$restart_file1
  restart_log=$restart_log1
elif [ -s "$restart_file2" ]
then
  restart_file=$restart_file2
  restart_log=$restart_log2
elif [ -s "$restart_file3" ]
then
  restart_file=$restart_file3
  restart_log=$restart_log3
elif [ -s "$restart_file4" ]
then
  restart_file=$restart_file4
  restart_log=$restart_log4
elif [ -s "$restart_file5" ]
then
  restart_file=$restart_file5
  restart_log=$restart_log5
fi

if [ -s "$restart_file" ]
then
 export START=WARM
 export INITIAL_RUN=N
else
  export START=COLD
  export INITIAL_RUN=Y
fi


if [ "$INITIAL_RUN" = "N" ]
then

  cp -rp ${CYCLE_DIR}/INPUT/C401_grid.tile7.halo3.nc ${CYCLE_DIR}/INPUT/C401_grid.tile7.halo3.nc_ori
  ncks -A $restart_file ${CYCLE_DIR}/INPUT/C401_grid.tile7.halo3.nc

  echo "hjp999 is generating new ICs for chemical species"
fi


#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
    print_info_msg "
========================================================================
Successfully copied or linked to external model files on system disk 
needed for generating initial conditions and surface fields for the FV3
forecast!!!

Exiting script:  \"${scrfunc_fn}\"
In directory:    \"${scrfunc_dir}\"
========================================================================"

#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/func-
# tion.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1

