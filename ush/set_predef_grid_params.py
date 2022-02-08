#!/usr/bin/env python3

import unittest
import os

from constants import radius_Earth,degs_per_radian

from python_utils import process_args,import_vars,export_vars,set_env_var,get_env_var,\
                         print_input_args,define_macos_utilities

def set_predef_grid_params():
    """ Sets grid parameters for the specified predfined grid 

    Args:
        None
    Returns:
        None
    """
    # import all environement variables
    import_vars()

    global DT_ATMOS, LAYOUT_X, LAYOUT_Y, BLOCKSIZE, GFDLgrid_RES
    #
    #-----------------------------------------------------------------------
    #
    # Set grid and other parameters according to the value of the predefined
    # domain (PREDEF_GRID_NAME).  Note that the code will enter this script
    # only if PREDEF_GRID_NAME has a valid (and non-empty) value.
    #
    ####################
    # The following comments need to be updated:
    ####################
    #
    # 1) Reset the experiment title (expt_title).
    # 2) Reset the grid parameters.
    # 3) If the write component is to be used (i.e. QUILTING is set to
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
    #
    #-----------------------------------------------------------------------
    #
    # The RRFS CONUS domain with ~25km cells.
    #
    #-----------------------------------------------------------------------
    #
    if PREDEF_GRID_NAME == "RRFS_CONUS_25km":
    
      GRID_GEN_METHOD="ESGgrid"
    
      ESGgrid_LON_CTR=-97.5
      ESGgrid_LAT_CTR=38.5
    
      ESGgrid_DELX=25000.0
      ESGgrid_DELY=25000.0
    
      ESGgrid_NX=202
      ESGgrid_NY=116
    
      ESGgrid_PAZI=0.0
    
      ESGgrid_WIDE_HALO_WIDTH=6
    
      DT_ATMOS=DT_ATMOS or 40
    
      LAYOUT_X=LAYOUT_X or 5
      LAYOUT_Y=LAYOUT_Y or 2
      BLOCKSIZE=BLOCKSIZE or 40
    
      if QUILTING == True:
        WRTCMP_write_groups=1
        WRTCMP_write_tasks_per_group=2
        WRTCMP_output_grid="lambert_conformal"
        WRTCMP_cen_lon=ESGgrid_LON_CTR
        WRTCMP_cen_lat=ESGgrid_LAT_CTR
        WRTCMP_stdlat1=ESGgrid_LAT_CTR
        WRTCMP_stdlat2=ESGgrid_LAT_CTR
        WRTCMP_nx=199
        WRTCMP_ny=111
        WRTCMP_lon_lwr_left=-121.23349066
        WRTCMP_lat_lwr_left=23.41731593
        WRTCMP_dx=ESGgrid_DELX
        WRTCMP_dy=ESGgrid_DELY
    #
    #-----------------------------------------------------------------------
    #
    # The RRFS CONUS domain with ~13km cells.
    #
    #-----------------------------------------------------------------------
    #
    elif PREDEF_GRID_NAME == "RRFS_CONUS_13km":
    
      GRID_GEN_METHOD="ESGgrid"
    
      ESGgrid_LON_CTR=-97.5
      ESGgrid_LAT_CTR=38.5
    
      ESGgrid_DELX=13000.0
      ESGgrid_DELY=13000.0
    
      ESGgrid_NX=396
      ESGgrid_NY=232
    
      ESGgrid_PAZI=0.0
      
      ESGgrid_WIDE_HALO_WIDTH=6
    
      DT_ATMOS=DT_ATMOS or 45
    
      LAYOUT_X=LAYOUT_X or 16
      LAYOUT_Y=LAYOUT_Y or 10
      BLOCKSIZE=BLOCKSIZE or 32
    
      if QUILTING == True:
        WRTCMP_write_groups=1
        WRTCMP_write_tasks_per_group=LAYOUT_Y
        WRTCMP_output_grid="lambert_conformal"
        WRTCMP_cen_lon=ESGgrid_LON_CTR
        WRTCMP_cen_lat=ESGgrid_LAT_CTR
        WRTCMP_stdlat1=ESGgrid_LAT_CTR
        WRTCMP_stdlat2=ESGgrid_LAT_CTR
        WRTCMP_nx=393
        WRTCMP_ny=225
        WRTCMP_lon_lwr_left=-121.70231097
        WRTCMP_lat_lwr_left=22.57417972
        WRTCMP_dx=ESGgrid_DELX
        WRTCMP_dy=ESGgrid_DELY
    #
    #-----------------------------------------------------------------------
    #
    # The RRFS CONUS domain with ~3km cells.
    #
    #-----------------------------------------------------------------------
    #
    elif PREDEF_GRID_NAME == "RRFS_CONUS_3km":
    
      GRID_GEN_METHOD="ESGgrid"
    
      ESGgrid_LON_CTR=-97.5
      ESGgrid_LAT_CTR=38.5
    
      ESGgrid_DELX=3000.0
      ESGgrid_DELY=3000.0
    
      ESGgrid_NX=1748
      ESGgrid_NY=1038
    
      ESGgrid_PAZI=0.0
    
      ESGgrid_WIDE_HALO_WIDTH=6
    
      DT_ATMOS=DT_ATMOS or 40
    
      LAYOUT_X=LAYOUT_X or 30
      LAYOUT_Y=LAYOUT_Y or 16
      BLOCKSIZE=BLOCKSIZE or 32
    
      if QUILTING == True:
        WRTCMP_write_groups=1
        WRTCMP_write_tasks_per_group=LAYOUT_Y
        WRTCMP_output_grid="lambert_conformal"
        WRTCMP_cen_lon=ESGgrid_LON_CTR
        WRTCMP_cen_lat=ESGgrid_LAT_CTR
        WRTCMP_stdlat1=ESGgrid_LAT_CTR
        WRTCMP_stdlat2=ESGgrid_LAT_CTR
        WRTCMP_nx=1746
        WRTCMP_ny=1014
        WRTCMP_lon_lwr_left=-122.17364391
        WRTCMP_lat_lwr_left=21.88588562
        WRTCMP_dx=ESGgrid_DELX
        WRTCMP_dy=ESGgrid_DELY
    #
    #-----------------------------------------------------------------------
    #
    # The RRFS SUBCONUS domain with ~3km cells.
    #
    #-----------------------------------------------------------------------
    #
    elif PREDEF_GRID_NAME == "RRFS_SUBCONUS_3km":
    
      GRID_GEN_METHOD="ESGgrid"
    
      ESGgrid_LON_CTR=-97.5
      ESGgrid_LAT_CTR=35.0
    
      ESGgrid_DELX=3000.0
      ESGgrid_DELY=3000.0
    
      ESGgrid_NX=840
      ESGgrid_NY=600
    
      ESGgrid_PAZI=0.0
      
      ESGgrid_WIDE_HALO_WIDTH=6
    
      DT_ATMOS=DT_ATMOS or 40
    
      LAYOUT_X=LAYOUT_X or 30
      LAYOUT_Y=LAYOUT_Y or 24
      BLOCKSIZE=BLOCKSIZE or 35
    
      if QUILTING == True:
        WRTCMP_write_groups=1
        WRTCMP_write_tasks_per_group=LAYOUT_Y
        WRTCMP_output_grid="lambert_conformal"
        WRTCMP_cen_lon=ESGgrid_LON_CTR
        WRTCMP_cen_lat=ESGgrid_LAT_CTR
        WRTCMP_stdlat1=ESGgrid_LAT_CTR
        WRTCMP_stdlat2=ESGgrid_LAT_CTR
        WRTCMP_nx=837
        WRTCMP_ny=595
        WRTCMP_lon_lwr_left=-109.97410429
        WRTCMP_lat_lwr_left=26.31459843
        WRTCMP_dx=ESGgrid_DELX
        WRTCMP_dy=ESGgrid_DELY
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
    elif PREDEF_GRID_NAME == "RRFS_AK_13km":
    
      GRID_GEN_METHOD="ESGgrid"
    
      ESGgrid_LON_CTR=-161.5
      ESGgrid_LAT_CTR=63.0
    
      ESGgrid_DELX=13000.0
      ESGgrid_DELY=13000.0
    
      ESGgrid_NX=320
      ESGgrid_NY=240
    
      ESGgrid_PAZI=0.0
      
      ESGgrid_WIDE_HALO_WIDTH=6
    
    #  DT_ATMOS=DT_ATMOS or 50
      DT_ATMOS=DT_ATMOS or 10
    
      LAYOUT_X=LAYOUT_X or 16
      LAYOUT_Y=LAYOUT_Y or 12
      BLOCKSIZE=BLOCKSIZE or 40
    
      if QUILTING == True:
        WRTCMP_write_groups=1
        WRTCMP_write_tasks_per_group=LAYOUT_Y
        WRTCMP_output_grid="lambert_conformal"
        WRTCMP_cen_lon=ESGgrid_LON_CTR
        WRTCMP_cen_lat=ESGgrid_LAT_CTR
        WRTCMP_stdlat1=ESGgrid_LAT_CTR
        WRTCMP_stdlat2=ESGgrid_LAT_CTR
    
    # The following work.  They were obtained using the NCL scripts but only
    # after manually modifying the longitutes of two of the 4 corners of the
    # domain to add 360.0 to them.  Need to automate that procedure.
        WRTCMP_nx=318
        WRTCMP_ny=234
    #    WRTCMP_lon_lwr_left=-187.76660836
        WRTCMP_lon_lwr_left=172.23339164
        WRTCMP_lat_lwr_left=45.77691870
    
        WRTCMP_dx=ESGgrid_DELX
        WRTCMP_dy=ESGgrid_DELY
    # The following rotated_latlon coordinate system parameters were obtained
    # using the NCL code and work.
    #    if QUILTING == True:
    #      WRTCMP_write_groups=1
    #      WRTCMP_write_tasks_per_group=LAYOUT_Y
    #      WRTCMP_output_grid="rotated_latlon"
    #      WRTCMP_cen_lon=ESGgrid_LON_CTR
    #      WRTCMP_cen_lat=ESGgrid_LAT_CTR
    #      WRTCMP_lon_lwr_left="-18.47206579"
    #      WRTCMP_lat_lwr_left="-13.56176982"
    #      WRTCMP_lon_upr_rght="18.47206579"
    #      WRTCMP_lat_upr_rght="13.56176982"
    ##      WRTCMP_dlon="0.11691181"
    ##      WRTCMP_dlat="0.11691181"
    #      WRTCMP_dlon=$( printf "%.9f" $( bc -l <<< "(${ESGgrid_DELX}/${radius_Earth})*${degs_per_radian}" ) )
    #      WRTCMP_dlat=$( printf "%.9f" $( bc -l <<< "(${ESGgrid_DELY}/${radius_Earth})*${degs_per_radian}" ) )
    #    fi
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
    elif PREDEF_GRID_NAME == "RRFS_AK_3km":
    
    #  if [ "${GRID_GEN_METHOD}" = "GFDLgrid" ]; then
    #
    #    GFDLgrid_LON_T6_CTR="-160.8"
    #    GFDLgrid_LAT_T6_CTR="63.0"
    #    GFDLgrid_STRETCH_FAC="1.161"
    #    GFDLgrid_RES="768"
    #    GFDLgrid_REFINE_RATIO="4"
    #
    #    num_margin_cells_T6_left="204"
    #    GFDLgrid_ISTART_OF_RGNL_DOM_ON_T6G=$(( num_margin_cells_T6_left + 1 ))
    #
    #    num_margin_cells_T6_right="204"
    #    GFDLgrid_IEND_OF_RGNL_DOM_ON_T6G=$(( GFDLgrid_RES - num_margin_cells_T6_right ))
    #
    #    num_margin_cells_T6_bottom="249"
    #    GFDLgrid_JSTART_OF_RGNL_DOM_ON_T6G=$(( num_margin_cells_T6_bottom + 1 ))
    #
    #    num_margin_cells_T6_top="249"
    #    GFDLgrid_JEND_OF_RGNL_DOM_ON_T6G=$(( GFDLgrid_RES - num_margin_cells_T6_top ))
    #
    #    GFDLgrid_USE_GFDLgrid_RES_IN_FILENAMES="FALSE"
    #
    #    DT_ATMOS="${DT_ATMOS or 18}"
    #
    #    LAYOUT_X="${LAYOUT_X or 24}"
    #    LAYOUT_Y="${LAYOUT_Y or 24}"
    #    BLOCKSIZE="${BLOCKSIZE or 15}"
    #
    #    if QUILTING == True:
    #      WRTCMP_write_groups=1
    #      WRTCMP_write_tasks_per_group=2
    #      WRTCMP_output_grid="lambert_conformal"
    #      WRTCMP_cen_lon="${GFDLgrid_LON_T6_CTR}"
    #      WRTCMP_cen_lat="${GFDLgrid_LAT_T6_CTR}"
    #      WRTCMP_stdlat1="${GFDLgrid_LAT_T6_CTR}"
    #      WRTCMP_stdlat2="${GFDLgrid_LAT_T6_CTR}"
    #      WRTCMP_nx="1320"
    #      WRTCMP_ny="950"
    #      WRTCMP_lon_lwr_left="173.734"
    #      WRTCMP_lat_lwr_left="46.740347"
    #      WRTCMP_dx=3000.0
    #      WRTCMP_dy=3000.0
    #    fi
    #
    #  elif [ "${GRID_GEN_METHOD}" = "ESGgrid" ]; then
    
      GRID_GEN_METHOD="ESGgrid"
    
      ESGgrid_LON_CTR=-161.5
      ESGgrid_LAT_CTR=63.0
    
      ESGgrid_DELX=3000.0
      ESGgrid_DELY=3000.0
    
      ESGgrid_NX=1380
      ESGgrid_NY=1020
    
      ESGgrid_PAZI=0.0
      
      ESGgrid_WIDE_HALO_WIDTH=6
    
    #  DT_ATMOS=DT_ATMOS or 50
      DT_ATMOS=DT_ATMOS or 10
    
      LAYOUT_X=LAYOUT_X or 30
      LAYOUT_Y=LAYOUT_Y or 17
      BLOCKSIZE=BLOCKSIZE or 40
    
      if QUILTING == True:
        WRTCMP_write_groups=1
        WRTCMP_write_tasks_per_group=LAYOUT_Y
        WRTCMP_output_grid="lambert_conformal"
        WRTCMP_cen_lon=ESGgrid_LON_CTR
        WRTCMP_cen_lat=ESGgrid_LAT_CTR
        WRTCMP_stdlat1=ESGgrid_LAT_CTR
        WRTCMP_stdlat2=ESGgrid_LAT_CTR
        WRTCMP_nx=1379
        WRTCMP_ny=1003
        WRTCMP_lon_lwr_left=-187.89737923
        WRTCMP_lat_lwr_left=45.84576053
        WRTCMP_dx=ESGgrid_DELX
        WRTCMP_dy=ESGgrid_DELY
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
    elif PREDEF_GRID_NAME == "CONUS_25km_GFDLgrid":
    
      GRID_GEN_METHOD="GFDLgrid"
    
      GFDLgrid_LON_T6_CTR=-97.5
      GFDLgrid_LAT_T6_CTR=38.5
      GFDLgrid_STRETCH_FAC=1.4
      GFDLgrid_RES=96
      GFDLgrid_REFINE_RATIO=3
    
      num_margin_cells_T6_left=12
      GFDLgrid_ISTART_OF_RGNL_DOM_ON_T6G=num_margin_cells_T6_left + 1
    
      num_margin_cells_T6_right=12
      GFDLgrid_IEND_OF_RGNL_DOM_ON_T6G=GFDLgrid_RES - num_margin_cells_T6_right
    
      num_margin_cells_T6_bottom=16
      GFDLgrid_JSTART_OF_RGNL_DOM_ON_T6G=num_margin_cells_T6_bottom + 1
    
      num_margin_cells_T6_top=16
      GFDLgrid_JEND_OF_RGNL_DOM_ON_T6G=GFDLgrid_RES - num_margin_cells_T6_top
    
      GFDLgrid_USE_GFDLgrid_RES_IN_FILENAMES="TRUE"
    
      DT_ATMOS=DT_ATMOS or 225
    
      LAYOUT_X=LAYOUT_X or 6
      LAYOUT_Y=LAYOUT_Y or 4
      BLOCKSIZE=BLOCKSIZE or 36
    
      if QUILTING == True:
        WRTCMP_write_groups=1
        WRTCMP_write_tasks_per_group=LAYOUT_Y
        WRTCMP_output_grid="rotated_latlon"
        WRTCMP_cen_lon=GFDLgrid_LON_T6_CTR
        WRTCMP_cen_lat=GFDLgrid_LAT_T6_CTR
        WRTCMP_lon_lwr_left=-24.40085141
        WRTCMP_lat_lwr_left=-19.65624142
        WRTCMP_lon_upr_rght=24.40085141
        WRTCMP_lat_upr_rght=19.65624142
        WRTCMP_dlon=0.22593381
        WRTCMP_dlat=0.22593381
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
    elif PREDEF_GRID_NAME == "CONUS_3km_GFDLgrid":
    
      GRID_GEN_METHOD="GFDLgrid"
    
      GFDLgrid_LON_T6_CTR=-97.5
      GFDLgrid_LAT_T6_CTR=38.5
      GFDLgrid_STRETCH_FAC=1.5
      GFDLgrid_RES=768
      GFDLgrid_REFINE_RATIO=3
    
      num_margin_cells_T6_left=69
      GFDLgrid_ISTART_OF_RGNL_DOM_ON_T6G=num_margin_cells_T6_left + 1
    
      num_margin_cells_T6_right=69
      GFDLgrid_IEND_OF_RGNL_DOM_ON_T6G=GFDLgrid_RES - num_margin_cells_T6_right
    
      num_margin_cells_T6_bottom=164
      GFDLgrid_JSTART_OF_RGNL_DOM_ON_T6G=num_margin_cells_T6_bottom + 1
    
      num_margin_cells_T6_top=164
      GFDLgrid_JEND_OF_RGNL_DOM_ON_T6G=GFDLgrid_RES - num_margin_cells_T6_top
    
      GFDLgrid_USE_GFDLgrid_RES_IN_FILENAMES="TRUE"
    
      DT_ATMOS=DT_ATMOS or 18
    
      LAYOUT_X=LAYOUT_X or 30
      LAYOUT_Y=LAYOUT_Y or 22
      BLOCKSIZE=BLOCKSIZE or 35
    
      if QUILTING == True:
        WRTCMP_write_groups=1
        WRTCMP_write_tasks_per_group=LAYOUT_Y
        WRTCMP_output_grid="rotated_latlon"
        WRTCMP_cen_lon=GFDLgrid_LON_T6_CTR
        WRTCMP_cen_lat=GFDLgrid_LAT_T6_CTR
        WRTCMP_lon_lwr_left=-25.23144805
        WRTCMP_lat_lwr_left=-15.82130419
        WRTCMP_lon_upr_rght=25.23144805
        WRTCMP_lat_upr_rght=15.82130419
        WRTCMP_dlon=0.02665763
        WRTCMP_dlat=0.02665763
    #
    #-----------------------------------------------------------------------
    #
    # EMC's Alaska grid.
    #
    #-----------------------------------------------------------------------
    #
    elif PREDEF_GRID_NAME == "EMC_AK":
    
    #  if [ "${GRID_GEN_METHOD}" = "GFDLgrid" ]; then
    
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
    
    #    GFDLgrid_LON_T6_CTR="-153.0"
    #    GFDLgrid_LAT_T6_CTR="61.0"
    #    GFDLgrid_STRETCH_FAC="1.0"  # ???
    #    GFDLgrid_RES="768"
    #    GFDLgrid_REFINE_RATIO=3   # ???
    #
    #    num_margin_cells_T6_left="61"
    #    GFDLgrid_ISTART_OF_RGNL_DOM_ON_T6G=$(( num_margin_cells_T6_left + 1 ))
    #
    #    num_margin_cells_T6_right="67"
    #    GFDLgrid_IEND_OF_RGNL_DOM_ON_T6G=$(( GFDLgrid_RES - num_margin_cells_T6_right ))
    #
    #    num_margin_cells_T6_bottom=1.5
    #    GFDLgrid_JSTART_OF_RGNL_DOM_ON_T6G=$(( num_margin_cells_T6_bottom + 1 ))
    #
    #    num_margin_cells_T6_top="171"
    #    GFDLgrid_JEND_OF_RGNL_DOM_ON_T6G=$(( GFDLgrid_RES - num_margin_cells_T6_top ))
    #
    #    GFDLgrid_USE_GFDLgrid_RES_IN_FILENAMES="TRUE"
    #
    #    DT_ATMOS="${DT_ATMOS or 18}"
    #
    #    LAYOUT_X="${LAYOUT_X or 16}"
    #    LAYOUT_Y="${LAYOUT_Y or 48}"
    #    WRTCMP_write_groups=2
    #    WRTCMP_write_tasks_per_group="24"
    #    BLOCKSIZE="${BLOCKSIZE or 32}"
    #
    #  elif [ "${GRID_GEN_METHOD}" = "ESGgrid" ]; then
    
      GRID_GEN_METHOD="ESGgrid"
    
    # Values taken from pre-generated files in /scratch4/NCEPDEV/fv3-cam/save/Benjamin.Blake/regional_workflow/fix/fix_sar
    # With move to Hera, those files were lost; a backup can be found here: /scratch2/BMC/det/kavulich/fix/fix_sar
    
    # Longitude and latitude for center of domain
      ESGgrid_LON_CTR=-153.0
      ESGgrid_LAT_CTR=61.0
    
    # Projected grid spacing in meters...in the static files (e.g. "C768_grid.tile7.nc"), the "dx" is actually the resolution
    # of the supergrid, which is HALF of this dx
      ESGgrid_DELX=3000.0
      ESGgrid_DELY=3000.0
    
    # Number of x and y points for your domain (halo not included);
    # Divide "supergrid" values from /scratch2/BMC/det/kavulich/fix/fix_sar/ak/C768_grid.tile7.halo4.nc by 2 and subtract 8 to eliminate halo
      ESGgrid_NX=1344 # Supergrid value 2704
      ESGgrid_NY=1152 # Supergrid value 2320
    
    # Rotation of the ESG grid in degrees.
      ESGgrid_PAZI=0.0
    
    # Number of halo points for a wide grid (before trimming)...this should almost always be 6 for now
    # Within the model we actually have a 4-point halo and a 3-point halo
      ESGgrid_WIDE_HALO_WIDTH=6
    
    # Side note: FV3 is lagrangian and vertical coordinates are dynamically remapped during model integration
    # 'ksplit' is the factor that determines the timestep for this process (divided
    
    # Physics timestep in seconds, actual dynamics timestep can be a subset of this.
    # This is the time step for the largest atmosphere model loop.  It corresponds to the frequency with which the
    # top-level routine in the dynamics is called as well as the frequency with which the physics is called.
    #
    # Preliminary standard values: 18 for 3-km runs, 90 for 13-km runs per config_defaults.sh
    
      DT_ATMOS=DT_ATMOS or 18
    
    #Factors for MPI decomposition. ESGgrid_NX must be divisible by LAYOUT_X, ESGgrid_NY must be divisible by LAYOUT_Y
      LAYOUT_X=LAYOUT_X or 28
      LAYOUT_Y=LAYOUT_Y or 16
    
    #Take number of points on a tile (nx/lx*ny/ly), must divide by block size to get an integer.
    #This integer must be small enough to fit into a processor's cache, so it is machine-dependent magic
    # For Theia, must be ~40 or less
    # Check setup.sh for more details
      BLOCKSIZE=BLOCKSIZE or 24
    
    #This section is all for the write component, which you need for output during model integration
      if QUILTING == True:
    #Write component reserves MPI tasks for writing output. The number of "groups" is usually 1, but if you have a case where group 1 is not done writing before the next write step, you need group 2, etc.
        WRTCMP_write_groups=1
    #Number of tasks per write group. Ny must be divisible my this number. LAYOUT_Y is usually a good value
        WRTCMP_write_tasks_per_group=24
    #lambert_conformal or rotated_latlon. lambert_conformal not well tested and probably doesn't work for our purposes
        WRTCMP_output_grid="lambert_conformal"
    #These should always be set the same as compute grid
        WRTCMP_cen_lon=ESGgrid_LON_CTR
        WRTCMP_cen_lat=ESGgrid_LAT_CTR
        WRTCMP_stdlat1=ESGgrid_LAT_CTR
        WRTCMP_stdlat2=ESGgrid_LAT_CTR
    #Write component grid must always be <= compute grid (without haloes)
        WRTCMP_nx=1344
        WRTCMP_ny=1152
    #Lower left latlon (southwest corner)
        WRTCMP_lon_lwr_left=-177.0
        WRTCMP_lat_lwr_left=42.5
        WRTCMP_dx=ESGgrid_DELX
        WRTCMP_dy=ESGgrid_DELY
    #
    #-----------------------------------------------------------------------
    #
    # EMC's Hawaii grid.
    #
    #-----------------------------------------------------------------------
    #
    elif PREDEF_GRID_NAME == "EMC_HI":
    
      GRID_GEN_METHOD="ESGgrid"
    
    # Values taken from pre-generated files in /scratch4/NCEPDEV/fv3-cam/save/Benjamin.Blake/regional_workflow/fix/fix_sar/hi/C768_grid.tile7.nc
    # With move to Hera, those files were lost; a backup can be found here: /scratch2/BMC/det/kavulich/fix/fix_sar
    # Longitude and latitude for center of domain
      ESGgrid_LON_CTR=-157.0
      ESGgrid_LAT_CTR=20.0
    
    # Projected grid spacing in meters...in the static files (e.g. "C768_grid.tile7.nc"), the "dx" is actually the resolution
    # of the supergrid, which is HALF of this dx (plus or minus some grid stretch factor)
      ESGgrid_DELX=3000.0
      ESGgrid_DELY=3000.0
    
    # Number of x and y points for your domain (halo not included);
    # Divide "supergrid" values from /scratch2/BMC/det/kavulich/fix/fix_sar/hi/C768_grid.tile7.halo4.nc by 2 and subtract 8 to eliminate halo
      ESGgrid_NX=432 # Supergrid value 880
      ESGgrid_NY=360 # Supergrid value 736
    
    # Rotation of the ESG grid in degrees.
      ESGgrid_PAZI=0.0
    
    # Number of halo points for a wide grid (before trimming)...this should almost always be 6 for now
    # Within the model we actually have a 4-point halo and a 3-point halo
      ESGgrid_WIDE_HALO_WIDTH=6
    
    # Side note: FV3 is lagrangian and vertical coordinates are dynamically remapped during model integration
    # 'ksplit' is the factor that determines the timestep for this process (divided
    
    # Physics timestep in seconds, actual dynamics timestep can be a subset of this.
    # This is the time step for the largest atmosphere model loop.  It corresponds to the frequency with which the
    # top-level routine in the dynamics is called as well as the frequency with which the physics is called.
    #
    # Preliminary standard values: 18 for 3-km runs, 90 for 13-km runs per config_defaults.sh
    
      DT_ATMOS=DT_ATMOS or 18
    
    #Factors for MPI decomposition. ESGgrid_NX must be divisible by LAYOUT_X, ESGgrid_NY must be divisible by LAYOUT_Y
      LAYOUT_X=LAYOUT_X or 8
      LAYOUT_Y=LAYOUT_Y or 8
    #Take number of points on a tile (nx/lx*ny/ly), must divide by block size to get an integer.
    #This integer must be small enough to fit into a processor's cache, so it is machine-dependent magic
    # For Theia, must be ~40 or less
    # Check setup.sh for more details
      BLOCKSIZE=BLOCKSIZE or 27
    
    #This section is all for the write component, which you need for output during model integration
      if QUILTING == True:
    #Write component reserves MPI tasks for writing output. The number of "groups" is usually 1, but if you have a case where group 1 is not done writing before the next write step, you need group 2, etc.
        WRTCMP_write_groups=1
    #Number of tasks per write group. Ny must be divisible my this number. LAYOUT_Y is usually a good value
        WRTCMP_write_tasks_per_group=8
    #lambert_conformal or rotated_latlon. lambert_conformal not well tested and probably doesn't work for our purposes
        WRTCMP_output_grid="lambert_conformal"
    #These should usually be set the same as compute grid
        WRTCMP_cen_lon=ESGgrid_LON_CTR
        WRTCMP_cen_lat=ESGgrid_LAT_CTR
        WRTCMP_stdlat1=ESGgrid_LAT_CTR
        WRTCMP_stdlat2=ESGgrid_LAT_CTR
    #Write component grid should be close to the ESGgrid values unless you are doing something weird
        WRTCMP_nx=420
        WRTCMP_ny=348
    
    #Lower left latlon (southwest corner)
        WRTCMP_lon_lwr_left=-162.8
        WRTCMP_lat_lwr_left=15.2
        WRTCMP_dx=ESGgrid_DELX
        WRTCMP_dy=ESGgrid_DELY
    #
    #-----------------------------------------------------------------------
    #
    # EMC's Puerto Rico grid.
    #
    #-----------------------------------------------------------------------
    #
    elif PREDEF_GRID_NAME == "EMC_PR":
    
      GRID_GEN_METHOD="ESGgrid"
    
    # Values taken from pre-generated files in /scratch4/NCEPDEV/fv3-cam/save/Benjamin.Blake/regional_workflow/fix/fix_sar/pr/C768_grid.tile7.nc
    # With move to Hera, those files were lost; a backup can be found here: /scratch2/BMC/det/kavulich/fix/fix_sar
    # Longitude and latitude for center of domain
      ESGgrid_LON_CTR=-69.0
      ESGgrid_LAT_CTR=18.0
    
    # Projected grid spacing in meters...in the static files (e.g. "C768_grid.tile7.nc"), the "dx" is actually the resolution
    # of the supergrid, which is HALF of this dx (plus or minus some grid stretch factor)
      ESGgrid_DELX=3000.0
      ESGgrid_DELY=3000.0
    
    # Number of x and y points for your domain (halo not included);
    # Divide "supergrid" values from /scratch2/BMC/det/kavulich/fix/fix_sar/pr/C768_grid.tile7.halo4.nc by 2 and subtract 8 to eliminate halo
      ESGgrid_NX=576 # Supergrid value 1168
      ESGgrid_NY=432 # Supergrid value 880
    
    # Rotation of the ESG grid in degrees.
      ESGgrid_PAZI=0.0
    
    # Number of halo points for a wide grid (before trimming)...this should almost always be 6 for now
    # Within the model we actually have a 4-point halo and a 3-point halo
      ESGgrid_WIDE_HALO_WIDTH=6
    
    # Side note: FV3 is lagrangian and vertical coordinates are dynamically remapped during model integration
    # 'ksplit' is the factor that determines the timestep for this process (divided
    
    # Physics timestep in seconds, actual dynamics timestep can be a subset of this.
    # This is the time step for the largest atmosphere model loop.  It corresponds to the frequency with which the
    # top-level routine in the dynamics is called as well as the frequency with which the physics is called.
    #
    # Preliminary standard values: 18 for 3-km runs, 90 for 13-km runs per config_defaults.sh
    
      DT_ATMOS=DT_ATMOS or 18
    
    #Factors for MPI decomposition. ESGgrid_NX must be divisible by LAYOUT_X, ESGgrid_NY must be divisible by LAYOUT_Y
      LAYOUT_X=LAYOUT_X or 16
      LAYOUT_Y=LAYOUT_Y or 8
    
    #Take number of points on a tile (nx/lx*ny/ly), must divide by block size to get an integer.
    #This integer must be small enough to fit into a processor's cache, so it is machine-dependent magic
    # For Theia, must be ~40 or less
    # Check setup.sh for more details
      BLOCKSIZE=BLOCKSIZE or 24
    
    #This section is all for the write component, which you need for output during model integration
      if QUILTING == True:
    #Write component reserves MPI tasks for writing output. The number of "groups" is usually 1, but if you have a case where group 1 is not done writing before the next write step, you need group 2, etc.
        WRTCMP_write_groups=1
    #Number of tasks per write group. Ny must be divisible my this number. LAYOUT_Y is usually a good value
        WRTCMP_write_tasks_per_group=24
    #lambert_conformal or rotated_latlon. lambert_conformal not well tested and probably doesn't work for our purposes
        WRTCMP_output_grid="lambert_conformal"
    #These should always be set the same as compute grid
        WRTCMP_cen_lon=ESGgrid_LON_CTR
        WRTCMP_cen_lat=ESGgrid_LAT_CTR
        WRTCMP_stdlat1=ESGgrid_LAT_CTR
        WRTCMP_stdlat2=ESGgrid_LAT_CTR
    #Write component grid must always be <= compute grid (without haloes)
        WRTCMP_nx=576
        WRTCMP_ny=432
    #Lower left latlon (southwest corner)
        WRTCMP_lon_lwr_left=-77
        WRTCMP_lat_lwr_left=12
        WRTCMP_dx=ESGgrid_DELX
        WRTCMP_dy=ESGgrid_DELY
    #
    #-----------------------------------------------------------------------
    #
    # EMC's Guam grid.
    #
    #-----------------------------------------------------------------------
    #
    elif PREDEF_GRID_NAME == "EMC_GU":
    
      GRID_GEN_METHOD="ESGgrid"
    
    # Values taken from pre-generated files in /scratch4/NCEPDEV/fv3-cam/save/Benjamin.Blake/regional_workflow/fix/fix_sar/guam/C768_grid.tile7.nc
    # With move to Hera, those files were lost; a backup can be found here: /scratch2/BMC/det/kavulich/fix/fix_sar
    # Longitude and latitude for center of domain
      ESGgrid_LON_CTR=146.0
      ESGgrid_LAT_CTR=15.0
    
    # Projected grid spacing in meters...in the static files (e.g. "C768_grid.tile7.nc"), the "dx" is actually the resolution
    # of the supergrid, which is HALF of this dx (plus or minus some grid stretch factor)
      ESGgrid_DELX=3000.0
      ESGgrid_DELY=3000.0
    
    # Number of x and y points for your domain (halo not included);
    # Divide "supergrid" values from /scratch2/BMC/det/kavulich/fix/fix_sar/guam/C768_grid.tile7.halo4.nc by 2 and subtract 8 to eliminate halo
      ESGgrid_NX=432 # Supergrid value 880
      ESGgrid_NY=360 # Supergrid value 736
    
    # Rotation of the ESG grid in degrees.
      ESGgrid_PAZI=0.0
    
    # Number of halo points for a wide grid (before trimming)...this should almost always be 6 for now
    # Within the model we actually have a 4-point halo and a 3-point halo
      ESGgrid_WIDE_HALO_WIDTH=6
    
    # Side note: FV3 is lagrangian and vertical coordinates are dynamically remapped during model integration
    # 'ksplit' is the factor that determines the timestep for this process (divided
    
    # Physics timestep in seconds, actual dynamics timestep can be a subset of this.
    # This is the time step for the largest atmosphere model loop.  It corresponds to the frequency with which the
    # top-level routine in the dynamics is called as well as the frequency with which the physics is called.
    #
    # Preliminary standard values: 18 for 3-km runs, 90 for 13-km runs per config_defaults.sh
    
      DT_ATMOS=DT_ATMOS or 18
    
    #Factors for MPI decomposition. ESGgrid_NX must be divisible by LAYOUT_X, ESGgrid_NY must be divisible by LAYOUT_Y
      LAYOUT_X=LAYOUT_X or 16
      LAYOUT_Y=LAYOUT_Y or 12
    #Take number of points on a tile (nx/lx*ny/ly), must divide by block size to get an integer.
    #This integer must be small enough to fit into a processor's cache, so it is machine-dependent magic
    # For Theia, must be ~40 or less
    # Check setup.sh for more details
      BLOCKSIZE=BLOCKSIZE or 27
    
    #This section is all for the write component, which you need for output during model integration
      if QUILTING == True:
    #Write component reserves MPI tasks for writing output. The number of "groups" is usually 1, but if you have a case where group 1 is not done writing before the next write step, you need group 2, etc.
        WRTCMP_write_groups=1
    #Number of tasks per write group. Ny must be divisible my this number. LAYOUT_Y is usually a good value
        WRTCMP_write_tasks_per_group=24
    #lambert_conformal or rotated_latlon. lambert_conformal not well tested and probably doesn't work for our purposes
        WRTCMP_output_grid="lambert_conformal"
    #These should always be set the same as compute grid
        WRTCMP_cen_lon=ESGgrid_LON_CTR
        WRTCMP_cen_lat=ESGgrid_LAT_CTR
        WRTCMP_stdlat1=ESGgrid_LAT_CTR
        WRTCMP_stdlat2=ESGgrid_LAT_CTR
    #Write component grid must always be <= compute grid (without haloes)
        WRTCMP_nx=420
        WRTCMP_ny=348
    #Lower left latlon (southwest corner) Used /scratch2/NCEPDEV/fv3-cam/Dusan.Jovic/dbrowse/fv3grid utility to find best value
        WRTCMP_lon_lwr_left=140
        WRTCMP_lat_lwr_left=10
        WRTCMP_dx=ESGgrid_DELX
        WRTCMP_dy=ESGgrid_DELY
    #
    #-----------------------------------------------------------------------
    #
    # Emulation of the HAFS v0.A grid at 25 km.
    #
    #-----------------------------------------------------------------------
    #
    elif PREDEF_GRID_NAME == "GSL_HAFSV0.A_25km":
    
      GRID_GEN_METHOD="ESGgrid"
    
      ESGgrid_LON_CTR=-62.0
      ESGgrid_LAT_CTR=22.0
    
      ESGgrid_DELX=25000.0
      ESGgrid_DELY=25000.0
    
      ESGgrid_NX=345
      ESGgrid_NY=230
    
      ESGgrid_PAZI=0.0
    
      ESGgrid_WIDE_HALO_WIDTH=6
    
      DT_ATMOS=DT_ATMOS or 300
    
      LAYOUT_X=LAYOUT_X or 5
      LAYOUT_Y=LAYOUT_Y or 5
      BLOCKSIZE=BLOCKSIZE or 6
    
      if QUILTING == True:
        WRTCMP_write_groups=1
        WRTCMP_write_tasks_per_group=32
        WRTCMP_output_grid="regional_latlon"
        WRTCMP_cen_lon=ESGgrid_LON_CTR
        WRTCMP_cen_lat=25.0
        WRTCMP_lon_lwr_left=-114.5
        WRTCMP_lat_lwr_left=-5.0
        WRTCMP_lon_upr_rght=-9.5
        WRTCMP_lat_upr_rght=55.0
        WRTCMP_dlon=0.25
        WRTCMP_dlat=0.25
    #
    #-----------------------------------------------------------------------
    #
    # Emulation of the HAFS v0.A grid at 13 km.
    #
    #-----------------------------------------------------------------------
    #
    elif PREDEF_GRID_NAME == "GSL_HAFSV0.A_13km":
    
      GRID_GEN_METHOD="ESGgrid"
    
      ESGgrid_LON_CTR=-62.0
      ESGgrid_LAT_CTR=22.0
    
      ESGgrid_DELX=13000.0
      ESGgrid_DELY=13000.0
    
      ESGgrid_NX=665
      ESGgrid_NY=444
    
      ESGgrid_PAZI=0.0
    
      ESGgrid_WIDE_HALO_WIDTH=6
    
      DT_ATMOS=DT_ATMOS or 180
    
      LAYOUT_X=LAYOUT_X or 19
      LAYOUT_Y=LAYOUT_Y or 12
      BLOCKSIZE=BLOCKSIZE or 35
    
      if QUILTING == True:
        WRTCMP_write_groups=1
        WRTCMP_write_tasks_per_group=32
        WRTCMP_output_grid="regional_latlon"
        WRTCMP_cen_lon=ESGgrid_LON_CTR
        WRTCMP_cen_lat=25.0
        WRTCMP_lon_lwr_left=-114.5
        WRTCMP_lat_lwr_left=-5.0
        WRTCMP_lon_upr_rght=-9.5
        WRTCMP_lat_upr_rght=55.0
        WRTCMP_dlon=0.13
        WRTCMP_dlat=0.13
    #
    #-----------------------------------------------------------------------
    #
    # Emulation of the HAFS v0.A grid at 3 km.
    #
    #-----------------------------------------------------------------------
    #
    elif PREDEF_GRID_NAME == "GSL_HAFSV0.A_3km":
    
      GRID_GEN_METHOD="ESGgrid"
    
      ESGgrid_LON_CTR=-62.0
      ESGgrid_LAT_CTR=22.0
    
      ESGgrid_DELX=3000.0
      ESGgrid_DELY=3000.0
    
      ESGgrid_NX=2880
      ESGgrid_NY=1920
    
      ESGgrid_PAZI=0.0
    
      ESGgrid_WIDE_HALO_WIDTH=6
    
      DT_ATMOS=DT_ATMOS or 40
    
      LAYOUT_X=LAYOUT_X or 32
      LAYOUT_Y=LAYOUT_Y or 24
      BLOCKSIZE=BLOCKSIZE or 32
    
      if QUILTING == True:
        WRTCMP_write_groups=1
        WRTCMP_write_tasks_per_group=32
        WRTCMP_output_grid="regional_latlon"
        WRTCMP_cen_lon=ESGgrid_LON_CTR
        WRTCMP_cen_lat=25.0
        WRTCMP_lon_lwr_left=-114.5
        WRTCMP_lat_lwr_left=-5.0
        WRTCMP_lon_upr_rght=-9.5
        WRTCMP_lat_upr_rght=55.0
        WRTCMP_dlon=0.03
        WRTCMP_dlat=0.03
    #
    #-----------------------------------------------------------------------
    #
    # 50-km HRRR Alaska grid.
    #
    #-----------------------------------------------------------------------
    #
    elif PREDEF_GRID_NAME == "GSD_HRRR_AK_50km":
    
      GRID_GEN_METHOD="ESGgrid"
    
      ESGgrid_LON_CTR=-163.5
      ESGgrid_LAT_CTR=62.8
    
      ESGgrid_DELX=50000.0
      ESGgrid_DELY=50000.0
    
      ESGgrid_NX=74
      ESGgrid_NY=51
    
      ESGgrid_PAZI=0.0
    
      ESGgrid_WIDE_HALO_WIDTH=6
    
      DT_ATMOS=DT_ATMOS or 600
    
      LAYOUT_X=LAYOUT_X or 2
      LAYOUT_Y=LAYOUT_Y or 3
      BLOCKSIZE=BLOCKSIZE or 37
    
      if QUILTING == True:
        WRTCMP_write_groups=1
        WRTCMP_write_tasks_per_group=1
        WRTCMP_output_grid="lambert_conformal"
        WRTCMP_cen_lon=ESGgrid_LON_CTR
        WRTCMP_cen_lat=ESGgrid_LAT_CTR
        WRTCMP_stdlat1=ESGgrid_LAT_CTR
        WRTCMP_stdlat2=ESGgrid_LAT_CTR
        WRTCMP_nx=70
        WRTCMP_ny=45
        WRTCMP_lon_lwr_left=172.0
        WRTCMP_lat_lwr_left=49.0
        WRTCMP_dx=ESGgrid_DELX
        WRTCMP_dy=ESGgrid_DELY
    #
    #-----------------------------------------------------------------------
    #
    # Emulation of GSD's RAP domain with ~13km cell size.
    #
    #-----------------------------------------------------------------------
    #
    elif PREDEF_GRID_NAME == "RRFS_NA_13km":
    
    #  if [ "${GRID_GEN_METHOD}" = "GFDLgrid" ]; then
    #
    #    GFDLgrid_LON_T6_CTR=-106.0
    #    GFDLgrid_LAT_T6_CTR=54.0
    #    GFDLgrid_STRETCH_FAC="0.63"
    #    GFDLgrid_RES=384
    #    GFDLgrid_REFINE_RATIO=3
    #
    #    num_margin_cells_T6_left="10"
    #    GFDLgrid_ISTART_OF_RGNL_DOM_ON_T6G=$(( num_margin_cells_T6_left + 1 ))
    #
    #    num_margin_cells_T6_right="10"
    #    GFDLgrid_IEND_OF_RGNL_DOM_ON_T6G=$(( GFDLgrid_RES - num_margin_cells_T6_right ))
    #
    #    num_margin_cells_T6_bottom="10"
    #    GFDLgrid_JSTART_OF_RGNL_DOM_ON_T6G=$(( num_margin_cells_T6_bottom + 1 ))
    #
    #    num_margin_cells_T6_top="10"
    #    GFDLgrid_JEND_OF_RGNL_DOM_ON_T6G=$(( GFDLgrid_RES - num_margin_cells_T6_top ))
    #
    #    GFDLgrid_USE_GFDLgrid_RES_IN_FILENAMES="FALSE"
    #
    #    DT_ATMOS="50"
    #
    #    LAYOUT_X="14"
    #    LAYOUT_Y="14"
    #    BLOCKSIZE="26"
    #
    #    if QUILTING == True:
    #      WRTCMP_write_groups=1
    #      WRTCMP_write_tasks_per_group="14"
    #      WRTCMP_output_grid="rotated_latlon"
    #      WRTCMP_cen_lon="${GFDLgrid_LON_T6_CTR}"
    #      WRTCMP_cen_lat="${GFDLgrid_LAT_T6_CTR}"
    #      WRTCMP_lon_lwr_left="-57.9926"
    #      WRTCMP_lat_lwr_left="-50.74344"
    #      WRTCMP_lon_upr_rght="57.99249"
    #      WRTCMP_lat_upr_rght="50.74344"
    #      WRTCMP_dlon="0.1218331"
    #      WRTCMP_dlat="0.121833"
    #    fi
    #
    #  elif [ "${GRID_GEN_METHOD}" = "ESGgrid" ]; then
    
      GRID_GEN_METHOD="ESGgrid"
    
      ESGgrid_LON_CTR=-106.0
      ESGgrid_LAT_CTR=54.0
    
      ESGgrid_DELX=13000.0
      ESGgrid_DELY=13000.0
    
      ESGgrid_NX=960
      ESGgrid_NY=960
    
      ESGgrid_PAZI=0.0
    
      ESGgrid_WIDE_HALO_WIDTH=6
    
      DT_ATMOS=DT_ATMOS or 50
    
      LAYOUT_X=LAYOUT_X or 16
      LAYOUT_Y=LAYOUT_Y or 16
      BLOCKSIZE=BLOCKSIZE or 30
    
      if QUILTING == True:
        WRTCMP_write_groups=1
        WRTCMP_write_tasks_per_group=16
        WRTCMP_output_grid="rotated_latlon"
        WRTCMP_cen_lon=ESGgrid_LON_CTR
        WRTCMP_cen_lat=ESGgrid_LAT_CTR
        WRTCMP_lon_lwr_left=-55.82538869
        WRTCMP_lat_lwr_left=-48.57685654
        WRTCMP_lon_upr_rght=55.82538869
        WRTCMP_lat_upr_rght=48.57685654
        WRTCMP_dlon=ESGgrid_DELX/radius_Earth*degs_per_radian
        WRTCMP_dlat=ESGgrid_DELY/radius_Earth*degs_per_radian
    #
    #-----------------------------------------------------------------------
    #
    # Future operational RRFS domain with ~3km cell size.
    #
    #-----------------------------------------------------------------------
    #
    elif PREDEF_GRID_NAME == "RRFS_NA_3km":
    
      GRID_GEN_METHOD="ESGgrid"
    
      ESGgrid_LON_CTR=-107.5
      ESGgrid_LAT_CTR=51.5
    
      ESGgrid_DELX=3000.0
      ESGgrid_DELY=3000.0
    
      ESGgrid_NX=3640
      ESGgrid_NY=2520
    
      ESGgrid_PAZI=-13.0
    
      ESGgrid_WIDE_HALO_WIDTH=6
    
      DT_ATMOS=DT_ATMOS or 36
    
      LAYOUT_X=LAYOUT_X or 18   # 40 - EMC operational configuration
      LAYOUT_Y=LAYOUT_Y or 36   # 45 - EMC operational configuration
      BLOCKSIZE=BLOCKSIZE or 28
    
      if QUILTING == True:
        WRTCMP_write_groups=1
        WRTCMP_write_tasks_per_group=144
        WRTCMP_output_grid="rotated_latlon"
        WRTCMP_cen_lon=-112.0 #${ESGgrid_LON_CTR}"
        WRTCMP_cen_lat=48.0 #${ESGgrid_LAT_CTR}"
        WRTCMP_lon_lwr_left=-51.0
        WRTCMP_lat_lwr_left=-33.0
        WRTCMP_lon_upr_rght=51.0
        WRTCMP_lat_upr_rght=33.0
        WRTCMP_dlon=0.025 #$( printf "%.9f" $( bc -l <<< "(${ESGgrid_DELX}/${radius_Earth})*${degs_per_radian}" ) )
        WRTCMP_dlat=0.025 #$( printf "%.9f" $( bc -l <<< "(${ESGgrid_DELY}/${radius_Earth})*${degs_per_radian}" ) )

    #export variables to environment
    export_vars()
    export_vars(dictionary=os.environ, source_dict=locals())
#
#-----------------------------------------------------------------------
#
# Call the function defined above.
#
#-----------------------------------------------------------------------
#
if __name__ == "__main__":
    set_predef_grid_params()

class Testing(unittest.TestCase):
    def test_set_predef_grid_params(self):
        set_predef_grid_params()
        self.assertEqual(get_env_var('GRID_GEN_METHOD'),"ESGgrid")
        self.assertEqual(get_env_var('ESGgrid_LON_CTR'),-97.5)

    def setUp(self):
        define_macos_utilities();
        set_env_var('DEBUG',False)
        set_env_var('PREDEF_GRID_NAME',"RRFS_CONUS_3km")
        set_env_var('DT_ATMOS',36)
        set_env_var('LAYOUT_X',18)
        set_env_var('LAYOUT_Y',36)
        set_env_var('BLOCKSIZE',28)
        set_env_var('QUILTING',True)

