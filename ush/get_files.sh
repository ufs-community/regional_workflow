#!/bin/bash
# Command line arguments
if [ -z "$1" ]; then
   echo "Usage: $0 filename"
   exit
fi
filename=$1

echo "filename = $filename"

wget -c -nv https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/$filename 
