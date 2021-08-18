#!/bin/bash

#
# Usage:
#
# To get files for generating ICs:
#
#   ./get_FV3GFS_grib2_files_from_NOMADS.sh "cheyenne" "./tmp" "ICS" "2021081500"
#
# To get files for generating LBCs, e.g. at forecast hours 1, 2, and 4:
#
# ./get_FV3GFS_grib2_files_from_NOMADS.sh "cheyenne" "./tmp" "LBCS" "2021081500" "1 2 4"
#

set -u

. ./source_util_funcs.sh
. ./extrn_mdl/set_extrn_mdl_filenames.sh
. ./extrn_mdl/set_extrn_mdl_arcv_file_dir_names.sh
. ./extrn_mdl/get_extrn_mdl_files_from_nomads.sh

export MACHINE="${1^^}"
staging_dir="$2"
ics_or_lbcs="${3^^}"
cdate="$4"
if [ "${ics_or_lbcs}" = "LBCS" ]; then
# Note: Need to use "eval" here, otherwise will be incorrect!
  eval lbc_spec_fhrs=( "$5" )
else
  lbc_spec_fhrs=( "" )
fi

data_src="nomads"
extrn_mdl_name="FV3GFS"
export FV3GFS_FILE_FMT_ICS="grib2"
export FV3GFS_FILE_FMT_LBCS="grib2"

export EXTRN_MDL_DIR_FILE_LAYOUT=""
export EXTRN_MDL_FNS_ICS=("")
export EXTRN_MDL_FNS_LBCS_PREFIX=""
export EXTRN_MDL_FNS_LBCS_SUFFIX=""

mkdir -p "${staging_dir}"

lbc_spec_fhrs_str="( "$( printf "\"%s\" " "${lbc_spec_fhrs[@]}" )")" 
set_extrn_mdl_filenames \
  data_src="${data_src}" \
  extrn_mdl_name="${extrn_mdl_name}" \
  ics_or_lbcs="${ics_or_lbcs}" \
  cdate="$cdate" \
  lbc_spec_fhrs="${lbc_spec_fhrs_str}" \
  outvarname_fns="__fns"

fns_str="( "$( printf "\"%s\" " "${__fns[@]}" )")"

set_extrn_mdl_arcv_file_dir_names \
  extrn_mdl_name="${extrn_mdl_name}" \
  ics_or_lbcs="${ics_or_lbcs}" \
  cdate="$cdate" \
  outvarname_arcvrel_dir="__arcvrel_dir"

get_extrn_mdl_files_from_nomads \
  extrn_mdl_name="${extrn_mdl_name}" \
  ics_or_lbcs="${ics_or_lbcs}" \
  staging_dir="${staging_dir}" \
  arcvrel_dir="${__arcvrel_dir}" \
  fns="${fns_str}"


