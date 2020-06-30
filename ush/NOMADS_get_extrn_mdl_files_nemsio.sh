#!/bin/bash
# Command line arguments
if [ -z "$1" -o -z "$2" ]; then
   echo "Usage: $0 yyyymmdd hh"
   exit
fi
yyyymmdd=$1 #i.e. "20191224"
hh=$2 #i.e. "12"
if [ "$#" -ge 3 ]; then
   nfcst=$3
else 
   nfcst=6
fi
if [ "$#" -ge 4 ]; then
   nfcst_int=$4
else 
   nfcst_int=3
fi

# Get the data (do not need to edit anything after this point!)
yyyymm=$((yyyymmdd/100))
#din_loc_ic=`./xmlquery DIN_LOC_IC --value`
mkdir -p $yyyymm/$yyyymmdd
echo "Download files to $din_loc_ic/$yyyymm/$yyyymmdd ..."
cd $yyyymm/$yyyymmdd
wget -c https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$yyyymmdd/$hh/gfs.t${hh}z.atmanl.nemsio
wget -c https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$yyyymmdd/$hh/gfs.t${hh}z.sfcanl.nemsio
ifcst=$nfcst_int
while [ $ifcst -le $nfcst ] 
do
echo $ifcst
  if [ $ifcst -le 99 ]; then 
     if [ $ifcst -le 9 ]; then
        ifcst_str="00"$ifcst
     else
        ifcst_str="0"$ifcst
     fi
  else
        ifcst_str="$ifcst"
 fi
 echo $ifcst_str
wget -c https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$yyyymmdd/$hh/gfs.t${hh}z.atmf${ifcst_str}.nemsio
wget -c https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$yyyymmdd/$hh/gfs.t${hh}z.sfcf${ifcst_str}.nemsio
ifcst=$[$ifcst+$nfcst_int]
done
