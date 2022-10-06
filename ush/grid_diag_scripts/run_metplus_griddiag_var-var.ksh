#!/bin/ksh
#SBATCH --account=fv3lam
#SBATCH --qos=batch
#SBATCH --partition=hera
#SBATCH --nodes=1-1
#SBATCH --tasks-per-node=1
#SBATCH -t 01:30:00
#SBATCH --job-name=metplus_griddiag
#SBATCH -o log.run_metplus_griddiag_var-var

#################################
# How to use this script
#################################

# This script will run MET's GridDiag tool to create statistics comparing
# two variables within the model output. Specifically this script has been
# used, in conjunction with the python plotting script plot_grid_diag_2dhist.py,
# to create 2d histogram plots for these two variables for the given period
#
# Some specific variables need to be set for each model variable you wish to
# analyze/compare. 
# The settings needed for each variable are described as follows:
# 
# VAR1, VAR2: The name of the variables as defined in the GRIB2 model output
# VAR1_OPTS, VAR2_OPTS: Options for modifying and binning each variable in MET;
#                       see the MET config file for details
# VAR1_UNITS, VAR2_UNITS: [optional] The units of each variable; used for plotting only
# VAR1_LEV, VAR2_LEV: The vertical level of each variable you wish to plot; see the MET
#                     users guide for more details:
# https://met.readthedocs.io/en/main_v10.0/Users_Guide/config_options.html#settings-common-to-multiple-tools


# Once this script is run, it will create a MET GridDiag output file (.nc)
# in the ${OUTPUT_BASE} directory. MET will be run according to the settings
# in the MET config file ${METPLUS_CONF}/GridDiag_2vars.conf
#
# In addition, when this script finishes, it will write the proper plotting
# commands in the file `plot_commands.txt`. These commands can be copy-pasted,
# or the file can be run as a shell script (provided the correct python packages
# are loaded; you will need to activate the "pygraf" conda module:
#
# module use -a /contrib/miniconda3/modulefiles
# module load miniconda3
# conda activate pygraf
#
# As a side note: the reason the plotting commands are not included in this script
# is due to Hera-specific limitations; python scripts using certain graphics
# packages will not run on Hera compute nodes for some reason.

# Set up environment on Hera 
module purge
module use -a /contrib/anaconda/modulefiles
module load intel/18.0.5.274
module load anaconda/latest
module use -a /contrib/met/modulefiles/
module load met/10.0.0
module use /contrib/METplus/modulefiles
module load metplus/4.0.0

# Set paths

SRW_DIR=/scratch2/BMC/fv3lam/kavulich/RRFS_baseline/update_regional_workflow_branch/ufs-srweather-app/
export MET_INSTALL_DIR=/contrib/met/10.0.0
export MET_BIN_EXEC=bin
export MET_CONFIG=${SRW_DIR}/regional_workflow/ush/templates/parm/met
export METPLUS_PATH=/contrib/METplus/METplus-4.0.0
export METPLUS_CONF=${SRW_DIR}/regional_workflow/ush/templates/parm/metplus

export INPUT_BASE=/scratch1/BMC/hmtb/beck/ens_design_RRFS
export OUTPUT_BASE=`pwd`/GridDiag

export VAR1='RETOP'
export VAR1_OPTS='censor_thresh = [<=-9.84252,eq-3.28084]; censor_val = [-9999,-16.4042]; convert(x) = x * 3.28084 * 0.001; n_bins = 60; range  = [0, 60]; cnt_thresh = [ >0 ];'
export VAR1_UNITS='kft'
export VAR1_LEV='L0'

#export VAR1='TMP'
#export VAR1_OPTS='n_bins = 150; range  = [190, 340];'
#export VAR1_UNITS='K'
#export VAR1_LEV='Z2'

#export VAR1='DPT'
#export VAR1_OPTS='n_bins = 60; range  = [240, 300];'
#export VAR1_UNITS='K'
#export VAR1_LEV='Z2'

#export VAR1='GUST'
#export VAR1_OPTS='n_bins = 40; range  = [0, 40];'
#export VAR1_UNITS='m/s'
#export VAR1_LEV='L0'

#export VAR1='PRES'
#export VAR1_OPTS='convert(x) = x * 0.01; n_bins = 90; range  = [600, 1050];'
#export VAR1_UNITS='hPa'
#export VAR1_LEV='L0'

#export VAR2='TMP'
#export VAR2_OPTS='n_bins = 70; range  = [220, 290];'
#export VAR2_UNITS='K'
#export VAR2_LEV='P500'

#export VAR1='TMP'
#export VAR1_OPTS='n_bins = 70; range  = [230, 300];'
#export VAR1_UNITS='K'
#export VAR1_LEV='P700'

#export VAR2='TMP'
#export VAR2_OPTS='n_bins = 70; range  = [240, 310];'
#export VAR2_UNITS='K'
#export VAR2_LEV='P850'

#export VAR1='TMP'
#export VAR1_OPTS='n_bins = 80; range  = [240, 320];'
#export VAR1_UNITS='K'
#export VAR1_LEV='P925'

#export VAR1='TMP'
#export VAR1_OPTS='n_bins = 90; range  = [240, 330];'
#export VAR1_UNITS='K'
#export VAR1_LEV='P1000'

#export VAR1='APCP'
#export VAR1_OPTS='n_bins = 100; range  = [0, 250];'
#export VAR1_UNITS='kg/m^2'
#export VAR1_LEV='L0'

#export VAR2='TCDC'
#export VAR2_OPTS='n_bins = 100; range  = [0, 100];'
#export VAR2_UNITS='kg/m^2'
#export VAR2_LEV='L0'

#export VAR1='HPBL'
#export VAR1_OPTS='n_bins = 500; range  = [0, 5000];'
#export VAR1_UNITS='m'
#export VAR1_LEV='L0'

#export VAR1='CAPE'
#export VAR1_OPTS='n_bins = 500; range  = [0, 5000];'
#export VAR1_UNITS='kJ/kg'
#export VAR1_LEV='L0'

#export VAR1='SNOD'
#export VAR1_OPTS='n_bins = 100; range  = [0, 5];'
#export VAR1_UNITS='m'
#export VAR1_LEV='L0'

#export VAR2='USWRF'
#export VAR2_OPTS='n_bins = 100; range  = [0, 1000];'
#export VAR2_UNITS='W/m^2'
#export VAR2_LEV='L0'

#export VAR2='DSWRF'
#export VAR2_OPTS='n_bins = 120; range  = [0, 1200];'
#export VAR2_UNITS='W/m^2'
#export VAR2_LEV='L0'

export VAR2='REFC'
export VAR2_OPTS='censor_thresh = [eq-999, <-20]; censor_val = [-9999, -20]; cnt_thresh = [ >15 ]; n_bins = 80; range  = [0, 80];'
export VAR2_UNITS='dBz'
export VAR2_LEV='L0'

# Set dates/times to process
export INIT_BEG=2021051900
export INIT_END=2021053000
export INIT_INC=86400 #in seconds (3 days)

export FHR_FIRST=12 #00
export FHR_LAST=36 #36
export FHR_INC=1 #hourly

MODEL=test_run
NET=RRFSE_CONUS
export MODEL
export NET

export SEASON=summer

mkdir ${OUTPUT_BASE}
echo "Go to OUTPUT_BASE:${OUTPUT_BASE}"
cd ${OUTPUT_BASE}

${METPLUS_PATH}/ush/master_metplus.py \
  -c ${METPLUS_CONF}/common.conf \
  -c ${METPLUS_CONF}/GridDiag_2vars.conf

retVal=$?

cd $SLURM_SUBMIT_DIR

if [ $retVal -eq 0 ]; then
  export plotting_queue="plot_commands.txt"

  cat << EOF >> $plotting_queue
#Completed on `date`
python3 plot_grid_diag_2dhist.py -v1=$VAR1 -v2=$VAR2 -v1l=$VAR1_LEV -v2l=$VAR2_LEV -u1=$VAR1_UNITS -u2=$VAR2_UNITS -s=$INIT_BEG -e=$INIT_END -sfhr=$FHR_FIRST -efhr=$FHR_LAST -ob=$OUTPUT_BASE -m=$MODEL
EOF
  echo "METplus complete, plotting commands written to"
  echo $plotting_queue
  chmod +x $plotting_queue
else
  touch FAIL_${VAR1}${VAR1_LEV}_${VAR2}${VAR2_LEV}
  echo METplus failed, nothing to plot
fi

echo
echo "Done!"
