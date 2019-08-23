#!/bin/sh
#############################################################################
# Script name:		exfv3cam_cleanup.sh
# Script description:	Scrub old files and directories
# Script history log:
#   1) 2018-04-09	Ben Blake
#			new script
#############################################################################
set -x

# Remove temporary working directories
cd ${STMP}
if [ $RUN = fv3sar ]; then
  cd tmpnwprd
elif [ $RUN = fv3nest ]; then
  cd tmpnwprd_nest
fi

rm -rf regional_make_bc_${dom}_${CDATE}
rm -rf regional_make_ic_${dom}_${CDATE}
rm -rf regional_forecast_tm00_${dom}_${CDATE}
rm -rf regional_post_${dom}_f*_${CDATE}
rm -rf regional_post_goes_${dom}_f*_${CDATE}

exit
