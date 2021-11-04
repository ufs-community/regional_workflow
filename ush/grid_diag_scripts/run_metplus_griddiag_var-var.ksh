#!/bin/ksh
#SBATCH --account=fv3lam
#SBATCH --qos=batch
#SBATCH --partition=hera
#SBATCH --nodes=1-1
#SBATCH --tasks-per-node=1
#SBATCH -t 00:30:00
#SBATCH --job-name=metplus_griddiag
#SBATCH -o run_metplus_griddiag_var-var.log

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

MET_INSTALL_DIR=/contrib/met/10.0.0
MET_BIN_EXEC=bin
MET_CONFIG=/scratch2/BMC/fv3lam/RRFS_baseline/ufs-srweather-app/regional_workflow/ush/templates/parm/met
METPLUS_PATH=/contrib/METplus/METplus-4.0.0
METPLUS_CONF=/scratch2/BMC/fv3lam/RRFS_baseline/ufs-srweather-app/regional_workflow/ush/templates/parm/metplus

INPUT_BASE=/scratch2/BMC/fv3lam/RRFS_baseline
OUTPUT_BASE=/scratch2/BMC/fv3lam/RRFS_baseline/expt_dirs/RRFS_baseline_summer/GridDiag

#export VAR1='RETOP'
#export VAR1_OPTS='convert(x) = x * 3.28084 * 0.001; n_bins = 30; range  = [0, 60]; cnt_thresh = [ >15 ];'
#export VAR1_UNITS='kft'
#export VAR1_LEV='L0'

export VAR1='HPBL'
export VAR1_OPTS='n_bins = 260; range  = [0, 2600]; cnt_thresh = [ >15 ];'
export VAR1_UNITS='m'
export VAR1_LEV='L0'

export VAR2='GUST'
export VAR2_OPTS='cnt_thresh = [ >15 ]; n_bins = 40; range  = [0, 40];'
export VAR2_UNITS='m/s'
export VAR2_LEV='L0'

#export VAR2='TMP'
#export VAR2_OPTS='cnt_thresh = [ >15 ]; n_bins = 110; range  = [190, 300];'
#export VAR2_UNITS='K'
#export VAR2_LEV='Z2'

#export VAR2='REFC'
#export VAR2_OPTS='cnt_thresh = [ >15 ]; n_bins = 70; range  = [0, 70];'
#export VAR2_UNITS='dBz'
#export VAR2_LEV='L0'

export MET_INSTALL_DIR
export MET_BIN_EXEC
export METPLUS_PATH
export METPLUS_CONF
export MET_CONFIG

export INPUT_BASE
export OUTPUT_BASE
export OBS_DIR

# Set dates/times to process
INIT_BEG=2019043000 #2019041500
INIT_END=2019043000 #2019053000
INIT_INC=259200 #in seconds (3 days)

FHR_FIRST=12 #00
FHR_LAST=36 #36
FHR_INC=1 #hourly

export INIT_BEG
export INIT_END
export INIT_INC
export FHR_FIRST
export FHR_LAST
export FHR_INC

MODEL=FV3_RRFS_v1alpha_3km_summer
NET=rrfs
export MODEL
export NET

export SEASON=summer

echo "Go to OUTPUT_BASE:${OUTPUT_BASE}"
cd ${OUTPUT_BASE}

${METPLUS_PATH}/ush/master_metplus.py \
  -c ${METPLUS_CONF}/common.conf \
  -c ${METPLUS_CONF}/GridDiag_2vars.conf

cd $SLURM_SUBMIT_DIR

echo `pwd`

export plotting_queue="plot_commands.txt"

cat << EOF >> $plotting_queue
#Completed on `date`
python3 plot_grid_diag_2dhist.py -v1=$VAR1 -v2=$VAR2 -v1l=$VAR1_LEV -v2l=$VAR2_LEV -u1=$VAR1_UNITS -u2=$VAR2_UNITS -s=$INIT_BEG -e=$INIT_END -sfhr=$FHR_FIRST -efhr=$FHR_LAST -ob=$OUTPUT_BASE -m=$MODEL
EOF
echo "METplus complete, plotting commands written to"
echo $plotting_queue
chmod +x $plotting_queue

echo
echo "Done!"
