#!/bin/sh

# This script reorganizes the CCPA data into a more intuitive structure:
# A valid YYYYMMDD directory is created, and all files for the valid day are placed within the directory.
# The accumulation interval is an input argument. Current supported accumulations: 01h, 03h, and 06h.

# Top-level CCPA directory
ccpa_dir=/scratch2/BMC/det/jwolff/HIWT/obs/ccpa
if [[ ! -d "$ccpa_dir" ]]; then
  mkdir -p $ccpa_dir
fi

# CCPA data from HPSS
ccpa_raw=$ccpa_dir/raw
if [[ ! -d "$ccpa_raw" ]]; then
  mkdir -p $ccpa_raw
fi

# Reorganized CCPA location
ccpa_proc=$ccpa_dir/proc
if [[ ! -d "$ccpa_proc" ]]; then
  mkdir -p $ccpa_proc
fi

# Accumulation
accum=01

# Initialization
init=2019101112

# Forecast length
fcst_length=24

current_fcst=$accum
while [[ ${current_fcst} -le ${fcst_length} ]]; do
  fcst_sec=`expr ${current_fcst} \* 3600` # convert forecast lead hour to seconds
  yyyy=`echo ${init} | cut -c1-4`  # year (YYYY) of initialization time
  mm=`echo ${init} | cut -c5-6`    # month (MM) of initialization time
  dd=`echo ${init} | cut -c7-8`    # day (DD) of initialization time
  hh=`echo ${init} | cut -c9-10`   # hour (HH) of initialization time
  init_ut=`date -ud ''${yyyy}-${mm}-${dd}' UTC '${hh}':00:00' +%s` # convert initialization time to universal time
  vdate_ut=`expr ${init_ut} + ${fcst_sec}` # calculate current forecast time in universal time
  vdate=`date -ud '1970-01-01 UTC '${vdate_ut}' seconds' +%Y%m%d%H` # convert universal time to standard time
  vyyyymmdd=`echo ${vdate} | cut -c1-8`  # forecast time (YYYYMMDD)
  vyyyy=`echo ${vdate} | cut -c1-4`  # year (YYYY) of valid time
  vmm=`echo ${vdate} | cut -c5-6`    # month (MM) of valid time
  vdd=`echo ${vdate} | cut -c7-8`    # day (DD) of valid time
  vhh=`echo ${vdate} | cut -c9-10`       # forecast hour (HH)

  vdate_ut_m1=`expr ${vdate_ut} - 86400` # calculate current forecast time in universal time
  vdate_m1=`date -ud '1970-01-01 UTC '${vdate_ut_m1}' seconds' +%Y%m%d%H` # convert universal time to standard time
  vyyyymmdd_m1=`echo ${vdate_m1} | cut -c1-8`  # forecast time (YYYYMMDD)
  vyyyy_m1=`echo ${vdate_m1} | cut -c1-4`  # year (YYYY) of valid time
  vmm_m1=`echo ${vdate_m1} | cut -c5-6`    # month (MM) of valid time
  vdd_m1=`echo ${vdate_m1} | cut -c7-8`    # day (DD) of valid time
  vhh_m1=`echo ${vdate_m1} | cut -c9-10`       # forecast hour (HH)

  vhh_noZero=$(expr ${vhh} + 0)
  vhh_m1_noZero=$(expr ${vhh_m1} + 0)

  # Check if file exists on disk
  ccpa_file="$ccpa_proc/${vyyyymmdd}/ccpa.t${vhh}z.01h.hrap.conus.gb2"
  echo "CCPA FILE:${ccpa_file}"

  if [[ ! -f "${ccpa_file}" ]]; then 
    # Check if valid hour is 00
    if [[ ${vhh_noZero} -ne 0 ]]; then
      if [[ ! -d "$ccpa_raw/${vyyyymmdd}" ]]; then
        mkdir -p $ccpa_raw/${vyyyymmdd}
      fi
      cd $ccpa_raw/${vyyyymmdd}
      # Pull CCPA data from HPSS
      TarFile="/NCEPPROD/hpssprod/runhistory/rh${vyyyy}/${vyyyy}${vmm}/${vyyyy}${vmm}${vdd}/gpfs_dell1_nco_ops_com_ccpa_prod_ccpa.${vyyyy}${vmm}${vdd}.tar"
      TarCommand="htar -xvf ${TarFile} \`htar -tf ${TarFile} | egrep \"ccpa.t${vhh}z.${accum}h.hrap.conus.gb2\" | awk '{print $7}'\`"
      echo "CALLING: ${TarCommand}"
      htar -xvf ${TarFile} `htar -tf ${TarFile} | egrep "ccpa.t${vhh}z.${accum}h.hrap.conus.gb2" | awk '{print $7}'` 
    else
      if [[ ! -d "$ccpa_raw/${vyyyymmdd_m1}" ]]; then
        mkdir -p $ccpa_raw/${vyyyymmdd_m1}
      fi
      cd $ccpa_raw/${vyyyymmdd_m1}
      # Pull CCPA data from HPSS
      TarFile="/NCEPPROD/hpssprod/runhistory/rh${vyyyy_m1}/${vyyyy_m1}${vmm_m1}/${vyyyy_m1}${vmm_m1}${vdd_m1}/gpfs_dell1_nco_ops_com_ccpa_prod_ccpa.${vyyyy_m1}${vmm_m1}${vdd_m1}.tar"
      TarCommand="htar -xvf ${TarFile} \`htar -tf ${TarFile} | egrep \"ccpa.t${vhh}z.${accum}h.hrap.conus.gb2\" | awk '{print $7}'\`"
      echo "CALLING: ${TarCommand}"
      htar -xvf ${TarFile} `htar -tf ${TarFile} | egrep "ccpa.t${vhh}z.${accum}h.hrap.conus.gb2" | awk '{print $7}'`
    fi

    if [[ ! -d "$ccpa_proc/${vyyyymmdd}" ]]; then
      mkdir -p $ccpa_proc/${vyyyymmdd}
    fi 

    if [[ ${vhh_noZero} -ge 1 && ${vhh_noZero} -le 6 ]]; then
      cp $ccpa_raw/${vyyyymmdd}/06/ccpa.t${vhh}z.01h.hrap.conus.gb2 $ccpa_proc/${vyyyymmdd}
    elif [[ ${vhh_noZero} -ge 7 && ${vhh_noZero} -le 12 ]]; then
      cp $ccpa_raw/${vyyyymmdd}/12/ccpa.t${vhh}z.01h.hrap.conus.gb2 $ccpa_proc/${vyyyymmdd}
    elif [[ ${vhh_noZero} -ge 13 && ${vhh_noZero} -le 18 ]]; then
      cp $ccpa_raw/${vyyyymmdd}/18/ccpa.t${vhh}z.01h.hrap.conus.gb2 $ccpa_proc/${vyyyymmdd}
    elif [[ ${vhh_noZero} -ge 19 && ${vhh_noZero} -le 23 ]]; then
      cp $ccpa_raw/${vyyyymmdd}/00/ccpa.t${vhh}z.01h.hrap.conus.gb2 ${ccpa_proc}/${vyyyymmdd}
    elif [[ ${vhh_noZero} -eq 0 ]]; then
      cp $ccpa_raw/${vyyyymmdd_m1}/00/ccpa.t${vhh}z.01h.hrap.conus.gb2 ${ccpa_proc}/${vyyyymmdd}
    fi
  fi

  current_fcst=$((${current_fcst} + ${accum}))
  echo "new fcst=${current_fcst}"

done
