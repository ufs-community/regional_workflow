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

rm -rf chgres*
rm -rf forecast*
rm -rf post*

# Delete images and other files from stmp directory
#cd ${STMP}/${cyc}
#rm -f *gif
#rm -f *html
#rm -f holddate*

exit
