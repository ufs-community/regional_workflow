#!/bin/sh
#SBATCH -e /scratch2/BMC/det/jwolff/GST/ufs-srweather-app-gst/regional_workflow/ush/Python/plot_allvars.log
#SBATCH --account=gsd-fv3
#SBATCH --qos=batch
#SBATCH --ntasks=4
#SBATCH --time=0:20:00
#SBATCH --job-name="plot_allvars"

cd /scratch2/BMC/det/jwolff/GST/ufs-srweather-app/regional_workflow/ush/Python
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
#Hera: /scratch2/NCEPDEV/fv3-cam/Chan-hoo.Jeon/tools/NaturalEarth/ 
#Jet: 
#Orion: /home/chjeon/tools/NaturalEarth/
#Gaea: 

python plot_allvars.py 2019061500 6 48 6 /scratch2/BMC/det/jwolff/GST/expt_dirs/test_CONUS_25km_GFSv15p2 /scratch2/NCEPDEV/fv3-cam/Chan-hoo.Jeon/tools/NaturalEarth
#python plot_allvars.py 2019061518 6 12 3 /scratch2/BMC/det/jwolff/GST/expt_dirs/test_CONUS_3km_GFSv15p2 /scratch2/NCEPDEV/fv3-cam/Chan-hoo.Jeon/tools/NaturalEarth
#python plot_allvars.py 2019061518 6 12 3 /scratch2/BMC/det/jwolff/GST/expt_dirs/test_CONUS_3km_GFSv15p2 /scratch2/NCEPDEV/fv3-cam/Chan-hoo.Jeon/tools/NaturalEarth

