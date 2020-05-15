git clone --recursive "https://vlab.ncep.noaa.gov/code-review/EMC_post"
git clone --recursive "https://vlab.ncep.noaa.gov/code-review/UFS_UTILS"

git clone --recursive "https://github.com/NOAA-GSD/NEMSfv3gfs.git" regional_forecast.fd

git clone --recursive ssh://jose.a.aravequia@vlab.ncep.noaa.gov:29418/ProdGSI regional_gsi.fd

git clone --recursive https://jose.a.aravequia@vlab.ncep.noaa.gov/code-review/a/ProdGSI regional_gsi.fd

cd regional_gsi.fd 

git clone --recursive https://jose.a.aravequia@vlab.ncep.noaa.gov/code-review/GSI-fix fix
git clone --recursive https://jose.a.aravequia@vlab.ncep.noaa.gov/code-review/GSI-libsrc libsrc
