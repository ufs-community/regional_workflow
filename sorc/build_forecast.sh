#! /usr/bin/env bash
set -eux

. ../ush/source_util_funcs.sh

source ./machine-setup.sh > /dev/null 2>&1
cwd=`pwd`

USE_PREINST_LIBS=${USE_PREINST_LIBS:-"true"}
if [ $USE_PREINST_LIBS = true ]; then
  export MOD_PATH=/scratch3/NCEPDEV/nwprod/lib/modulefiles
else
  export MOD_PATH=${cwd}/lib/modulefiles
fi

# Check final exec folder exists
if [ ! -d "../exec" ]; then
  mkdir ../exec
fi

if [ $target = hera ]; then target=hera.intel ; fi

if [ $target = jet ]; then target=jet.intel ; fi

if [ $target = cheyenne ]; then target=cheyenne.intel ; fi

#------------------------------------
# Get from the manage_externals configuration file the relative directo-
# ries in which the UFS utility codes (not including chgres_cube) and 
# the chgres_cube codes get cloned.  Note that these two sets of codes
# are in the same repository but different branches.  These directories
# will be relative to the workflow home directory, which we denote below
# by HOMErrfs.  Then form the absolute paths to these codes.
#------------------------------------
HOMErrfs=$( readlink -f "${cwd}/.." )
mng_extrns_cfg_fn="${HOMErrfs}/Externals.cfg"
mdl_extrns_cfg_fp="${HOMErrfs}/conf/fcst_model.cfg"
workflow_cfg_fp="${HOMErrfs}/ush/config.sh"
property_name="local_path"

fcst_model_name=$( get_fcst_model_name ${workflow_cfg_fp} ) || \
print_err_msg_exit "\
Call to function get_fcst_model_name failed."

get_fcst_model_info ${mdl_extrns_cfg_fp} "${fcst_model_name}" external_name build_dir build_cmd build_opt exec_path

forecast_model_dir=$( \
get_manage_externals_config_property \
"${mng_extrns_cfg_fn}" "${external_name}" "${property_name}" ) || \
print_err_msg_exit "\
Call to function get_manage_config_externals_property failed."
forecast_model_dir="${HOMErrfs}/${forecast_model_dir}"

cd ${forecast_model_dir}

case "${build_cmd}" in
  gmake)
    cmd="cd ${build_dir} && gmake ${build_opt}"
    ;;
  compile)
    FV3=$( pwd -P )/FV3
    cmd="cd ${build_dir} && ./compile.sh $FV3 $target \"${build_opt}\""
    ;;
  *)
    print_err_msg_exit "\
    Unsupported build command: \"${build_cmd}\""
    ;;
esac

eval ${cmd}
