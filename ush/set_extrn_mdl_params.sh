#
#-----------------------------------------------------------------------
#
# This file defines and then calls a function that sets known locations
# of files on supported platforms.
#
#-----------------------------------------------------------------------
#
function set_extrn_mdl_params() {

  #
  #-----------------------------------------------------------------------
  #
  # Use COMINgfs as external model input source, if specified in NCO
  # mode.
  #
  #-----------------------------------------------------------------------
  #
  if [ "${RUN_ENVIR}" = "nco" ]; then
    if [ -d "$COMINgfs" ] ; then
      EXTRN_MDL_SYSBASEDIR_ICS="${COMINgfs}"
      EXTRN_MDL_SYSBASEDIR_LBCS="${COMINgfs}"
    fi
  fi

  #
  #-----------------------------------------------------------------------
  #
  # Set EXTRN_MDL_LBCS_OFFSET_HRS, which is the number of hours to shift 
  # the starting time of the external model that provides lateral boundary 
  # conditions.
  #
  #-----------------------------------------------------------------------
  #
  EXTRN_MDL_LBCS_OFFSET_HRS=${EXTRN_MDL_LBCS_OFFSET_HRS:-"0"}
  case "${EXTRN_MDL_NAME_LBCS}" in
    "RAP")
      EXTRN_MDL_LBCS_OFFSET_HRS=${EXTRN_MDL_LBCS_OFFSET_HRS:-"3"}
      ;;
  esac
}
#
#-----------------------------------------------------------------------
#
# Call the function defined above.
#
#-----------------------------------------------------------------------
#
set_extrn_mdl_params
