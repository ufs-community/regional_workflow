#!/bin/sh
set -eux
#
# Check for input argument: this should be the "platform" if it exists.
#
if [ $# -eq 0 ]; then
  echo
  echo "No 'platform' argument supplied"
  echo "Using directory structure to determine machine settings"
  platform=''
else 
  platform=$1
fi
echo "hjp111,platform=",$platform
#
#source ./machine-setup.sh $platform > /dev/null 2>&1
source ./machine-setup.sh $platform
echo "hjp112"
#
# Set the name of the package.  This will also be the name of the execu-
# table that will be built.
#
package_name="arl_nexus"
#
# Make an exec folder if it doesn't already exist.
#
mkdir -p ../exec
#
# Change directory to where the source code is located.
# 
cd ${package_name}
home_dir=`pwd`/../../
src_dir=`pwd`
build_dir=${src_dir}/build
#
# Load modules.
#
set +x
modules_dir=${src_dir}/modulefiles
module_name=${platform}
module_path=${modules_dir}/${module_name}
if [ ! -r ${module_path} ]; then
  # select Intel compilers if no generic module file is available
  module_name=${module_name}.intel
  module_path=${modules_dir}/${module_name}
fi
if [ -r ${module_path} ]; then
  module use  ${modules_dir}
  module load ${module_name}
else
  echo "No module file found for platform: ${platform}"
  exit 1
fi
#
# Build NEXUS
#
mkdir -p ${build_dir}
cd ${build_dir}
cmake ..
make -j
#
# Install NEXUS
#
ln -sf ${build_dir}/bin/nexus ${home_dir}/exec
ln -sf ${module_path} ${build_dir}/modules

exit $?
