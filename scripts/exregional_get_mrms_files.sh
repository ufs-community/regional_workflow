#!/bin/sh

# This script pulls MRMS data from the NOAA HPSS
#OBS_DIR=/scratch2/BMC/det/jwolff/HIWT/obs/mrms/proc

# Top-level MRMS directory
mrms_dir=${OBS_DIR}/..
if [[ ! -d "$mrms_dir" ]]; then
  mkdir -p $mrms_dir
fi

# MRMS data from HPSS
mrms_raw=$mrms_dir/raw
if [[ ! -d "$mrms_raw" ]]; then
  mkdir -p $mrms_raw
fi

# Reorganized MRMS location
mrms_proc=$mrms_dir/proc
if [[ ! -d "$mrms_proc" ]]; then
  mkdir -p $mrms_proc
fi

# Initialization
start_init=${CDATE}${hh}
#start_init=2020063000

# Forecast length
fcst_length=${fhr_last}
#fcst_length=36

s_yyyy=`echo ${start_init} | cut -c1-4`  # year (YYYY) of initialization time
s_mm=`echo ${start_init} | cut -c5-6`    # month (MM) of initialization time
s_dd=`echo ${start_init} | cut -c7-8`    # day (DD) of initialization time
s_hh=`echo ${start_init} | cut -c9-10`   # hour (HH) of initialization time
start_init_ut=`date -ud ''${s_yyyy}-${s_mm}-${s_dd}' UTC '${s_hh}':00:00' +%s` # convert initialization time to universal time
#echo "start_init_ut=${start_init_ut}"

end_fcst_sec=`expr ${fcst_length} \* 3600` # convert last forecast lead hour to seconds
end_init_ut=`expr ${start_init_ut} + ${end_fcst_sec}` # calculate current forecast time in universal time
#echo "end_init_ut=${end_init_ut}"
#end_init=`date -ud '1970-01-01 UTC '${end_init_ut}' seconds' +%Y%m%d%H` # convert universal time to standard time
#echo "end_init=${end_init}"

cur_ut=${start_init_ut}
current_fcst=0
fcst_sec=`expr ${current_fcst} \* 3600` # convert forecast lead hour to seconds

while [[ ${cur_ut} -le ${end_init_ut} ]]; do
  cur_init=`date -ud '1970-01-01 UTC '${cur_ut}' seconds' +%Y%m%d%H` # convert universal time to standard time
  echo "cur_init=${cur_init}"

  # Calculate valid date info
  vyyyy=`echo ${cur_init} | cut -c1-4`  # year (YYYY) of initialization time
  vmm=`echo ${cur_init} | cut -c5-6`    # month (MM) of initialization time
  vdd=`echo ${cur_init} | cut -c7-8`    # day (DD) of initialization time
  vhh=`echo ${cur_init} | cut -c9-10`   # hour (HH) of initialization time
  vyyyymmdd=`echo ${cur_init} | cut -c1-8`    # YYYYMMDD of initialization time
  vinit_ut=`date -ud ''${vyyyy}-${vmm}-${vdd}' UTC '${vhh}':00:00' +%s` # convert initialization time to universal time

  #echo "vyyyy vmm vdd vhh = ${vyyyy} ${vmm} ${vdd} ${vhh}"

  # Create necessary raw and proc directories
  if [[ ! -d "$mrms_raw/${vyyyymmdd}" ]]; then
    mkdir -p $mrms_raw/${vyyyymmdd}

    # Check if file exists on disk; if not, pull it.
    mrms_file="$mrms_proc/${vyyyymmdd}/MergedReflectivityQComposite_00.00_${vyyyy}${vmm}${vdd}-${vhh}0000.grib2"
    #echo "MRMS FILE:${mrms_file}"

    if [[ ! -f "${mrms_file}" ]]; then
      cd $mrms_raw/${vyyyymmdd}

      # Name of MRMS tar file on HPSS
      TarFile="/NCEPPROD/hpssprod/runhistory/rh${vyyyy}/${vyyyy}${vmm}/${vyyyy}${vmm}${vdd}/dcom_prod_ldmdata_obs.tar"
      TarCommand="htar -xvf ${TarFile} \`htar -tf ${TarFile} | egrep \"MergedReflectivityQComposite_00.00_${vyyyy}${vmm}${vdd}-[0-9][0-9][0-9][0-9][0-9][0-9].grib2.gz\" | awk '{print $7}'\`"
      #echo "CALLING: time ${TarCommand}"
      htar -xvf ${TarFile} `htar -tf ${TarFile} | egrep "MergedReflectivityQComposite_00.00_${vyyyy}${vmm}${vdd}-[0-9][0-9][0-9][0-9][0-9][0-9].grib2.gz" | awk '{print $7}'`
      Status=$?

      if [[ ${Status} != 0 ]]; then
        echo "WARNING: Bad return status (${Status}) for date \"${CurDate}\".  Did you forget to run \"module load hpss\"?"
        echo "WARNING: ${TarCommand}"
      else
        if [[ ! -d "$mrms_proc/${vyyyymmdd}" ]]; then
          mkdir -p $mrms_proc/${vyyyymmdd}
        fi
	
        hour=0
        while [[ ${hour} -le 23 ]]; do
          echo "hour=${hour}"
          python /scratch2/BMC/det/jwolff/HIWT/ufs-srweather-app-add-metplus/regional_workflow/scripts/mrms_pull_topofhour.py ${vyyyy}${vmm}${vdd}${hour} ${mrms_proc} ${mrms_raw}
        hour=$((${hour} + 1)) # hourly increment
        done
      fi

    fi

  else
    # Check if file exists on disk; if not, pull it.
    mrms_file="$mrms_proc/${vyyyymmdd}/MergedReflectivityQComposite_00.00_${vyyyy}${vmm}${vdd}-${vhh}0000.grib2"
    #echo "MRMS FILE:${mrms_file}"

    if [[ ! -f "${mrms_file}" ]]; then
      cd $mrms_raw/${vyyyymmdd}

      python /scratch2/BMC/det/jwolff/HIWT/ufs-srweather-app-add-metplus/regional_workflow/scripts/mrms_pull_topofhour.py ${vyyyy}${vmm}${vdd}${vhh} ${mrms_proc} ${mrms_raw}
    fi
  fi

  # Increment to next forecast hour      
  current_fcst=$((${current_fcst} + 1)) # hourly increment
  #echo "Current fcst hr=${current_fcst}"
  fcst_sec=`expr ${current_fcst} \* 3600` # convert forecast lead hour to seconds
  cur_ut=`expr ${start_init_ut} + ${fcst_sec}`
  #echo "Current init UT=${cur_ut}"
  
done
