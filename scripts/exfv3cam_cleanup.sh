#!/bin/sh
#############################################################################
# Script name:		exfv3cam_cleanup.sh
# Script description:	Scrub old files and directories
# Script history log:
#   1) 2018-04-09	Ben Blake
#			new script
#############################################################################
set -x

# Remove input and forecast directories that are 2 days old 
# We aew going to need to remake this script!!!
cd ${PTMPDIR}
rm -rf INPUT/${CASE}_${RUN}_${CDATEm2}
rm -rf ${CASE}_${RUN}_${CDATEm2}_${NHRS}h

# Delete images and other files from stmp directory
#cd ${STMPDIR}/${cyc}
#rm -f *gif
#rm -f *html
#rm -f holddate*

exit
