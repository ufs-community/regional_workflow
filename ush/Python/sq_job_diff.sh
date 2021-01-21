#!/bin/sh
#SBATCH -e /scratch2/BMC/det/jwolff/GST/ufs-srweather-app-gst/regional_workflow/ush/Python/plot_allvars_diff.log
#SBATCH --account=gsd-fv3
#SBATCH --qos=batch
#SBATCH --ntasks=8
#SBATCH --time=0:30:00
#SBATCH --job-name="plot_allvars_diff"

cd /scratch2/BMC/det/jwolff/GST/ufs-srweather-app-gst/regional_workflow/ush/Python
set -x
. /apps/lmod/lmod/init/sh

module purge
module load hpss

############
# Python environment for Jet and Hera
module use -a /contrib/miniconda3/modulefiles
module load miniconda3
conda activate pygraf

############
# Python environment for Orion
############
#module use -a /apps/contrib/miniconda3-noaa-gsl/modulefiles
#module load miniconda3
#conda activate pygraf

############
# Python environment for Gaea
############
#module use -a /apps/contrib/miniconda3-noaa-gsl/modulefiles
#module load miniconda3
#conda activate pygraf

############
# Path to shape files
############
#Hera: /scratch2/NCEPDEV/fv3-cam/Chan-hoo.Jeon/tools/NaturalEarth 
#Jet:
#Orion:
#Gaea: 

python plot_allvars_diff.py 2019061518 6 12 3 /scratch2/BMC/det/jwolff/GST/expt_dirs/test_gst_CONUS_3km_GFSv15p2 /scratch2/BMC/det/jwolff/GST/expt_dirs/test_gst_CONUS_3km_RRFSv1alpha /scratch2/NCEPDEV/fv3-cam/Chan-hoo.Jeon/tools/NaturalEarth
