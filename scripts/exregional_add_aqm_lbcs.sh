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
scrfunc_fp=$( $READLINK -f "${BASH_SOURCE[0]}" )
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

This is the ex-script for the task that generates chemical and GEFS
lateral boundary conditions.
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
valid_args=( "lbcs_dir" "workdir" )
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
print_input_args valid_args
#
# Set OpenMP variables.
#
#-----------------------------------------------------------------------
#
export KMP_AFFINITY=${KMP_AFFINITY_MAKE_LBCS}
export OMP_NUM_THREADS=${OMP_NUM_THREADS_MAKE_LBCS}
export OMP_STACKSIZE=${OMP_STACKSIZE_MAKE_LBCS}
#
#-----------------------------------------------------------------------
#
# Set machine-dependent parameters.
#
#-----------------------------------------------------------------------
#
  case "$MACHINE" in

    "WCOSS_CRAY")
      ulimit -s unlimited
      ulimit -a
      APRUN="aprun -b -j1 -n48 -N12 -d1 -cc depth"
      ;;

    "WCOSS_DELL_P3")
      ulimit -s unlimited
      ulimit -a
      APRUN="mpirun"
      ;;

    "HERA")
      ulimit -s unlimited
      ulimit -a
      APRUN="srun"
      ;;

    "ORION")
      ulimit -s unlimited
      ulimit -a
      APRUN="srun"
      ;;

    "JET")
      ulimit -s unlimited
      ulimit -a
      APRUN="srun"
      ;;

    "ODIN")
      APRUN="srun"
      ;;

    "CHEYENNE")
      nprocs=$(( NNODES_MAKE_LBCS*PPN_MAKE_LBCS ))
      APRUN="mpirun -np $nprocs"
      ;;

    "STAMPEDE")
      APRUN="ibrun"
      ;;
  esac
#
#-----------------------------------------------------------------------
#
# Move to working directory
#
#-----------------------------------------------------------------------
#
cd_vrfy $workdir
#
#-----------------------------------------------------------------------
#
# Add chemical LBCS
#
#-----------------------------------------------------------------------
#
yyyymmdd="${PDY:0:8}"
mm="${PDY:4:2}"

if [ ${RUN_ADD_AQM_CHEM_LBCS} = "TRUE" ]; then

  ext_lbcs_file=${AQM_LBCS_FILES}
  ext_lbcs_file=${ext_lbcs_file//<MM>/${mm}}

  CHEM_BOUNDARY_CONDITION_FILE=${ext_lbcs_file}

  FULL_CHEMICAL_BOUNDARY_FILE=${AQM_LBCS_DIR}/${CHEM_BOUNDARY_CONDITION_FILE}
  if [ -f ${FULL_CHEMICAL_BOUNDARY_FILE} ]; then
    #Copy the boundary condition file to the current location
    cp_vrfy ${FULL_CHEMICAL_BOUNDARY_FILE} .
  else
    print_err_msg_exit "\
The chemical LBC files do not exist:
  CHEM_BOUNDARY_CONDITION_FILE = \"${CHEM_BOUNDARY_CONDITION_FILE}\""
  fi

  for hr in 0 ${LBC_SPEC_FCST_HRS[@]}; do
    fhr=$( printf "%03d" "${hr}" )
    if [ -r ${lbcs_dir}/gfs_bndy.tile7.${fhr}.nc ]; then
        ncks -A ${CHEM_BOUNDARY_CONDITION_FILE} ${lbcs_dir}/gfs_bndy.tile7.${fhr}.nc
    fi
  done

  print_info_msg "
========================================================================
Successfully added chemical LBCs !!!
========================================================================"
fi
#
#-----------------------------------------------------------------------
#
# Add GEFS-LBCS
#
#-----------------------------------------------------------------------
#
if [ ${RUN_ADD_AQM_GEFS_LBCS} = "TRUE" ]; then

  cp_vrfy ${lbcs_dir}/gfs_bndy.tile7.???.nc $workdir

  RUN_CYC="${CDATE:8:2}"

  GEFS_CYC_DIFF=$( printf "%02d" "$(( ${RUN_CYC} - ${AQM_GEFS_CYC} ))" )

  NUMTS="$(( ${FCST_LEN_HRS} / ${LBC_SPEC_INTVL_HRS} + 1 ))"

cat > gefs2lbc-nemsio.ini <<EOF
&control
 tstepdiff=${GEFS_CYC_DIFF}
 dtstep=${LBC_SPEC_INTVL_HRS}
 bndname='aothrj','aecj','aorgcj','asoil','numacc','numcor'
 mofile='${AQM_GEFS_DIR}/$yyyymmdd/${AQM_GEFS_CYC}/gfs.t00z.atmf','.nemsio'
 lbcfile='${lbcs_dir}/gfs_bndy.tile7.','.nc'
 topofile='${OROG_DIR}/${CRES}_oro_data.tile7.halo4.nc'
&end

Species converting Factor
# Gocart ug/m3 to regional ug/m3
'dust1'    2  ## 0.2-2um diameter: assuming mean diameter is 0.3 um (volume= 0.01414x10^-18 m3) and density is 2.6x10^3 kg/m3 or 2.6x10^12 ug/m3.so 1 particle = 0.036x10^-6 ug
'aothrj'  1.0   'numacc' 27205909.
'dust2'    4  ## 2-4um
'aothrj'  0.45    'numacc'  330882.  'asoil'  0.55   'numcor'  50607.
'dust3'    2  ## 4-6um
'asoil'   1.0   'numcor' 11501.
'dust4'    2   ## 6-12um
'asoil'  0.7586   'numcor' 1437.
'bc1'      2     # kg/kg
'aecj'     1.0   'numacc' 6775815.
'bc2'  2     # kg/kg
'aecj'     1.0   'numacc' 6775815.
'oc1'  2     # kg/kg OC -> organic matter
'aorgcj'    1.0   'numacc' 6775815.
'oc2'  2
'aorgcj'  1.0   'numacc' 6775815.
EOF

  exec_fn="gefs2lbc_para"
  exec_fp="$EXECDIR/${exec_fn}"
  if [ ! -f "${exec_fp}" ]; then
    print_err_msg_exit "\
The executable (exec_fp) for GEFS LBCs does not exist:
  exec_fp = \"${exec_fp}\"
Please ensure that you've built this executable."
  fi
#
#----------------------------------------------------------------------
#
# Run the executable
#
#----------------------------------------------------------------------
#
  ${APRUN} -n ${NUMTS} ${exec_fp} || \
    print_err_msg_exit "\
Call to executable (exec_fp) to generate chemical and GEFS LBCs
file for RRFS-CMAQ failed:
  exec_fp = \"${exec_fp}\""

  print_info_msg "
========================================================================
Successfully added GEFS aerosol LBCs !!!
========================================================================"
#
fi
#
print_info_msg "
========================================================================
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

