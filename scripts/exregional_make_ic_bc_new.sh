#!/bin/bash -l
#
#-----------------------------------------------------------------------
#
# This script generates:
#
# 1) A NetCDF initial condition (IC) file on a regional grid for the
#    date/time on which the analysis files in the directory specified by
#    INIDIR are valid.  Note that this file does not include data in the
#    halo of this regional grid (that data is found in the boundary con-
#    dition (BC) files).
#
# 2) A NetCDF surface file on the regional grid.  As with the IC file,
#    this file does not include data in the halo.
#
# 3) A NetCDF boundary condition (BC) file containing data on the halo
#    of the regional grid at the initial time (i.e. at the same time as
#    the one at which the IC file is valid).
#
# 4) A NetCDF "control" file named gfs_ctrl.nc that contains infor-
#    mation on the vertical coordinate and the number of tracers for
#    which initial and boundary conditions are provided.
#
# All four of these NetCDF files are placed in the directory specified
# by WORKDIR_ICSLBCS_CDATE, defined as
#
#   WORKDIR_ICSLBCS_CDATE="$WORKDIR_ICSLBCS/$CDATE"
#
# where CDATE is the externally specified starting date and cycle hour
# of the current forecast.
#
#-----------------------------------------------------------------------

#
#-----------------------------------------------------------------------
#
# Source the variable definitions script.
#
#-----------------------------------------------------------------------
#
. $SCRIPT_VAR_DEFNS_FP

. $HOMEfv3/jobs/JFV3CAM_SAR_ENVIR
COMOUT=${COMROOT}/${NET}/${envir}/${RUN}.${PDY}/${cyc}

#
#-----------------------------------------------------------------------
#
# Source function definition files.
#
#-----------------------------------------------------------------------
#
. $USHDIR/source_funcs.sh
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; set -u -x; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# Set the name of and create the directory in which the output from this
# script will be placed (if it doesn't already exist).
#
#-----------------------------------------------------------------------
#
if [ $RUN_ENVIR = "nco" ]; then
  WORKDIR_ICSLBCS_CDATE=$COMOUT/anl.${dom}.$tmark
else
  WORKDIR_ICSLBCS_CDATE="$WORKDIR_ICSLBCS/$CDATE"
fi
WORKDIR_ICSLBCS_CDATE_ICSSURF_WORK="$WORKDIR_ICSLBCS_CDATE/ICSSURF_work"
mkdir_vrfy -p "$WORKDIR_ICSLBCS_CDATE_ICSSURF_WORK"
cd_vrfy ${WORKDIR_ICSLBCS_CDATE_ICSSURF_WORK}
#
#-----------------------------------------------------------------------
#
# Load modules and set machine-dependent parameters.
#
#-----------------------------------------------------------------------
#
case "$MACHINE" in
#
"WCOSS_C")
#
  { save_shell_opts; set +x; } > /dev/null 2>&1

  { restore_shell_opts; } > /dev/null 2>&1
  ;;
#
"WCOSS")
#
  { save_shell_opts; set +x; } > /dev/null 2>&1

  { restore_shell_opts; } > /dev/null 2>&1
  ;;
#
"DELL")
#
  { save_shell_opts; set +x; } > /dev/null 2>&1

  { restore_shell_opts; } > /dev/null 2>&1
  ;;
#
"THEIA")
#
  { save_shell_opts; set +x; } > /dev/null 2>&1

   ulimit -s unlimited
   ulimit -a

   module purge
   module load intel/18.1.163
   module load impi/5.1.1.109
   module load netcdf/4.3.0
   module load hdf5/1.8.14
   module load wgrib2/2.0.8
   module load contrib wrap-mpi
   module list

  np=${SLURM_NTASKS}
  APRUN="mpirun -np ${np}"

  { restore_shell_opts; } > /dev/null 2>&1
  ;;
#
"JET")
#
  { save_shell_opts; set +x; } > /dev/null 2>&1

  { restore_shell_opts; } > /dev/null 2>&1
  ;;
#
"ODIN")
#
  ;;
#
"CHEYENNE")
#
  ;;
#
esac
#
#-----------------------------------------------------------------------
#
# Create links to the grid and orography files with 4 halo cells.  These
# are needed by chgres_cube to create the boundary data.
#
#-----------------------------------------------------------------------
#
# Are these still needed for chgres_cube?  I don't think so; try commenting out.
#
ln_vrfy -sf $WORKDIR_SHVE/${CRES}_grid.tile7.halo${nh4_T7}.nc \
            $WORKDIR_SHVE/${CRES}_grid.tile7.nc

ln_vrfy -sf $WORKDIR_SHVE/${CRES}_oro_data.tile7.halo${nh4_T7}.nc \
            $WORKDIR_SHVE/${CRES}_oro_data.tile7.nc
#
#-----------------------------------------------------------------------
#
# Find the directory in which the wgrib2 executable is located.
#
#-----------------------------------------------------------------------
#
WGRIB2_DIR=$( which wgrib2 ) || print_err_msg_exit "\
Directory in which the wgrib2 executable is located not found:
  WGRIB2_DIR = \"${WGRIB2_DIR}\"
"
#
#-----------------------------------------------------------------------
#
# Set the directory containing the external model output files.
#
#-----------------------------------------------------------------------
#
EXTRN_MDL_FILES_DIR="${EXTRN_MDL_FILES_BASEDIR_ICSSURF}/${CDATE}"
#
#-----------------------------------------------------------------------
#
# Source the file (generated by a previous task) that contains variable
# definitions (e.g. forecast hours, file and directory names, etc) re-
# lated to the exteranl model run that is providing fields from which
# we will generate LBC files for the FV3SAR.
#
#-----------------------------------------------------------------------
#
. ${EXTRN_MDL_FILES_DIR}/${EXTRN_MDL_INFO_FN}




#
#-----------------------------------------------------------------------
#
# Get the name of the external model to use in the chgres FORTRAN name-
# list file.
#
#-----------------------------------------------------------------------
#
case "$EXTRN_MDL_NAME_ICSSURF" in
#
"GFS")
  external_model="GFS"
  ;;
"RAPX")
  external_model="RAP"
  ;;
"HRRRX")
  external_model="HRRR"
  ;;
*)
  print_err_msg_exit "\
The external model name to use in the chgres FORTRAN namelist file is 
not specified for this external model:
  EXTRN_MDL_NAME_ICSSURF = \"${EXTRN_MDL_NAME_ICSSURF}\"
"
  ;;
#
esac
#
#-----------------------------------------------------------------------
#
# Get the name of the physics suite to use in the chgres FORTRAN name-
# list file.
#
#-----------------------------------------------------------------------
#
case "$CCPP_phys_suite" in
#
"GFS")
  phys_suite="GFS"
  ;;
"GSD")
  phys_suite="GSD"
  ;;
*)
  print_err_msg_exit "\
The physics suite name to use in the chgres FORTRAN namelist file is not
specified for this physics suite:
  CCPP_phys_suite = \"${CCPP_phys_suite}\"
"
  ;;
#
esac
#
#-----------------------------------------------------------------------
#
# Get the starting year, month, day, and hour of the the external model
# run.
#
#-----------------------------------------------------------------------
#
#yyyy="${EXTRN_MDL_CDATE:0:4}"
mm="${EXTRN_MDL_CDATE:4:2}"
dd="${EXTRN_MDL_CDATE:6:2}"
hh="${EXTRN_MDL_CDATE:8:2}"
#yyyymmdd="${EXTRN_MDL_CDATE:0:8}"
#
#-----------------------------------------------------------------------
#
# Set external model output file name(s) and file type/format.  Note 
# that these are now inputs into chgres.
#
#-----------------------------------------------------------------------
#
fn_atm_nemsio=""
fn_sfc_nemsio=""
fn_grib2=""
input_type=""

case "$EXTRN_MDL_NAME_ICSSURF" in
"GFS")
  fn_atm_nemsio="${EXTRN_MDL_FNS[0]}"
  fn_sfc_nemsio="${EXTRN_MDL_FNS[1]}"
# This has to be fixed to that for EXTRN_MDL_NAME_ICSSURF, there is a "GFS_GAUSSIAN" (or better yet, spectral)
# and a "GFS-FV3" option!!!
  input_type="gfs_gaussian" # For spectral GFS Gaussian grid in nemsio format.
#  input_type="gaussian"     # For FV3-GFS Gaussian grid in nemsio format.
  ;;
"RAPX")
  fn_grib2="${EXTRN_MDL_FNS[0]}"
  input_type="grib2"
  ;;
"HRRRX")
  fn_grib2="${EXTRN_MDL_FNS[0]}"
  input_type="grib2"
  ;;
*)
  print_err_msg_exit "\
The external model output file name(s) and file type/format to use in the
chgres FORTRAN namelist file are not specified for this external model:
  EXTRN_MDL_NAME_ICSSURF = \"${EXTRN_MDL_NAME_ICSSURF}\"
"
  ;;
esac
#
#-----------------------------------------------------------------------
#
# Set various external model-dependent namelist options to chgres_cube.
#
#-----------------------------------------------------------------------
#
case "$EXTRN_MDL_NAME_ICSSURF" in

"GFS")
#
# The following are the three atmsopheric tracers that are in the atmo-
# spheric analysis (atmanl) nemsio file for CDATE=2017100700:
#
#   "spfh","o3mr","clwmr"
#
# Note also that these are hardcoded in the code (file input_data.F90, 
# subroutine read_input_atm_gfs_spectral_file), so that subroutine will
# break if tracers_input(:) is not specified as above.
#
# Note that there are other fields too ["hgt" (surface height (togography?)), 
# pres (surface pressure), ugrd, vgrd, and tmp (temperature)] in the atmanl file, but those
# are not considered tracers (they're categorized as dynamics variables,
# I guess).
#
# Another note:  The way things are set up now, tracers_input(:) and 
# tracers(:) are assumed to have the same number of elements (just the
# atmospheric tracer names in the input and output files may be differ-
# ent).  There needs to be a check for this in the chgres_cube code!!
# If there was a varmap table that specifies how to handle missing 
# fields, that would solve this problem.
#
# Also, it seems like the order of tracers in tracers_input(:) and 
# tracers(:) must match, e.g. if ozone mixing ratio is 3rd in 
# tracers_input(:), it must also be 3rd in tracers(:).  How can this be checked?
#
# NOTE: Really should use a varmap table for GFS, just like we do for 
# RAP/HRRR.
#

# A non-prognostic variable that appears in the field_table for GSD physics 
# is cld_amt.  Why is that in the field_table at all (since it is a non-
# prognostic field), and how should we handle it here??

# I guess this works for spectral GFS but not for FV3GFS since the nemsio
# output files of those have different variable names (see below).
  tracers_input="\"spfh\",\"o3mr\",\"clwmr\""
# I guess this works for FV3GFS but not for the spectral GFS since these
# variables won't exist in the spectral GFS atmanl files.
#  tracers_input="\"sphum\",\"liq_wat\",\"ice_wat\",\"rainwat\",\"snowwat\",\"graupel\",\"o3mr\""
#
# Not sure if tracers(:) should include "cld_amt" since that is also in
# the field_table for CDATE=2017100700 but is a non-prognostic variable.
#
#  tracers="\"sphum\",\"liq_wat\",\"ice_wat\",\"rainwat\",\"snowwat\",\"graupel\",\"o3mr\""
  tracers="\"sphum\",\"o3mr\",\"liq_wat\""
#
  numsoil_out="4"
  geogrid_file_input_grid=""  # How to get this to not be used???
  replace_vgtyp=".true."
  replace_sotyp=".true."
  replace_vgfrc=".true."
  tg3_from_soil=".false."
  ;;

"HRRRX")
# Don't set these; tracers(:) won't get used, and tracers_input(:) will
# get set to the value specified in the varmap table.
# Maybe better to set them to blank?  Not sure...
  tracers_input="\"\""
  tracers="\"\""
#
  numsoil_out="9"
  geogrid_file_input_grid="/scratch3/BMC/det/beck/FV3-CAM/geo_em.d01.nc"  # As of 2019-06-19, this parameter is only used if reading in HRRR grib2 files.
  replace_vgtyp=".false."
  replace_sotyp=".false."
  replace_vgfrc=".false."
  tg3_from_soil=".true."
  ;;

*)
  print_err_msg_exit "\
One or more chgres_cube namelist variables have not been specified for
the specifed external model used to generate ICs, surface fields, and
the first LBC:

  EXTRN_MDL_NAME_ICSSURF = \"${EXTRN_MDL_NAME_ICSSURF}\"

Unspecified namelist variables:

  tracers_input
  tracers
  numsoil_out
  geogrid_file_input_grid
  replace_vgtyp
  replace_sotyp
  replace_vgfrc
  tg3_from_soil
"
  ;;

esac
#
#-----------------------------------------------------------------------
#
# Build the FORTRAN namelist file that chgres_cube will read in.
#
#-----------------------------------------------------------------------
#

# For GFS physics, the character arrays tracers_input(:) and tracers(:)
# must be specified in the namelist file.  tracers_input(:) contains the
# tracer name to look for in the external model file(s), while tracers(:)
# contains the names to use for the tracers in the output NetCDF files 
# that chgres creates (that will be read in by FV3).  Since when FV3 
# reads these NetCDF files it looks for atmospheric traces as specified
# in the file field_table, tracers(:) should be set to the names in 
# field_table.
#
# NOTE: This process should be automated where the set of elements that
# tracers(:) should be set to is obtained from reading in field_table.
#
# To know how to set tracers_input(:), you have to know the names of the
# variables in the input atmospheric nemsio file (usually this file is 
# named gfs.t00z.atmanl.nemsio).
#
# It is not quite clear how these should be specified.  Here are a list
# of examples:
#
# [Gerard.Ketefian@tfe05] /scratch3/.../chgres_cube.fd/run (feature/chgres_grib2_gsk)
# $ grep -n -i "tracers" * | grep theia
# config.C1152.l91.atm.theia.nml:24: tracers="sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"
# config.C1152.l91.atm.theia.nml:25: tracers_input="sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"
# config.C48.gaussian.theia.nml:20: tracers="sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"
# config.C48.gaussian.theia.nml:21: tracers_input="spfh","clwmr","o3mr","icmr","rwmr","snmr","grle"
# config.C48.gfs.gaussian.theia.nml:21: tracers="sphum","liq_wat","o3mr"
# config.C48.gfs.gaussian.theia.nml:22: tracers_input="spfh","clwmr","o3mr"
# config.C48.gfs.spectral.theia.nml:21: tracers_input="spfh","o3mr","clwmr"
# config.C48.gfs.spectral.theia.nml:22: tracers="sphum","o3mr","liq_wat"
# config.C48.theia.nml:21: tracers="sphum","liq_wat","o3mr"
# config.C48.theia.nml:22: tracers_input="spfh","clwmr","o3mr"
# config.C768.atm.theia.nml:24: tracers="sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"
# config.C768.atm.theia.nml:25: tracers_input="sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"
# config.C768.l91.atm.theia.nml:24: tracers="sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"
# config.C768.l91.atm.theia.nml:25: tracers_input="sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"
# config.C768.nest.atm.theia.nml:22: tracers="sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"
# config.C768.nest.atm.theia.nml:23: tracers_input="sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"


# fix_dir_target_grid="${BASEDIR}/JP_grid_HRRR_like_fix_files_chgres_cube"
# base_install_dir="${SORCDIR}/chgres_cube.fd"

#
# As an alternative to the cat command below, we can have a template for
# the namelist file and use the set_file_param(.sh) function to set 
# namelist entries in it.  The set_file_param function will print out a
# message and exit if it fails to set a variable in the file.
#

{ cat > fort.41 <<EOF
&config
 fix_dir_target_grid="${WORKDIR_SFC_CLIMO}"
 mosaic_file_target_grid="${EXPTDIR}/INPUT/${CRES}_mosaic.nc"
 orog_dir_target_grid="${EXPTDIR}/INPUT"
 orog_files_target_grid="${CRES}_oro_data.tile7.halo${nh4_T7}.nc"
 vcoord_file_target_grid="${FV3SAR_DIR}/fix/fix_am/global_hyblev.l65.txt"
 mosaic_file_input_grid=""
 orog_dir_input_grid=""
 base_install_dir="${BASEDIR}/UFS_UTILS_chgres_grib2"
 wgrib2_path="${WGRIB2_DIR}"
 data_dir_input_grid="${EXTRN_MDL_FILES_DIR}"
 atm_files_input_grid="${fn_atm_nemsio}"
 sfc_files_input_grid="${fn_sfc_nemsio}"
 grib2_file_input_grid="${fn_grib2}"
 cycle_mon=${mm}
 cycle_day=${dd}
 cycle_hour=${hh}
 convert_atm=.true.
 convert_sfc=.true.
 convert_nst=.false.
 regional=1
 halo_bndy=${nh4_T7}
 input_type="${input_type}"
 external_model="${external_model}"
 tracers_input=${tracers_input}
 tracers=${tracers}
 phys_suite="${phys_suite}"
 numsoil_out=${numsoil_out}
 geogrid_file_input_grid="${geogrid_file_input_grid}"
 replace_vgtyp=${replace_vgtyp}
 replace_sotyp=${replace_sotyp}
 replace_vgfrc=${replace_vgfrc}
 tg3_from_soil=${tg3_from_soil}
/
EOF
} || print_err_msg_exit "\
\"cat\" command to create a namelist file for chgres_cube to generate ICs,
surface fields, and the 0-th hour (initial) LBCs returned with nonzero 
status."

# tracers_input= "sphum","liq_wat","o3mr"
# tracers_input= "spfh","clwmr","o3mr"
#
#-----------------------------------------------------------------------
#
# Run chgres_cube.
#
#-----------------------------------------------------------------------
#
#${APRUN} ${EXECDIR}/global_chgres.exe || print_err_msg_exit "\
#${APRUN} ${EXECDIR}/chgres_cube.exe || print_err_msg_exit "\
${APRUN} ${BASEDIR}/UFS_UTILS_chgres_grib2/exec/chgres_cube.exe || print_err_msg_exit "\
Call to executable to generate surface and initial conditions files for
the FV3SAR failed:
  EXTRN_MDL_NAME_ICSSURF = \"${EXTRN_MDL_NAME_ICSSURF}\"
  EXTRN_MDL_FILES_DIR = \"${EXTRN_MDL_FILES_DIR}\"
"
#
#-----------------------------------------------------------------------
#
# Move initial condition, surface, control, and 0-th hour lateral bound-
# ary files to ICs_BCs directory. 
#
#-----------------------------------------------------------------------
#
mv_vrfy out.atm.tile7.nc ${WORKDIR_ICSLBCS_CDATE}/gfs_data.tile7.nc
mv_vrfy out.sfc.tile7.nc ${WORKDIR_ICSLBCS_CDATE}/sfc_data.tile7.nc
mv_vrfy gfs_ctrl.nc ${WORKDIR_ICSLBCS_CDATE}
mv_vrfy gfs_bndy.nc ${WORKDIR_ICSLBCS_CDATE}/gfs_bndy.tile7.000.nc
#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
print_info_msg "\

========================================================================
Initial condition, surface, and 0-th hour lateral boundary condition
files (in NetCDF format) generated successfully!!!
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
