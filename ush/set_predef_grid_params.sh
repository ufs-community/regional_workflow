#
#-----------------------------------------------------------------------
#
# This file defines and then calls a function that sets grid parameters
# for the specified predefined grid.
#
#-----------------------------------------------------------------------
#
function set_predef_grid_params() {
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
  local scrfunc_fp=$( $READLINK -f "${BASH_SOURCE[0]}" )
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
# Set directories.
#
#-----------------------------------------------------------------------
#
  local homerrfs=${scrfunc_dir%/*}
  local ushdir="$homerrfs/ush"
#
#-----------------------------------------------------------------------
#
# Source the file containing various mathematical, physical, etc constants.
#
#-----------------------------------------------------------------------
#
  . $ushdir/constants.sh
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
  local valid_args=( \
    "predef_grid_name" \
    "dt_atmos" \
    "layout_x" \
    "layout_y" \
    "blocksize" \
    "quilting" \
    "outvarname_grid_gen_method" \
    "outvarname_esggrid_lon_ctr" \
    "outvarname_esggrid_lat_ctr" \
    "outvarname_esggrid_delx" \
    "outvarname_esggrid_dely" \
    "outvarname_esggrid_nx" \
    "outvarname_esggrid_ny" \
    "outvarname_esggrid_pazi" \
    "outvarname_esggrid_wide_halo_width" \
    "outvarname_gfdlgrid_lon_t6_ctr" \
    "outvarname_gfdlgrid_lat_t6_ctr" \
    "outvarname_gfdlgrid_stretch_fac" \
    "outvarname_gfdlgrid_res" \
    "outvarname_gfdlgrid_refine_ratio" \
    "outvarname_gfdlgrid_istart_of_rgnl_dom_on_t6g" \
    "outvarname_gfdlgrid_iend_of_rgnl_dom_on_t6g" \
    "outvarname_gfdlgrid_jstart_of_rgnl_dom_on_t6g" \
    "outvarname_gfdlgrid_jend_of_rgnl_dom_on_t6g" \
    "outvarname_gfdlgrid_use_gfdlgrid_res_in_filenames" \
    "outvarname_dt_atmos" \
    "outvarname_layout_x" \
    "outvarname_layout_y" \
    "outvarname_blocksize" \
    "outvarname_wrtcmp_write_groups" \
    "outvarname_wrtcmp_write_tasks_per_group" \
    "outvarname_wrtcmp_output_grid" \
    "outvarname_wrtcmp_cen_lon" \
    "outvarname_wrtcmp_cen_lat" \
    "outvarname_wrtcmp_stdlat1" \
    "outvarname_wrtcmp_stdlat2" \
    "outvarname_wrtcmp_nx" \
    "outvarname_wrtcmp_ny" \
    "outvarname_wrtcmp_lon_lwr_left" \
    "outvarname_wrtcmp_lat_lwr_left" \
    "outvarname_wrtcmp_lon_upr_rght" \
    "outvarname_wrtcmp_lat_upr_rght" \
    "outvarname_wrtcmp_dx" \
    "outvarname_wrtcmp_dy" \
    "outvarname_wrtcmp_dlon" \
    "outvarname_wrtcmp_dlat" \
    )
  process_args valid_args "$@"
#
#-----------------------------------------------------------------------
#
# Declare and initialize local variables.
#
#-----------------------------------------------------------------------
#
  local grid_gen_method="" \
        esggrid_lon_ctr="" \
        esggrid_lat_ctr="" \
        esggrid_delx="" \
        esggrid_dely="" \
        esggrid_nx="" \
        esggrid_ny="" \
        esggrid_pazi="" \
        esggrid_wide_halo_width="" \
        gfdlgrid_lon_t6_ctr="" \
        gfdlgrid_lat_t6_ctr="" \
        gfdlgrid_stretch_fac="" \
        gfdlgrid_res="" \
        gfdlgrid_refine_ratio="" \
        gfdlgrid_istart_of_rgnl_dom_on_t6g="" \
        gfdlgrid_iend_of_rgnl_dom_on_t6g="" \
        gfdlgrid_jstart_of_rgnl_dom_on_t6g="" \
        gfdlgrid_jend_of_rgnl_dom_on_t6g="" \
        gfdlgrid_use_gfdlgrid_res_in_filenames="" \
        dt_atmos="" \
        layout_x="" \
        layout_y="" \
        blocksize="" \
        wrtcmp_write_groups="" \
        wrtcmp_write_tasks_per_group="" \
        wrtcmp_output_grid="" \
        wrtcmp_cen_lon="" \
        wrtcmp_cen_lat="" \
        wrtcmp_stdlat1="" \
        wrtcmp_stdlat2="" \
        wrtcmp_nx="" \
        wrtcmp_ny="" \
        wrtcmp_lon_lwr_left="" \
        wrtcmp_lat_lwr_left="" \
        wrtcmp_lon_upr_rght="" \
        wrtcmp_lat_upr_rght="" \
        wrtcmp_dx="" \
        wrtcmp_dy="" \
        wrtcmp_dlon="" \
        wrtcmp_dlat="" \
        num_margin_cells_T6_left="" \
        num_margin_cells_T6_right="" \
        num_margin_cells_T6_bottom="" \
        num_margin_cells_T6_top=""
#
#-----------------------------------------------------------------------
#
# For debugging purposes, print out values of arguments passed to this
# script.  Note that these will be printed out only if VERBOSE is set to
# TRUE.
#
#-----------------------------------------------------------------------
#
#  print_input_args valid_args
#
#-----------------------------------------------------------------------
#
# Make sure that the input argument "quilting" is set to a valid value.
#
#-----------------------------------------------------------------------
#
  check_var_valid_value "quilting" "valid_vals_BOOLEAN"
  quilting=$(boolify $quilting)
#
#-----------------------------------------------------------------------
#
# Set grid and other parameters according to the value of the predefined
# domain (predef_grid_name).  Note that the code will enter this script
# only if predef_grid_name has a valid (and non-empty) value.
#
####################
# The following comments need to be updated:
####################
#
# 1) Reset the experiment title (expt_title).
# 2) Reset the grid parameters.
# 3) If the write component is to be used (i.e. "quilting" is set to
#    "TRUE") and the variable WRTCMP_PARAMS_TMPL_FN containing the name
#    of the write-component template file is unset or empty, set that
#    filename variable to the appropriate preexisting template file.
#
# For the predefined domains, we determine the starting and ending indi-
# ces of the regional grid within tile 6 by specifying margins (in units
# of number of cells on tile 6) between the boundary of tile 6 and that
# of the regional grid (tile 7) along the left, right, bottom, and top
# portions of these boundaries.  Note that we do not use "west", "east",
# "south", and "north" here because the tiles aren't necessarily orient-
# ed such that the left boundary segment corresponds to the west edge,
# etc.  The widths of these margins (in units of number of cells on tile
# 6) are specified via the parameters
#
#   num_margin_cells_T6_left
#   num_margin_cells_T6_right
#   num_margin_cells_T6_bottom
#   num_margin_cells_T6_top
#
# where the "_T6" in these names is used to indicate that the cell count
# is on tile 6, not tile 7.
#
# Note that we must make the margins wide enough (by making the above
# four parameters large enough) such that a region of halo cells around
# the boundary of the regional grid fits into the margins, i.e. such
# that the halo does not overrun the boundary of tile 6.  (The halo is
# added later in another script; its function is to feed in boundary
# conditions to the regional grid.)  Currently, a halo of 5 regional
# grid cells is used around the regional grid.  Setting num_margin_-
# cells_T6_... to at least 10 leaves enough room for this halo.
#
#-----------------------------------------------------------------------
#
  case "${predef_grid_name}" in
#
#-----------------------------------------------------------------------
#
# The RRFS CONUS domain with ~25km cells.
#
#-----------------------------------------------------------------------
#
  "RRFS_CONUS_25km")

    grid_gen_method="ESGgrid"

    esggrid_lon_ctr="-97.5"
    esggrid_lat_ctr="38.5"

    esggrid_delx="25000.0"
    esggrid_dely="25000.0"

    esggrid_nx="219"
    esggrid_ny="131"

    esggrid_pazi="0.0"

    esggrid_wide_halo_width="6"

    dt_atmos="${dt_atmos:-40}"

    layout_x="${layout_x:-5}"
    layout_y="${layout_y:-2}"
    blocksize="${blocksize:-40}"

    if [ "$quilting" = "TRUE" ]; then
      wrtcmp_write_groups="1"
      wrtcmp_write_tasks_per_group="2"
      wrtcmp_output_grid="lambert_conformal"
      wrtcmp_cen_lon="${esggrid_lon_ctr}"
      wrtcmp_cen_lat="${esggrid_lat_ctr}"
      wrtcmp_stdlat1="${esggrid_lat_ctr}"
      wrtcmp_stdlat2="${esggrid_lat_ctr}"
      wrtcmp_nx="217"
      wrtcmp_ny="128"
      wrtcmp_lon_lwr_left="-122.719528"
      wrtcmp_lat_lwr_left="21.138123"
      wrtcmp_dx="${esggrid_delx}"
      wrtcmp_dy="${esggrid_dely}"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# The RRFS CONUS domain with ~25km cells that can be initialized from
# the HRRR.
#
#-----------------------------------------------------------------------
#
  "RRFS_CONUScompact_25km")

    grid_gen_method="ESGgrid"

    esggrid_lon_ctr="-97.5"
    esggrid_lat_ctr="38.5"

    esggrid_delx="25000.0"
    esggrid_dely="25000.0"

    esggrid_nx="202"
    esggrid_ny="116"

    esggrid_pazi="0.0"

    esggrid_wide_halo_width="6"

    dt_atmos="${dt_atmos:-40}"

    layout_x="${layout_x:-5}"
    layout_y="${layout_y:-2}"
    blocksize="${blocksize:-40}"

    if [ "$quilting" = "TRUE" ]; then
      wrtcmp_write_groups="1"
      wrtcmp_write_tasks_per_group="2"
      wrtcmp_output_grid="lambert_conformal"
      wrtcmp_cen_lon="${esggrid_lon_ctr}"
      wrtcmp_cen_lat="${esggrid_lat_ctr}"
      wrtcmp_stdlat1="${esggrid_lat_ctr}"
      wrtcmp_stdlat2="${esggrid_lat_ctr}"
      wrtcmp_nx="199"
      wrtcmp_ny="111"
      wrtcmp_lon_lwr_left="-121.23349066"
      wrtcmp_lat_lwr_left="23.41731593"
      wrtcmp_dx="${esggrid_delx}"
      wrtcmp_dy="${esggrid_dely}"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# The RRFS CONUS domain with ~13km cells.
#
#-----------------------------------------------------------------------
#
  "RRFS_CONUS_13km")

    grid_gen_method="ESGgrid"

    esggrid_lon_ctr="-97.5"
    esggrid_lat_ctr="38.5"

    esggrid_delx="13000.0"
    esggrid_dely="13000.0"

    esggrid_nx="420"
    esggrid_ny="252"

    esggrid_pazi="0.0"

    esggrid_wide_halo_width="6"

    dt_atmos="${dt_atmos:-45}"

    layout_x="${layout_x:-16}"
    layout_y="${layout_y:-10}"
    blocksize="${blocksize:-32}"

    if [ "$quilting" = "TRUE" ]; then
      wrtcmp_write_groups="1"
      wrtcmp_write_tasks_per_group=$(( 1*layout_y ))
      wrtcmp_output_grid="lambert_conformal"
      wrtcmp_cen_lon="${esggrid_lon_ctr}"
      wrtcmp_cen_lat="${esggrid_lat_ctr}"
      wrtcmp_stdlat1="${esggrid_lat_ctr}"
      wrtcmp_stdlat2="${esggrid_lat_ctr}"
      wrtcmp_nx="416"
      wrtcmp_ny="245"
      wrtcmp_lon_lwr_left="-122.719528"
      wrtcmp_lat_lwr_left="21.138123"
      wrtcmp_dx="${esggrid_delx}"
      wrtcmp_dy="${esggrid_dely}"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# The RRFS CONUS domain with ~13km cells that can be initialized from the HRRR.
#
#-----------------------------------------------------------------------
#
  "RRFS_CONUScompact_13km")

    grid_gen_method="ESGgrid"

    esggrid_lon_ctr="-97.5"
    esggrid_lat_ctr="38.5"

    esggrid_delx="13000.0"
    esggrid_dely="13000.0"

    esggrid_nx="396"
    esggrid_ny="232"

    esggrid_pazi="0.0"

    esggrid_wide_halo_width="6"

    dt_atmos="${dt_atmos:-45}"

    layout_x="${layout_x:-16}"
    layout_y="${layout_y:-10}"
    blocksize="${blocksize:-32}"

    if [ "$quilting" = "TRUE" ]; then
      wrtcmp_write_groups="1"
      wrtcmp_write_tasks_per_group=$(( 1*layout_y ))
      wrtcmp_output_grid="lambert_conformal"
      wrtcmp_cen_lon="${esggrid_lon_ctr}"
      wrtcmp_cen_lat="${esggrid_lat_ctr}"
      wrtcmp_stdlat1="${esggrid_lat_ctr}"
      wrtcmp_stdlat2="${esggrid_lat_ctr}"
      wrtcmp_nx="393"
      wrtcmp_ny="225"
      wrtcmp_lon_lwr_left="-121.70231097"
      wrtcmp_lat_lwr_left="22.57417972"
      wrtcmp_dx="${esggrid_delx}"
      wrtcmp_dy="${esggrid_dely}"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# The RRFS CONUS domain with ~3km cells.
#
#-----------------------------------------------------------------------
#
  "RRFS_CONUS_3km")

    grid_gen_method="ESGgrid"

    esggrid_lon_ctr="-97.5"
    esggrid_lat_ctr="38.5"

    esggrid_delx="3000.0"
    esggrid_dely="3000.0"

    esggrid_nx="1820"
    esggrid_ny="1092"

    esggrid_pazi="0.0"

    esggrid_wide_halo_width="6"

    dt_atmos="${dt_atmos:-36}"

    layout_x="${layout_x:-28}"
    layout_y="${layout_y:-28}"
    blocksize="${blocksize:-29}"

    if [ "$quilting" = "TRUE" ]; then
      wrtcmp_write_groups="1"
      wrtcmp_write_tasks_per_group=$(( 1*layout_y ))
      wrtcmp_output_grid="lambert_conformal"
      wrtcmp_cen_lon="${esggrid_lon_ctr}"
      wrtcmp_cen_lat="${esggrid_lat_ctr}"
      wrtcmp_stdlat1="${esggrid_lat_ctr}"
      wrtcmp_stdlat2="${esggrid_lat_ctr}"
      wrtcmp_nx="1799"
      wrtcmp_ny="1059"
      wrtcmp_lon_lwr_left="-122.719528"
      wrtcmp_lat_lwr_left="21.138123"
      wrtcmp_dx="${esggrid_delx}"
      wrtcmp_dy="${esggrid_dely}"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# The RRFS CONUS domain with ~3km cells that can be initialized from
# the HRRR.
#
#-----------------------------------------------------------------------
#
  "RRFS_CONUScompact_3km")

    grid_gen_method="ESGgrid"

    esggrid_lon_ctr="-97.5"
    esggrid_lat_ctr="38.5"

    esggrid_delx="3000.0"
    esggrid_dely="3000.0"

    esggrid_nx="1748"
    esggrid_ny="1038"

    esggrid_pazi="0.0"

    esggrid_wide_halo_width="6"

    dt_atmos="${dt_atmos:-40}"

    layout_x="${layout_x:-30}"
    layout_y="${layout_y:-16}"
    blocksize="${blocksize:-32}"

    if [ "$quilting" = "TRUE" ]; then
      wrtcmp_write_groups="1"
      wrtcmp_write_tasks_per_group=$(( 1*layout_y ))
      wrtcmp_output_grid="lambert_conformal"
      wrtcmp_cen_lon="${esggrid_lon_ctr}"
      wrtcmp_cen_lat="${esggrid_lat_ctr}"
      wrtcmp_stdlat1="${esggrid_lat_ctr}"
      wrtcmp_stdlat2="${esggrid_lat_ctr}"
      wrtcmp_nx="1746"
      wrtcmp_ny="1014"
      wrtcmp_lon_lwr_left="-122.17364391"
      wrtcmp_lat_lwr_left="21.88588562"
      wrtcmp_dx="${esggrid_delx}"
      wrtcmp_dy="${esggrid_dely}"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# The RRFS SUBCONUS domain with ~3km cells.
#
#-----------------------------------------------------------------------
#
  "RRFS_SUBCONUS_3km")

    grid_gen_method="ESGgrid"

    esggrid_lon_ctr="-97.5"
    esggrid_lat_ctr="35.0"

    esggrid_delx="3000.0"
    esggrid_dely="3000.0"

    esggrid_nx="840"
    esggrid_ny="600"

    esggrid_pazi="0.0"

    esggrid_wide_halo_width="6"

    dt_atmos="${dt_atmos:-40}"

    layout_x="${layout_x:-30}"
    layout_y="${layout_y:-24}"
    blocksize="${blocksize:-35}"

    if [ "$quilting" = "TRUE" ]; then
      wrtcmp_write_groups="1"
      wrtcmp_write_tasks_per_group=$(( 1*layout_y ))
      wrtcmp_output_grid="lambert_conformal"
      wrtcmp_cen_lon="${esggrid_lon_ctr}"
      wrtcmp_cen_lat="${esggrid_lat_ctr}"
      wrtcmp_stdlat1="${esggrid_lat_ctr}"
      wrtcmp_stdlat2="${esggrid_lat_ctr}"
      wrtcmp_nx="837"
      wrtcmp_ny="595"
      wrtcmp_lon_lwr_left="-109.97410429"
      wrtcmp_lat_lwr_left="26.31459843"
      wrtcmp_dx="${esggrid_delx}"
      wrtcmp_dy="${esggrid_dely}"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# A subconus domain over Indianapolis, Indiana with ~3km cells.  This is
# mostly for testing on a 3km grid with a much small number of cells than
# on the full CONUS.
#
#-----------------------------------------------------------------------
#
  "SUBCONUS_Ind_3km")

    grid_gen_method="ESGgrid"

    esggrid_lon_ctr="-86.16"
    esggrid_lat_ctr="39.77"

    esggrid_delx="3000.0"
    esggrid_dely="3000.0"

    esggrid_nx="200"
    esggrid_ny="200"

    esggrid_pazi="0.0"

    esggrid_wide_halo_width="6"

    dt_atmos="${dt_atmos:-40}"

    layout_x="${layout_x:-5}"
    layout_y="${layout_y:-5}"
    blocksize="${blocksize:-40}"

    if [ "$quilting" = "TRUE" ]; then
      wrtcmp_write_groups="1"
      wrtcmp_write_tasks_per_group=$(( 1*layout_y ))
      wrtcmp_output_grid="lambert_conformal"
      wrtcmp_cen_lon="${esggrid_lon_ctr}"
      wrtcmp_cen_lat="${esggrid_lat_ctr}"
      wrtcmp_stdlat1="${esggrid_lat_ctr}"
      wrtcmp_stdlat2="${esggrid_lat_ctr}"
      wrtcmp_nx="197"
      wrtcmp_ny="195"
      wrtcmp_lon_lwr_left="-89.47120417"
      wrtcmp_lat_lwr_left="37.07809642"
      wrtcmp_dx="${esggrid_delx}"
      wrtcmp_dy="${esggrid_dely}"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# The RRFS Alaska domain with ~13km cells.
#
# Note:
# This grid has not been thoroughly tested (as of 20201027).
#
#-----------------------------------------------------------------------
#
  "RRFS_AK_13km")

    grid_gen_method="ESGgrid"

    esggrid_lon_ctr="-161.5"
    esggrid_lat_ctr="63.0"

    esggrid_delx="13000.0"
    esggrid_dely="13000.0"

    esggrid_nx="320"
    esggrid_ny="240"

    esggrid_pazi="0.0"

    esggrid_wide_halo_width="6"

#    dt_atmos="${dt_atmos:-50}"
    dt_atmos="${dt_atmos:-10}"

    layout_x="${layout_x:-16}"
    layout_y="${layout_y:-12}"
    blocksize="${blocksize:-40}"

    if [ "$quilting" = "TRUE" ]; then
      wrtcmp_write_groups="1"
      wrtcmp_write_tasks_per_group=$(( 1*layout_y ))
      wrtcmp_output_grid="lambert_conformal"
      wrtcmp_cen_lon="${esggrid_lon_ctr}"
      wrtcmp_cen_lat="${esggrid_lat_ctr}"
      wrtcmp_stdlat1="${esggrid_lat_ctr}"
      wrtcmp_stdlat2="${esggrid_lat_ctr}"

# The following works.  The numbers were obtained using the NCL scripts
# but only after manually modifying the longitutes of two of the four
# corners of the domain to add 360.0 to them.  Need to automate that
# procedure.
      wrtcmp_nx="318"
      wrtcmp_ny="234"
#      wrtcmp_lon_lwr_left="-187.76660836"
      wrtcmp_lon_lwr_left="172.23339164"
      wrtcmp_lat_lwr_left="45.77691870"

      wrtcmp_dx="${esggrid_delx}"
      wrtcmp_dy="${esggrid_dely}"
    fi

# The following rotated_latlon coordinate system parameters were obtained
# using the NCL code and work.
#      if [ "$quilting" = "TRUE" ]; then
#        wrtcmp_write_groups="1"
#        wrtcmp_write_tasks_per_group=$(( 1*layout_y ))
#        wrtcmp_output_grid="rotated_latlon"
#        wrtcmp_cen_lon="${esggrid_lon_ctr}"
#        wrtcmp_cen_lat="${esggrid_lat_ctr}"
#        wrtcmp_lon_lwr_left="-18.47206579"
#        wrtcmp_lat_lwr_left="-13.56176982"
#        wrtcmp_lon_upr_rght="18.47206579"
#        wrtcmp_lat_upr_rght="13.56176982"
##        wrtcmp_dlon="0.11691181"
##        wrtcmp_dlat="0.11691181"
#        wrtcmp_dlon=$( printf "%.9f" $( bc -l <<< "(${esggrid_delx}/${radius_Earth})*${degs_per_radian}" ) )
#        wrtcmp_dlat=$( printf "%.9f" $( bc -l <<< "(${esggrid_dely}/${radius_Earth})*${degs_per_radian}" ) )
#      fi
    ;;
#
#-----------------------------------------------------------------------
#
# The RRFS Alaska domain with ~3km cells.
#
# Note:
# This grid has not been thoroughly tested (as of 20201027).
#
#-----------------------------------------------------------------------
#
  "RRFS_AK_3km")

#    if [ "${grid_gen_method}" = "GFDLgrid" ]; then
#
#      gfdlgrid_lon_t6_ctr="-160.8"
#      gfdlgrid_lat_t6_ctr="63.0"
#      gfdlgrid_stretch_fac="1.161"
#      gfdlgrid_res="768"
#      gfdlgrid_refine_ratio="4"
#
#      num_margin_cells_T6_left="204"
#      gfdlgrid_istart_of_rgnl_dom_on_t6g=$(( num_margin_cells_T6_left + 1 ))
#
#      num_margin_cells_T6_right="204"
#      gfdlgrid_iend_of_rgnl_dom_on_t6g=$(( gfdlgrid_res - num_margin_cells_T6_right ))
#
#      num_margin_cells_T6_bottom="249"
#      gfdlgrid_jstart_of_rgnl_dom_on_t6g=$(( num_margin_cells_T6_bottom + 1 ))
#
#      num_margin_cells_T6_top="249"
#      gfdlgrid_jend_of_rgnl_dom_on_t6g=$(( gfdlgrid_res - num_margin_cells_T6_top ))
#
#      gfdlgrid_use_gfdlgrid_res_in_filenames="FALSE"
#
#      dt_atmos="${dt_atmos:-18}"
#
#      layout_x="${layout_x:-24}"
#      layout_y="${layout_y:-24}"
#      blocksize="${blocksize:-15}"
#
#      if [ "$quilting" = "TRUE" ]; then
#        wrtcmp_write_groups="1"
#        wrtcmp_write_tasks_per_group="2"
#        wrtcmp_output_grid="lambert_conformal"
#        wrtcmp_cen_lon="${gfdlgrid_lon_t6_ctr}"
#        wrtcmp_cen_lat="${gfdlgrid_lat_t6_ctr}"
#        wrtcmp_stdlat1="${gfdlgrid_lat_t6_ctr}"
#        wrtcmp_stdlat2="${gfdlgrid_lat_t6_ctr}"
#        wrtcmp_nx="1320"
#        wrtcmp_ny="950"
#        wrtcmp_lon_lwr_left="173.734"
#        wrtcmp_lat_lwr_left="46.740347"
#        wrtcmp_dx="3000.0"
#        wrtcmp_dy="3000.0"
#      fi
#
#    elif [ "${grid_gen_method}" = "ESGgrid" ]; then

    grid_gen_method="ESGgrid"

    esggrid_lon_ctr="-161.5"
    esggrid_lat_ctr="63.0"

    esggrid_delx="3000.0"
    esggrid_dely="3000.0"

    esggrid_nx="1380"
    esggrid_ny="1020"

    esggrid_pazi="0.0"

    esggrid_wide_halo_width="6"

#    dt_atmos="${dt_atmos:-50}"
    dt_atmos="${dt_atmos:-10}"

    layout_x="${layout_x:-30}"
    layout_y="${layout_y:-17}"
    blocksize="${blocksize:-40}"

    if [ "$quilting" = "TRUE" ]; then
      wrtcmp_write_groups="1"
      wrtcmp_write_tasks_per_group=$(( 1*layout_y ))
      wrtcmp_output_grid="lambert_conformal"
      wrtcmp_cen_lon="${esggrid_lon_ctr}"
      wrtcmp_cen_lat="${esggrid_lat_ctr}"
      wrtcmp_stdlat1="${esggrid_lat_ctr}"
      wrtcmp_stdlat2="${esggrid_lat_ctr}"
      wrtcmp_nx="1379"
      wrtcmp_ny="1003"
      wrtcmp_lon_lwr_left="-187.89737923"
      wrtcmp_lat_lwr_left="45.84576053"
      wrtcmp_dx="${esggrid_delx}"
      wrtcmp_dy="${esggrid_dely}"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# The WoFS domain with ~3km cells.
#
# Note:
# The WoFS domain will generate a 301 x 301 output grid (WRITE COMPONENT) and
# will eventually be movable (esggrid_lon_ctr/esggrid_lat_ctr). A python script
# python_utils/fv3write_parms_lambert will be useful to determine
# wrtcmp_lon_lwr_left and wrtcmp_lat_lwr_left locations (only for Lambert map
# projection currently) of the quilting output when the domain location is
# moved. Later, it should be integrated into the workflow.
#
#-----------------------------------------------------------------------
#
  "WoFS_3km")

    grid_gen_method="ESGgrid"

    esggrid_lon_ctr="-97.5"
    esggrid_lat_ctr="38.5"

    esggrid_delx="3000.0"
    esggrid_dely="3000.0"

    esggrid_nx="361"
    esggrid_ny="361"

    esggrid_pazi="0.0"

    esggrid_wide_halo_width="6"

    dt_atmos="${dt_atmos:-20}"

    layout_x="${layout_x:-18}"
    layout_y="${layout_y:-12}"
    blocksize="${blocksize:-30}"

    if [ "$quilting" = "TRUE" ]; then
      wrtcmp_write_groups="1"
      wrtcmp_write_tasks_per_group=$(( 1*layout_y ))
      wrtcmp_output_grid="lambert_conformal"
      wrtcmp_cen_lon="${esggrid_lon_ctr}"
      wrtcmp_cen_lat="${esggrid_lat_ctr}"
      wrtcmp_stdlat1="${esggrid_lat_ctr}"
      wrtcmp_stdlat2="${esggrid_lat_ctr}"
      wrtcmp_nx="301"
      wrtcmp_ny="301"
      wrtcmp_lon_lwr_left="-102.3802487"
      wrtcmp_lat_lwr_left="34.3407918"
      wrtcmp_dx="${esggrid_delx}"
      wrtcmp_dy="${esggrid_dely}"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# A CONUS domain of GFDLgrid type with ~25km cells.
#
# Note:
# This grid is larger than the HRRRX domain and thus cannot be initialized
# using the HRRRX.
#
#-----------------------------------------------------------------------
#
  "CONUS_25km_GFDLgrid")

    grid_gen_method="GFDLgrid"

    gfdlgrid_lon_t6_ctr="-97.5"
    gfdlgrid_lat_t6_ctr="38.5"
    gfdlgrid_stretch_fac="1.4"
    gfdlgrid_res="96"
    gfdlgrid_refine_ratio="3"

    num_margin_cells_T6_left="12"
    gfdlgrid_istart_of_rgnl_dom_on_t6g=$(( num_margin_cells_T6_left + 1 ))

    num_margin_cells_T6_right="12"
    gfdlgrid_iend_of_rgnl_dom_on_t6g=$(( gfdlgrid_res - num_margin_cells_T6_right ))

    num_margin_cells_T6_bottom="16"
    gfdlgrid_jstart_of_rgnl_dom_on_t6g=$(( num_margin_cells_T6_bottom + 1 ))

    num_margin_cells_T6_top="16"
    gfdlgrid_jend_of_rgnl_dom_on_t6g=$(( gfdlgrid_res - num_margin_cells_T6_top ))

    gfdlgrid_use_gfdlgrid_res_in_filenames="TRUE"

    dt_atmos="${dt_atmos:-225}"

    layout_x="${layout_x:-6}"
    layout_y="${layout_y:-4}"
    blocksize="${blocksize:-36}"

    if [ "$quilting" = "TRUE" ]; then
      wrtcmp_write_groups="1"
      wrtcmp_write_tasks_per_group=$(( 1*layout_y ))
      wrtcmp_output_grid="rotated_latlon"
      wrtcmp_cen_lon="${gfdlgrid_lon_t6_ctr}"
      wrtcmp_cen_lat="${gfdlgrid_lat_t6_ctr}"
      wrtcmp_lon_lwr_left="-24.40085141"
      wrtcmp_lat_lwr_left="-19.65624142"
      wrtcmp_lon_upr_rght="24.40085141"
      wrtcmp_lat_upr_rght="19.65624142"
      wrtcmp_dlon="0.22593381"
      wrtcmp_dlat="0.22593381"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# A CONUS domain of GFDLgrid type with ~3km cells.
#
# Note:
# This grid is larger than the HRRRX domain and thus cannot be initialized
# using the HRRRX.
#
#-----------------------------------------------------------------------
#
  "CONUS_3km_GFDLgrid")

    grid_gen_method="GFDLgrid"

    gfdlgrid_lon_t6_ctr="-97.5"
    gfdlgrid_lat_t6_ctr="38.5"
    gfdlgrid_stretch_fac="1.5"
    gfdlgrid_res="768"
    gfdlgrid_refine_ratio="3"

    num_margin_cells_T6_left="69"
    gfdlgrid_istart_of_rgnl_dom_on_t6g=$(( num_margin_cells_T6_left + 1 ))

    num_margin_cells_T6_right="69"
    gfdlgrid_iend_of_rgnl_dom_on_t6g=$(( gfdlgrid_res - num_margin_cells_T6_right ))

    num_margin_cells_T6_bottom="164"
    gfdlgrid_jstart_of_rgnl_dom_on_t6g=$(( num_margin_cells_T6_bottom + 1 ))

    num_margin_cells_T6_top="164"
    gfdlgrid_jend_of_rgnl_dom_on_t6g=$(( gfdlgrid_res - num_margin_cells_T6_top ))

    gfdlgrid_use_gfdlgrid_res_in_filenames="TRUE"

    dt_atmos="${dt_atmos:-18}"

    layout_x="${layout_x:-30}"
    layout_y="${layout_y:-22}"
    blocksize="${blocksize:-35}"

    if [ "$quilting" = "TRUE" ]; then
      wrtcmp_write_groups="1"
      wrtcmp_write_tasks_per_group=$(( 1*layout_y ))
      wrtcmp_output_grid="rotated_latlon"
      wrtcmp_cen_lon="${gfdlgrid_lon_t6_ctr}"
      wrtcmp_cen_lat="${gfdlgrid_lat_t6_ctr}"
      wrtcmp_lon_lwr_left="-25.23144805"
      wrtcmp_lat_lwr_left="-15.82130419"
      wrtcmp_lon_upr_rght="25.23144805"
      wrtcmp_lat_upr_rght="15.82130419"
      wrtcmp_dlon="0.02665763"
      wrtcmp_dlat="0.02665763"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# EMC's Alaska grid.
#
#-----------------------------------------------------------------------
#
  "EMC_AK")

#    if [ "${grid_gen_method}" = "GFDLgrid" ]; then

# Values from an EMC script.

### rocoto items
#
#fcstnodes=68
#bcnodes=11
#postnodes=2
#goespostnodes=5
#goespostthrottle=6
#sh=06
#eh=18
#
### namelist items
#
#task_layout_x=16
#task_layout_y=48
#npx=1345
#npy=1153
#target_lat=61.0
#target_lon=-153.0
#
### model config items
#
#write_groups=2
#write_tasks_per_group=24
#cen_lon=$target_lon
#cen_lat=$target_lat
#lon1=-18.0
#lat1=-14.79
#lon2=18.0
#lat2=14.79
#dlon=0.03
#dlat=0.03

#      gfdlgrid_lon_t6_ctr="-153.0"
#      gfdlgrid_lat_t6_ctr="61.0"
#      gfdlgrid_stretch_fac="1.0"  # ???
#      gfdlgrid_res="768"
#      gfdlgrid_refine_ratio="3"   # ???
#
#      num_margin_cells_T6_left="61"
#      gfdlgrid_istart_of_rgnl_dom_on_t6g=$(( num_margin_cells_T6_left + 1 ))
#
#      num_margin_cells_T6_right="67"
#      gfdlgrid_iend_of_rgnl_dom_on_t6g=$(( gfdlgrid_res - num_margin_cells_T6_right ))
#
#      num_margin_cells_T6_bottom="165"
#      gfdlgrid_jstart_of_rgnl_dom_on_t6g=$(( num_margin_cells_T6_bottom + 1 ))
#
#      num_margin_cells_T6_top="171"
#      gfdlgrid_jend_of_rgnl_dom_on_t6g=$(( gfdlgrid_res - num_margin_cells_T6_top ))
#
#      gfdlgrid_use_gfdlgrid_res_in_filenames="TRUE"
#
#      dt_atmos="${dt_atmos:-18}"
#
#      layout_x="${layout_x:-16}"
#      layout_y="${layout_y:-48}"
#      wrtcmp_write_groups="2"
#      wrtcmp_write_tasks_per_group="24"
#      blocksize="${blocksize:-32}"
#
#    elif [ "${grid_gen_method}" = "ESGgrid" ]; then

    grid_gen_method="ESGgrid"

# Values taken from pre-generated files in /scratch4/NCEPDEV/fv3-cam/save/Benjamin.Blake/regional_workflow/fix/fix_sar
# With move to Hera, those files were lost; a backup can be found here: /scratch2/BMC/det/kavulich/fix/fix_sar

# Longitude and latitude for center of domain
    esggrid_lon_ctr="-153.0"
    esggrid_lat_ctr="61.0"

# Projected grid spacing in meters...in the static files (e.g. "C768_grid.tile7.nc"), the "dx" is actually the resolution
# of the supergrid, which is HALF of this dx
    esggrid_delx="3000.0"
    esggrid_dely="3000.0"

# Number of x and y points for your domain (halo not included);
# Divide "supergrid" values from /scratch2/BMC/det/kavulich/fix/fix_sar/ak/C768_grid.tile7.halo4.nc by 2 and subtract 8 to eliminate halo
    esggrid_nx="1344" # Supergrid value 2704
    esggrid_ny="1152" # Supergrid value 2320

# Rotation of the ESG grid in degrees.
    esggrid_pazi="0.0"

# Number of halo points for a wide grid (before trimming)...this should almost always be 6 for now
# Within the model we actually have a 4-point halo and a 3-point halo
    esggrid_wide_halo_width="6"

# Side note: FV3 is lagrangian and vertical coordinates are dynamically remapped during model integration
# 'ksplit' is the factor that determines the timestep for this process (divided

# Physics timestep in seconds, actual dynamics timestep can be a subset of this.
# This is the time step for the largest atmosphere model loop.  It corresponds to the frequency with which the
# top-level routine in the dynamics is called as well as the frequency with which the physics is called.
#
# Preliminary standard values: 18 for 3-km runs, 90 for 13-km runs per config_defaults.sh

    dt_atmos="${dt_atmos:-18}"

#Factors for MPI decomposition. esggrid_nx must be divisible by layout_x, esggrid_ny must be divisible by layout_y
    layout_x="${layout_x:-28}"
    layout_y="${layout_y:-16}"

#Take number of points on a tile (nx/lx*ny/ly), must divide by block size to get an integer.
#This integer must be small enough to fit into a processor's cache, so it is machine-dependent magic
# For Theia, must be ~40 or less
# Check setup.sh for more details
    blocksize="${blocksize:-24}"

#This section is all for the write component, which you need for output during model integration
    if [ "$quilting" = "TRUE" ]; then
#Write component reserves MPI tasks for writing output. The number of "groups" is usually 1, but if you have a case where group 1 is not done writing before the next write step, you need group 2, etc.
      wrtcmp_write_groups="1"
#Number of tasks per write group. Ny must be divisible my this number. layout_y is usually a good value
      wrtcmp_write_tasks_per_group="24"
#lambert_conformal or rotated_latlon. lambert_conformal not well tested and probably doesn't work for our purposes
      wrtcmp_output_grid="lambert_conformal"
#These should always be set the same as compute grid
      wrtcmp_cen_lon="${esggrid_lon_ctr}"
      wrtcmp_cen_lat="${esggrid_lat_ctr}"
      wrtcmp_stdlat1="${esggrid_lat_ctr}"
      wrtcmp_stdlat2="${esggrid_lat_ctr}"
#Write component grid must always be <= compute grid (without haloes)
      wrtcmp_nx="1344"
      wrtcmp_ny="1152"
#Lower left latlon (southwest corner)
      wrtcmp_lon_lwr_left="-177.0"
      wrtcmp_lat_lwr_left="42.5"
      wrtcmp_dx="${esggrid_delx}"
      wrtcmp_dy="${esggrid_dely}"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# EMC's Hawaii grid.
#
#-----------------------------------------------------------------------
#
  "EMC_HI")

    grid_gen_method="ESGgrid"

# Values taken from pre-generated files in /scratch4/NCEPDEV/fv3-cam/save/Benjamin.Blake/regional_workflow/fix/fix_sar/hi/C768_grid.tile7.nc
# With move to Hera, those files were lost; a backup can be found here: /scratch2/BMC/det/kavulich/fix/fix_sar
# Longitude and latitude for center of domain
    esggrid_lon_ctr="-157.0"
    esggrid_lat_ctr="20.0"

# Projected grid spacing in meters...in the static files (e.g. "C768_grid.tile7.nc"), the "dx" is actually the resolution
# of the supergrid, which is HALF of this dx (plus or minus some grid stretch factor)
    esggrid_delx="3000.0"
    esggrid_dely="3000.0"

# Number of x and y points for your domain (halo not included);
# Divide "supergrid" values from /scratch2/BMC/det/kavulich/fix/fix_sar/hi/C768_grid.tile7.halo4.nc by 2 and subtract 8 to eliminate halo
    esggrid_nx="432" # Supergrid value 880
    esggrid_ny="360" # Supergrid value 736

# Rotation of the ESG grid in degrees.
    esggrid_pazi="0.0"

# Number of halo points for a wide grid (before trimming)...this should almost always be 6 for now
# Within the model we actually have a 4-point halo and a 3-point halo
    esggrid_wide_halo_width="6"

# Side note: FV3 is lagrangian and vertical coordinates are dynamically remapped during model integration
# 'ksplit' is the factor that determines the timestep for this process (divided

# Physics timestep in seconds, actual dynamics timestep can be a subset of this.
# This is the time step for the largest atmosphere model loop.  It corresponds to the frequency with which the
# top-level routine in the dynamics is called as well as the frequency with which the physics is called.
#
# Preliminary standard values: 18 for 3-km runs, 90 for 13-km runs per config_defaults.sh

    dt_atmos="${dt_atmos:-18}"

#Factors for MPI decomposition. esggrid_nx must be divisible by layout_x, esggrid_ny must be divisible by layout_y
    layout_x="${layout_x:-8}"
    layout_y="${layout_y:-8}"
#Take number of points on a tile (nx/lx*ny/ly), must divide by block size to get an integer.
#This integer must be small enough to fit into a processor's cache, so it is machine-dependent magic
# For Theia, must be ~40 or less
# Check setup.sh for more details
    blocksize="${blocksize:-27}"

#This section is all for the write component, which you need for output during model integration
    if [ "$quilting" = "TRUE" ]; then
#Write component reserves MPI tasks for writing output. The number of "groups" is usually 1, but if you have a case where group 1 is not done writing before the next write step, you need group 2, etc.
      wrtcmp_write_groups="1"
#Number of tasks per write group. Ny must be divisible my this number. layout_y is usually a good value
      wrtcmp_write_tasks_per_group="8"
#lambert_conformal or rotated_latlon. lambert_conformal not well tested and probably doesn't work for our purposes
      wrtcmp_output_grid="lambert_conformal"
#These should usually be set the same as compute grid
      wrtcmp_cen_lon="${esggrid_lon_ctr}"
      wrtcmp_cen_lat="${esggrid_lat_ctr}"
      wrtcmp_stdlat1="${esggrid_lat_ctr}"
      wrtcmp_stdlat2="${esggrid_lat_ctr}"
#Write component grid should be close to the ESGgrid values unless you are doing something weird
      wrtcmp_nx="420"
      wrtcmp_ny="348"

#Lower left latlon (southwest corner)
      wrtcmp_lon_lwr_left="-162.8"
      wrtcmp_lat_lwr_left="15.2"
      wrtcmp_dx="${esggrid_delx}"
      wrtcmp_dy="${esggrid_dely}"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# EMC's Puerto Rico grid.
#
#-----------------------------------------------------------------------
#
  "EMC_PR")

    grid_gen_method="ESGgrid"

# Values taken from pre-generated files in /scratch4/NCEPDEV/fv3-cam/save/Benjamin.Blake/regional_workflow/fix/fix_sar/pr/C768_grid.tile7.nc
# With move to Hera, those files were lost; a backup can be found here: /scratch2/BMC/det/kavulich/fix/fix_sar
# Longitude and latitude for center of domain
    esggrid_lon_ctr="-69.0"
    esggrid_lat_ctr="18.0"

# Projected grid spacing in meters...in the static files (e.g. "C768_grid.tile7.nc"), the "dx" is actually the resolution
# of the supergrid, which is HALF of this dx (plus or minus some grid stretch factor)
    esggrid_delx="3000.0"
    esggrid_dely="3000.0"

# Number of x and y points for your domain (halo not included);
# Divide "supergrid" values from /scratch2/BMC/det/kavulich/fix/fix_sar/pr/C768_grid.tile7.halo4.nc by 2 and subtract 8 to eliminate halo
    esggrid_nx="576" # Supergrid value 1168
    esggrid_ny="432" # Supergrid value 880

# Rotation of the ESG grid in degrees.
    esggrid_pazi="0.0"

# Number of halo points for a wide grid (before trimming)...this should almost always be 6 for now
# Within the model we actually have a 4-point halo and a 3-point halo
    esggrid_wide_halo_width="6"

# Side note: FV3 is lagrangian and vertical coordinates are dynamically remapped during model integration
# 'ksplit' is the factor that determines the timestep for this process (divided

# Physics timestep in seconds, actual dynamics timestep can be a subset of this.
# This is the time step for the largest atmosphere model loop.  It corresponds to the frequency with which the
# top-level routine in the dynamics is called as well as the frequency with which the physics is called.
#
# Preliminary standard values: 18 for 3-km runs, 90 for 13-km runs per config_defaults.sh

    dt_atmos="${dt_atmos:-18}"

#Factors for MPI decomposition. esggrid_nx must be divisible by layout_x, esggrid_ny must be divisible by layout_y
    layout_x="${layout_x:-16}"
    layout_y="${layout_y:-8}"

#Take number of points on a tile (nx/lx*ny/ly), must divide by block size to get an integer.
#This integer must be small enough to fit into a processor's cache, so it is machine-dependent magic
# For Theia, must be ~40 or less
# Check setup.sh for more details
    blocksize="${blocksize:-24}"

#This section is all for the write component, which you need for output during model integration
    if [ "$quilting" = "TRUE" ]; then
#Write component reserves MPI tasks for writing output. The number of "groups" is usually 1, but if you have a case where group 1 is not done writing before the next write step, you need group 2, etc.
      wrtcmp_write_groups="1"
#Number of tasks per write group. Ny must be divisible my this number. layout_y is usually a good value
      wrtcmp_write_tasks_per_group="24"
#lambert_conformal or rotated_latlon. lambert_conformal not well tested and probably doesn't work for our purposes
      wrtcmp_output_grid="lambert_conformal"
#These should always be set the same as compute grid
      wrtcmp_cen_lon="${esggrid_lon_ctr}"
      wrtcmp_cen_lat="${esggrid_lat_ctr}"
      wrtcmp_stdlat1="${esggrid_lat_ctr}"
      wrtcmp_stdlat2="${esggrid_lat_ctr}"
#Write component grid must always be <= compute grid (without haloes)
      wrtcmp_nx="576"
      wrtcmp_ny="432"
#Lower left latlon (southwest corner)
      wrtcmp_lon_lwr_left="-77"
      wrtcmp_lat_lwr_left="12"
      wrtcmp_dx="${esggrid_delx}"
      wrtcmp_dy="${esggrid_dely}"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# EMC's Guam grid.
#
#-----------------------------------------------------------------------
#
  "EMC_GU")

    grid_gen_method="ESGgrid"

# Values taken from pre-generated files in /scratch4/NCEPDEV/fv3-cam/save/Benjamin.Blake/regional_workflow/fix/fix_sar/guam/C768_grid.tile7.nc
# With move to Hera, those files were lost; a backup can be found here: /scratch2/BMC/det/kavulich/fix/fix_sar
# Longitude and latitude for center of domain
    esggrid_lon_ctr="146.0"
    esggrid_lat_ctr="15.0"

# Projected grid spacing in meters...in the static files (e.g. "C768_grid.tile7.nc"), the "dx" is actually the resolution
# of the supergrid, which is HALF of this dx (plus or minus some grid stretch factor)
    esggrid_delx="3000.0"
    esggrid_dely="3000.0"

# Number of x and y points for your domain (halo not included);
# Divide "supergrid" values from /scratch2/BMC/det/kavulich/fix/fix_sar/guam/C768_grid.tile7.halo4.nc by 2 and subtract 8 to eliminate halo
    esggrid_nx="432" # Supergrid value 880
    esggrid_ny="360" # Supergrid value 736

# Rotation of the ESG grid in degrees.
    esggrid_pazi="0.0"

# Number of halo points for a wide grid (before trimming)...this should almost always be 6 for now
# Within the model we actually have a 4-point halo and a 3-point halo
    esggrid_wide_halo_width="6"

# Side note: FV3 is lagrangian and vertical coordinates are dynamically remapped during model integration
# 'ksplit' is the factor that determines the timestep for this process (divided

# Physics timestep in seconds, actual dynamics timestep can be a subset of this.
# This is the time step for the largest atmosphere model loop.  It corresponds to the frequency with which the
# top-level routine in the dynamics is called as well as the frequency with which the physics is called.
#
# Preliminary standard values: 18 for 3-km runs, 90 for 13-km runs per config_defaults.sh

    dt_atmos="${dt_atmos:-18}"

#Factors for MPI decomposition. esggrid_nx must be divisible by layout_x, esggrid_ny must be divisible by layout_y
    layout_x="${layout_x:-16}"
    layout_y="${layout_y:-12}"
#Take number of points on a tile (nx/lx*ny/ly), must divide by block size to get an integer.
#This integer must be small enough to fit into a processor's cache, so it is machine-dependent magic
# For Theia, must be ~40 or less
# Check setup.sh for more details
    blocksize="${blocksize:-27}"

#This section is all for the write component, which you need for output during model integration
    if [ "$quilting" = "TRUE" ]; then
#Write component reserves MPI tasks for writing output. The number of "groups" is usually 1, but if you have a case where group 1 is not done writing before the next write step, you need group 2, etc.
      wrtcmp_write_groups="1"
#Number of tasks per write group. Ny must be divisible my this number. layout_y is usually a good value
      wrtcmp_write_tasks_per_group="24"
#lambert_conformal or rotated_latlon. lambert_conformal not well tested and probably doesn't work for our purposes
      wrtcmp_output_grid="lambert_conformal"
#These should always be set the same as compute grid
      wrtcmp_cen_lon="${esggrid_lon_ctr}"
      wrtcmp_cen_lat="${esggrid_lat_ctr}"
      wrtcmp_stdlat1="${esggrid_lat_ctr}"
      wrtcmp_stdlat2="${esggrid_lat_ctr}"
#Write component grid must always be <= compute grid (without haloes)
      wrtcmp_nx="420"
      wrtcmp_ny="348"
#Lower left latlon (southwest corner) Used /scratch2/NCEPDEV/fv3-cam/Dusan.Jovic/dbrowse/fv3grid utility to find best value
      wrtcmp_lon_lwr_left="140"
      wrtcmp_lat_lwr_left="10"
      wrtcmp_dx="${esggrid_delx}"
      wrtcmp_dy="${esggrid_dely}"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# Emulation of the HAFS v0.A grid at 25 km.
#
#-----------------------------------------------------------------------
#
  "GSL_HAFSV0.A_25km")

    grid_gen_method="ESGgrid"

    esggrid_lon_ctr="-62.0"
    esggrid_lat_ctr="22.0"

    esggrid_delx="25000.0"
    esggrid_dely="25000.0"

    esggrid_nx="345"
    esggrid_ny="230"

    esggrid_pazi="0.0"

    esggrid_wide_halo_width="6"

    dt_atmos="${dt_atmos:-300}"

    layout_x="${layout_x:-5}"
    layout_y="${layout_y:-5}"
    blocksize="${blocksize:-6}"

    if [ "$quilting" = "TRUE" ]; then
      wrtcmp_write_groups="1"
      wrtcmp_write_tasks_per_group="32"
      wrtcmp_output_grid="regional_latlon"
      wrtcmp_cen_lon="${esggrid_lon_ctr}"
      wrtcmp_cen_lat="25.0"
      wrtcmp_lon_lwr_left="-114.5"
      wrtcmp_lat_lwr_left="-5.0"
      wrtcmp_lon_upr_rght="-9.5"
      wrtcmp_lat_upr_rght="55.0"
      wrtcmp_dlon="0.25"
      wrtcmp_dlat="0.25"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# Emulation of the HAFS v0.A grid at 13 km.
#
#-----------------------------------------------------------------------
#
  "GSL_HAFSV0.A_13km")

    grid_gen_method="ESGgrid"

    esggrid_lon_ctr="-62.0"
    esggrid_lat_ctr="22.0"

    esggrid_delx="13000.0"
    esggrid_dely="13000.0"

    esggrid_nx="665"
    esggrid_ny="444"

    esggrid_pazi="0.0"

    esggrid_wide_halo_width="6"

    dt_atmos="${dt_atmos:-180}"

    layout_x="${layout_x:-19}"
    layout_y="${layout_y:-12}"
    blocksize="${blocksize:-35}"

    if [ "$quilting" = "TRUE" ]; then
      wrtcmp_write_groups="1"
      wrtcmp_write_tasks_per_group="32"
      wrtcmp_output_grid="regional_latlon"
      wrtcmp_cen_lon="${esggrid_lon_ctr}"
      wrtcmp_cen_lat="25.0"
      wrtcmp_lon_lwr_left="-114.5"
      wrtcmp_lat_lwr_left="-5.0"
      wrtcmp_lon_upr_rght="-9.5"
      wrtcmp_lat_upr_rght="55.0"
      wrtcmp_dlon="0.13"
      wrtcmp_dlat="0.13"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# Emulation of the HAFS v0.A grid at 3 km.
#
#-----------------------------------------------------------------------
#
  "GSL_HAFSV0.A_3km")

    grid_gen_method="ESGgrid"

    esggrid_lon_ctr="-62.0"
    esggrid_lat_ctr="22.0"

    esggrid_delx="3000.0"
    esggrid_dely="3000.0"

    esggrid_nx="2880"
    esggrid_ny="1920"

    esggrid_pazi="0.0"

    esggrid_wide_halo_width="6"

    dt_atmos="${dt_atmos:-40}"

    layout_x="${layout_x:-32}"
    layout_y="${layout_y:-24}"
    blocksize="${blocksize:-32}"

    if [ "$quilting" = "TRUE" ]; then
      wrtcmp_write_groups="1"
      wrtcmp_write_tasks_per_group="32"
      wrtcmp_output_grid="regional_latlon"
      wrtcmp_cen_lon="${esggrid_lon_ctr}"
      wrtcmp_cen_lat="25.0"
      wrtcmp_lon_lwr_left="-114.5"
      wrtcmp_lat_lwr_left="-5.0"
      wrtcmp_lon_upr_rght="-9.5"
      wrtcmp_lat_upr_rght="55.0"
      wrtcmp_dlon="0.03"
      wrtcmp_dlat="0.03"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# 50-km HRRR Alaska grid.
#
#-----------------------------------------------------------------------
#
  "GSD_HRRR_AK_50km")

    grid_gen_method="ESGgrid"

    esggrid_lon_ctr="-163.5"
    esggrid_lat_ctr="62.8"

    esggrid_delx="50000.0"
    esggrid_dely="50000.0"

    esggrid_nx="74"
    esggrid_ny="51"

    esggrid_pazi="0.0"

    esggrid_wide_halo_width="6"

    dt_atmos="${dt_atmos:-600}"

    layout_x="${layout_x:-2}"
    layout_y="${layout_y:-3}"
    blocksize="${blocksize:-37}"

    if [ "$quilting" = "TRUE" ]; then
      wrtcmp_write_groups="1"
      wrtcmp_write_tasks_per_group="1"
      wrtcmp_output_grid="lambert_conformal"
      wrtcmp_cen_lon="${esggrid_lon_ctr}"
      wrtcmp_cen_lat="${esggrid_lat_ctr}"
      wrtcmp_stdlat1="${esggrid_lat_ctr}"
      wrtcmp_stdlat2="${esggrid_lat_ctr}"
      wrtcmp_nx="70"
      wrtcmp_ny="45"
      wrtcmp_lon_lwr_left="172.0"
      wrtcmp_lat_lwr_left="49.0"
      wrtcmp_dx="${esggrid_delx}"
      wrtcmp_dy="${esggrid_dely}"
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# Emulation of GSD's RAP domain with ~13km cell size.
#
#-----------------------------------------------------------------------
#
  "RRFS_NA_13km")

    grid_gen_method="ESGgrid"

    esggrid_lon_ctr="-112.5"
    esggrid_lat_ctr="55.0"

    esggrid_delx="13000.0"
    esggrid_dely="13000.0"

    esggrid_nx="912"
    esggrid_ny="623"

    esggrid_pazi="0.0"

    esggrid_wide_halo_width="6"

    dt_atmos="${dt_atmos:-50}"

    layout_x="${layout_x:-16}"
    layout_y="${layout_y:-16}"
    blocksize="${blocksize:-30}"

    if [ "$quilting" = "TRUE" ]; then
      wrtcmp_write_groups="1"
      wrtcmp_write_tasks_per_group="16"
      wrtcmp_output_grid="rotated_latlon"
      wrtcmp_cen_lon="-113.0" #"${esggrid_lon_ctr}"
      wrtcmp_cen_lat="55.0" #"${esggrid_lat_ctr}"
      wrtcmp_lon_lwr_left="-61.0"
      wrtcmp_lat_lwr_left="-37.0"
      wrtcmp_lon_upr_rght="61.0"
      wrtcmp_lat_upr_rght="37.0"
      wrtcmp_dlon=$( printf "%.9f" $( bc -l <<< "(${esggrid_delx}/${radius_Earth})*${degs_per_radian}" ) )
      wrtcmp_dlat=$( printf "%.9f" $( bc -l <<< "(${esggrid_dely}/${radius_Earth})*${degs_per_radian}" ) )
    fi
    ;;
#
#-----------------------------------------------------------------------
#
# Future operational RRFS domain with ~3km cell size.
#
#-----------------------------------------------------------------------
#
  "RRFS_NA_3km")

    grid_gen_method="ESGgrid"

    esggrid_lon_ctr=-112.5
    esggrid_lat_ctr=55.0

    esggrid_delx="3000.0"
    esggrid_dely="3000.0"

    esggrid_nx="3950"
    esggrid_ny="2700"

    esggrid_pazi="0.0"

    esggrid_wide_halo_width="6"

    dt_atmos="${dt_atmos:-36}"

    layout_x="${layout_x:-20}"   # 40 - EMC operational configuration
    layout_y="${layout_y:-35}"   # 45 - EMC operational configuration
    blocksize="${blocksize:-28}"

    if [ "$quilting" = "TRUE" ]; then
      wrtcmp_write_groups="1"
      wrtcmp_write_tasks_per_group="144"
      wrtcmp_output_grid="rotated_latlon"
      wrtcmp_cen_lon="-113.0" #"${esggrid_lon_ctr}"
      wrtcmp_cen_lat="55.0" #"${esggrid_lat_ctr}"
      wrtcmp_lon_lwr_left="-61.0"
      wrtcmp_lat_lwr_left="-37.0"
      wrtcmp_lon_upr_rght="61.0"
      wrtcmp_lat_upr_rght="37.0"
      wrtcmp_dlon="0.025" #$( printf "%.9f" $( bc -l <<< "(${esggrid_delx}/${radius_Earth})*${degs_per_radian}" ) )
      wrtcmp_dlat="0.025" #$( printf "%.9f" $( bc -l <<< "(${esggrid_dely}/${radius_Earth})*${degs_per_radian}" ) )
    fi
    ;;

  esac
#
#-----------------------------------------------------------------------
#
# Use the printf utility with the -v flag to set this function's output
# variables.  Note that each of these is set only if the corresponding
# input variable specifying the name to use for the output variable is
# not empty.
#
#-----------------------------------------------------------------------
#
  if [ ! -z "${outvarname_grid_gen_method}" ]; then
    printf -v ${outvarname_grid_gen_method} "%s" "${grid_gen_method}"
  fi

  if [ ! -z "${outvarname_esggrid_lon_ctr}" ]; then
    printf -v ${outvarname_esggrid_lon_ctr} "%s" "${esggrid_lon_ctr}"
  fi

  if [ ! -z "${outvarname_esggrid_lat_ctr}" ]; then
    printf -v ${outvarname_esggrid_lat_ctr} "%s" "${esggrid_lat_ctr}"
  fi

  if [ ! -z "${outvarname_esggrid_delx}" ]; then
    printf -v ${outvarname_esggrid_delx} "%s" "${esggrid_delx}"
  fi

  if [ ! -z "${outvarname_esggrid_dely}" ]; then
    printf -v ${outvarname_esggrid_dely} "%s" "${esggrid_dely}"
  fi

  if [ ! -z "${outvarname_esggrid_nx}" ]; then
    printf -v ${outvarname_esggrid_nx} "%s" "${esggrid_nx}"
  fi

  if [ ! -z "${outvarname_esggrid_ny}" ]; then
    printf -v ${outvarname_esggrid_ny} "%s" "${esggrid_ny}"
  fi

  if [ ! -z "${outvarname_esggrid_pazi}" ]; then
    printf -v ${outvarname_esggrid_pazi} "%s" "${esggrid_pazi}"
  fi

  if [ ! -z "${outvarname_esggrid_wide_halo_width}" ]; then
    printf -v ${outvarname_esggrid_wide_halo_width} "%s" "${esggrid_wide_halo_width}"
  fi

  if [ ! -z "${outvarname_gfdlgrid_lon_t6_ctr}" ]; then
    printf -v ${outvarname_gfdlgrid_lon_t6_ctr} "%s" "${gfdlgrid_lon_t6_ctr}"
  fi

  if [ ! -z "${outvarname_gfdlgrid_lat_t6_ctr}" ]; then
    printf -v ${outvarname_gfdlgrid_lat_t6_ctr} "%s" "${gfdlgrid_lat_t6_ctr}"
  fi

  if [ ! -z "${outvarname_gfdlgrid_stretch_fac}" ]; then
    printf -v ${outvarname_gfdlgrid_stretch_fac} "%s" "${gfdlgrid_stretch_fac}"
  fi

  if [ ! -z "${outvarname_gfdlgrid_res}" ]; then
    printf -v ${outvarname_gfdlgrid_res} "%s" "${gfdlgrid_res}"
  fi

  if [ ! -z "${outvarname_gfdlgrid_refine_ratio}" ]; then
    printf -v ${outvarname_gfdlgrid_refine_ratio} "%s" "${gfdlgrid_refine_ratio}"
  fi

  if [ ! -z "${outvarname_gfdlgrid_istart_of_rgnl_dom_on_t6g}" ]; then
    printf -v ${outvarname_gfdlgrid_istart_of_rgnl_dom_on_t6g} "%s" "${gfdlgrid_istart_of_rgnl_dom_on_t6g}"
  fi

  if [ ! -z "${outvarname_gfdlgrid_iend_of_rgnl_dom_on_t6g}" ]; then
    printf -v ${outvarname_gfdlgrid_iend_of_rgnl_dom_on_t6g} "%s" "${gfdlgrid_iend_of_rgnl_dom_on_t6g}"
  fi

  if [ ! -z "${outvarname_gfdlgrid_jstart_of_rgnl_dom_on_t6g}" ]; then
    printf -v ${outvarname_gfdlgrid_jstart_of_rgnl_dom_on_t6g} "%s" "${gfdlgrid_jstart_of_rgnl_dom_on_t6g}"
  fi

  if [ ! -z "${outvarname_gfdlgrid_jend_of_rgnl_dom_on_t6g}" ]; then
    printf -v ${outvarname_gfdlgrid_jend_of_rgnl_dom_on_t6g} "%s" "${gfdlgrid_jend_of_rgnl_dom_on_t6g}"
  fi

  if [ ! -z "${outvarname_gfdlgrid_use_gfdlgrid_res_in_filenames}" ]; then
    printf -v ${outvarname_gfdlgrid_use_gfdlgrid_res_in_filenames} "%s" "${gfdlgrid_use_gfdlgrid_res_in_filenames}"
  fi

  if [ ! -z "${outvarname_dt_atmos}" ]; then
    printf -v ${outvarname_dt_atmos} "%s" "${dt_atmos}"
  fi

  if [ ! -z "${outvarname_layout_x}" ]; then
    printf -v ${outvarname_layout_x} "%s" "${layout_x}"
  fi

  if [ ! -z "${outvarname_layout_y}" ]; then
    printf -v ${outvarname_layout_y} "%s" "${layout_y}"
  fi

  if [ ! -z "${outvarname_blocksize}" ]; then
    printf -v ${outvarname_blocksize} "%s" "${blocksize}"
  fi

  if [ ! -z "${outvarname_wrtcmp_write_groups}" ]; then
    printf -v ${outvarname_wrtcmp_write_groups} "%s" "${wrtcmp_write_groups}"
  fi

  if [ ! -z "${outvarname_wrtcmp_write_tasks_per_group}" ]; then
    printf -v ${outvarname_wrtcmp_write_tasks_per_group} "%s" "${wrtcmp_write_tasks_per_group}"
  fi

  if [ ! -z "${outvarname_wrtcmp_output_grid}" ]; then
    printf -v ${outvarname_wrtcmp_output_grid} "%s" "${wrtcmp_output_grid}"
  fi

  if [ ! -z "${outvarname_wrtcmp_cen_lon}" ]; then
    printf -v ${outvarname_wrtcmp_cen_lon} "%s" "${wrtcmp_cen_lon}"
  fi

  if [ ! -z "${outvarname_wrtcmp_cen_lat}" ]; then
    printf -v ${outvarname_wrtcmp_cen_lat} "%s" "${wrtcmp_cen_lat}"
  fi

  if [ ! -z "${outvarname_wrtcmp_stdlat1}" ]; then
    printf -v ${outvarname_wrtcmp_stdlat1} "%s" "${wrtcmp_stdlat1}"
  fi

  if [ ! -z "${outvarname_wrtcmp_stdlat2}" ]; then
    printf -v ${outvarname_wrtcmp_stdlat2} "%s" "${wrtcmp_stdlat2}"
  fi

  if [ ! -z "${outvarname_wrtcmp_nx}" ]; then
    printf -v ${outvarname_wrtcmp_nx} "%s" "${wrtcmp_nx}"
  fi

  if [ ! -z "${outvarname_wrtcmp_ny}" ]; then
    printf -v ${outvarname_wrtcmp_ny} "%s" "${wrtcmp_ny}"
  fi

  if [ ! -z "${outvarname_wrtcmp_lon_lwr_left}" ]; then
    printf -v ${outvarname_wrtcmp_lon_lwr_left} "%s" "${wrtcmp_lon_lwr_left}"
  fi

  if [ ! -z "${outvarname_wrtcmp_lat_lwr_left}" ]; then
    printf -v ${outvarname_wrtcmp_lat_lwr_left} "%s" "${wrtcmp_lat_lwr_left}"
  fi

  if [ ! -z "${outvarname_wrtcmp_lon_upr_rght}" ]; then
    printf -v ${outvarname_wrtcmp_lon_upr_rght} "%s" "${wrtcmp_lon_upr_rght}"
  fi

  if [ ! -z "${outvarname_wrtcmp_lat_upr_rght}" ]; then
    printf -v ${outvarname_wrtcmp_lat_upr_rght} "%s" "${wrtcmp_lat_upr_rght}"
  fi

  if [ ! -z "${outvarname_wrtcmp_dx}" ]; then
    printf -v ${outvarname_wrtcmp_dx} "%s" "${wrtcmp_dx}"
  fi

  if [ ! -z "${outvarname_wrtcmp_dy}" ]; then
    printf -v ${outvarname_wrtcmp_dy} "%s" "${wrtcmp_dy}"
  fi

  if [ ! -z "${outvarname_wrtcmp_dlon}" ]; then
    printf -v ${outvarname_wrtcmp_dlon} "%s" "${wrtcmp_dlon}"
  fi

  if [ ! -z "${outvarname_wrtcmp_dlat}" ]; then
    printf -v ${outvarname_wrtcmp_dlat} "%s" "${wrtcmp_dlat}"
  fi
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/func-
# tion.
#
#-----------------------------------------------------------------------
#
  { restore_shell_opts; } > /dev/null 2>&1

}
