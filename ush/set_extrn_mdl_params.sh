#
#-----------------------------------------------------------------------
#
# This file defines and then calls a function that sets parameters rela-
# ting to the external model used for initial conditions (ICs) and the
# one used for lateral boundary conditions (LBCs).
#
#-----------------------------------------------------------------------
#
function set_extrn_mdl_params() {
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
local scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
local scrfunc_fn=$( basename "${scrfunc_fp}" )
local scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Get the name of this function.
#
#-----------------------------------------------------------------------
#
local func_name="${FUNCNAME[0]}"
#
#-----------------------------------------------------------------------
#
# Set the system directory (i.e. location on disk, not on HPSS) in which
# the files generated by the external model specified by EXTRN_MDL_-
# NAME_ICS that are necessary for generating initial condition (IC)
# and surface files for the FV3-LAM are stored (usually for a limited 
# time, e.g. for the GFS external model, 2 weeks on WCOSS and 2 days on
# theia).  If for a given cycle these files are available in this system
# directory, they will be copied over to a subdirectory within the cy-
# cle's run directory.  If these files are not available in the system
# directory, then we search for them elsewhere, e.g. in the mass store
# (HPSS).
#
#-----------------------------------------------------------------------
#
if [ "${RUN_ENVIR}" = "nco" ]; then

  EXTRN_MDL_SYSBASEDIR_ICS="$COMINgfs"

else

  case ${EXTRN_MDL_NAME_ICS} in

  "GSMGFS")
    case $MACHINE in
    "WCOSS_CRAY")
      EXTRN_MDL_SYSBASEDIR_ICS=""
      ;;
    "WCOSS_DELL_P3")
      EXTRN_MDL_SYSBASEDIR_ICS=""
      ;;
    "HERA")
      EXTRN_MDL_SYSBASEDIR_ICS=""
      ;;
    "JET")
      EXTRN_MDL_SYSBASEDIR_ICS=""
      ;;
    "ODIN")
      EXTRN_MDL_SYSBASEDIR_ICS="/scratch/ywang/EPIC/GDAS/2019053000_mem001"
      ;;
    "CHEYENNE")
      EXTRN_MDL_SYSBASEDIR_ICS="/glade/p/ral/jntp/UFS_CAM/COMGFS"
      ;;
    "STAMPEDE")
      EXTRN_MDL_SYSBASEDIR_ICS="/scratch/00315/tg455890/GDAS/20190530/2019053000_mem001"
      ;;
    esac
    ;;

  "FV3GFS")
    case $MACHINE in
    "WCOSS_CRAY")
      EXTRN_MDL_SYSBASEDIR_ICS="/gpfs/dell1/nco/ops/com/gfs/prod"
      ;;
    "WCOSS_DELL_P3")
      EXTRN_MDL_SYSBASEDIR_ICS="/gpfs/dell1/nco/ops/com/gfs/prod"
      ;;
    "HERA")
      EXTRN_MDL_SYSBASEDIR_ICS="/scratch1/NCEPDEV/rstprod/com/gfs/prod"
      ;;
    "JET")
      EXTRN_MDL_SYSBASEDIR_ICS="/public/data/grids/gfs/nemsio"
      ;;
    "ODIN")
      EXTRN_MDL_SYSBASEDIR_ICS="/scratch/ywang/test_runs/FV3_regional/gfs"
      ;;
    "CHEYENNE")
      EXTRN_MDL_SYSBASEDIR_ICS="/glade/p/ral/jntp/UFS_CAM/COMGFS"
      ;;
    esac
    ;;

  "RAPX")
    case $MACHINE in
    "HERA")
      EXTRN_MDL_SYSBASEDIR_ICS="/scratch2/BMC/public/data/gsd/rap/full/wrfnat"
      ;;
    "JET")
      EXTRN_MDL_SYSBASEDIR_ICS="/misc/whome/rtrr/rap"
      ;;
# This goes with the comment below for the if-statement (-z EXTRN_MDL_SYSBASEDIR_ICS).
# Should not need this case.
    "CHEYENNE")
      EXTRN_MDL_SYSBASEDIR_ICS="dummy_value"
      ;;
    esac
    ;;

  "HRRRX")
    case $MACHINE in
    "HERA")
      EXTRN_MDL_SYSBASEDIR_ICS="/scratch2/BMC/public/data/gsd/hrrr/conus/wrfnat"
      ;;
    "JET")
      EXTRN_MDL_SYSBASEDIR_ICS="/misc/whome/rtrr/hrrr"
      ;;
    "CHEYENNE")
      EXTRN_MDL_SYSBASEDIR_ICS="dummy_value"
      ;;
    esac
    ;;

  esac

fi

# This approach needs to be rechecked.  It gives this error if EXTRN_MDL_SYSBASEDIR_ICS
# does not get set above:
# ./set_extrn_mdl_params.sh: line 134: EXTRN_MDL_SYSBASEDIR_ICS: unbound variable
if [ -z "${EXTRN_MDL_SYSBASEDIR_ICS}" ]; then
  print_err_msg_exit "\
The variable EXTRN_MDL_SYSBASEDIR_ICS specifying the system directory
in which to look for the files generated by the external model for ICs
has not been set for the current combination of machine (MACHINE) and 
external model (EXTRN_MDL_NAME_ICS):
  MACHINE = \"$MACHINE\"
  EXTRN_MDL_NAME_ICS = \"${EXTRN_MDL_NAME_ICS}\""
fi
#
#-----------------------------------------------------------------------
#
# Set EXTRN_MDL_LBCS_OFFSET_HRS, which is the number of hours to
# shift the starting time of the external model that provides lateral
# boundary conditions.
#
#-----------------------------------------------------------------------
#
case ${EXTRN_MDL_NAME_LBCS} in
  "GSMGFS")
    EXTRN_MDL_LBCS_OFFSET_HRS="0"
    ;;
  "FV3GFS")
    EXTRN_MDL_LBCS_OFFSET_HRS="0"
    ;;
  "RAPX")
    EXTRN_MDL_LBCS_OFFSET_HRS="3"
    ;;
  "HRRRX")
    EXTRN_MDL_LBCS_OFFSET_HRS="0"
    ;;
esac
#
#-----------------------------------------------------------------------
#
# Set the system directory (i.e. location on disk, not on HPSS) in which
# the files generated by the external model specified by EXTRN_MDL_-
# NAME_LBCS that are necessary for generating lateral boundary condition
# (LBC) files for the FV3-LAM are stored (usually for a limited time, 
# e.g. for the GFS external model, 2 weeks on WCOSS and 2 days on the-
# ia).  If for a given cycle these files are available in this system 
# directory, they will be copied over to a subdirectory within the cy-
# cle's run directory.  If these files are not available in the system
# directory, then we search for them elsewhere, e.g. in the mass store
# (HPSS).
#
#-----------------------------------------------------------------------
#
if [ "${RUN_ENVIR}" = "nco" ]; then

  EXTRN_MDL_SYSBASEDIR_LBCS="$COMINgfs"

else

  case ${EXTRN_MDL_NAME_LBCS} in

  "GSMGFS")
    case $MACHINE in
    "WCOSS_CRAY")
      EXTRN_MDL_SYSBASEDIR_LBCS=""
      ;;
    "WCOSS_DELL_P3")
      EXTRN_MDL_SYSBASEDIR_LBCS=""
      ;;
    "HERA")
      EXTRN_MDL_SYSBASEDIR_LBCS=""
      ;;
    "JET")
      EXTRN_MDL_SYSBASEDIR_LBCS=""
      ;;
    "ODIN")
      EXTRN_MDL_SYSBASEDIR_LBCS="/scratch/ywang/EPIC/GDAS/2019053000_mem001"
      ;;
    "CHEYENNE")
      EXTRN_MDL_SYSBASEDIR_LBCS="/glade/p/ral/jntp/UFS_CAM/COMGFS"
      ;;
    "STAMPEDE")
      EXTRN_MDL_SYSBASEDIR_LBCS="/scratch/00315/tg455890/GDAS/20190530/2019053000_mem001"
      ;;
    esac
    ;;

  "FV3GFS")
    case $MACHINE in
    "WCOSS_CRAY")
      EXTRN_MDL_SYSBASEDIR_LBCS="/gpfs/dell1/nco/ops/com/gfs/prod"
      ;;
    "WCOSS_DELL_P3")
      EXTRN_MDL_SYSBASEDIR_LBCS="/gpfs/dell1/nco/ops/com/gfs/prod"
      ;;
    "HERA")
      EXTRN_MDL_SYSBASEDIR_LBCS="/scratch1/NCEPDEV/rstprod/com/gfs/prod"
      ;;
    "JET")
      EXTRN_MDL_SYSBASEDIR_LBCS="/public/data/grids/gfs/nemsio"
      ;;
    "ODIN")
      EXTRN_MDL_SYSBASEDIR_LBCS="/scratch/ywang/test_runs/FV3_regional/gfs"
      ;;
    "CHEYENNE")
      EXTRN_MDL_SYSBASEDIR_LBCS="/glade/p/ral/jntp/UFS_CAM/COMGFS"
      ;;
    esac
    ;;

  "RAPX")
    case $MACHINE in
    "HERA")
      EXTRN_MDL_SYSBASEDIR_LBCS="/scratch2/BMC/public/data/gsd/rap/full/wrfnat"
      ;;
    "JET")
      EXTRN_MDL_SYSBASEDIR_LBCS="/misc/whome/rtrr/rap"
      ;;
    "CHEYENNE")
      EXTRN_MDL_SYSBASEDIR_LBCS="dummy_value"
      ;;
    esac
    ;;

  "HRRRX")
    case $MACHINE in
    "HERA")
      EXTRN_MDL_SYSBASEDIR_LBCS="/scratch2/BMC/public/data/gsd/hrrr/conus/wrfnat"
      ;;
    "JET")
      EXTRN_MDL_SYSBASEDIR_LBCS="/misc/whome/rtrr/hrrr"
      ;;
    esac
    ;;

  esac

fi

# This approach needs to be rechecked.
if [ -z "${EXTRN_MDL_SYSBASEDIR_LBCS}" ]; then
  print_err_msg_exit "\
The variable EXTRN_MDL_SYSBASEDIR_LBCS specifying the system directory
in which to look for the files generated by the external model for LBCs
has not been set for the current combination of machine (MACHINE) and 
external model (EXTRN_MDL_NAME_LBCS):
  MACHINE = \"$MACHINE\"
  EXTRN_MDL_NAME_LBCS = \"${EXTRN_MDL_NAME_LBCS}\""
fi
}
#
#-----------------------------------------------------------------------
#
# Call the function defined above.
#
#-----------------------------------------------------------------------
#
set_extrn_mdl_params
