import os
import numpy as np
from netCDF4 import Dataset

import matplotlib.pyplot as plt
from matplotlib.colors import BoundaryNorm
## Added for logarithmic color scale
import matplotlib.colors as colors

#start_date = '2019041800'
#end_date = '2019041800'

start_date=os.environ.get('INIT_BEG')
end_date=os.environ.get('INIT_END')

start_date = '2019041500'
end_date = '2019053000'

start_fhr = '12'
end_fhr = '36'

#grid_diag_out = os.environ.get('OUTPUT_BASE') + 'grid_diag_out_' + os.environ.get('MODEL') + '_' + os.environ.get('VAR1') + '-' + os.environ.get('VAR3') + '_' + start_date + '-' + end_date + '_f' + start_fhr + '-' + end_fhr + '.nc'
#grid_diag_out = '/scratch2/BMC/fv3lam/RRFS_baseline/expt_dirs/RRFS_baseline_summer/GridDiag/grid_diag_out_FV3_RRFS_v1alpha_3km_summer_' + start_date + '-' + end_date + '_f' + start_fhr + '-' + end_fhr + '.nc'
grid_diag_out = '/scratch2/BMC/fv3lam/RRFS_baseline/expt_dirs/RRFS_baseline_summer/GridDiag/grid_diag_out_FV3_RRFS_v1alpha_3km_summer_2019041500-2019053000_f12-36.nc'

file_id = Dataset(grid_diag_out, 'r')
hist_gfs_obs = file_id.variables['hist_RETOP_L0_EchoTop18_Z500'][:]
gfs_ctr = file_id.variables['RETOP_L0_mid'][:]
obs_ctr = file_id.variables['EchoTop18_Z500_mid'][:]
file_id.close()
#MergedReflectivityQCComposite_00.50_20191201-010000.grib2
#EchoTop_18_00.50_20191201-000000.grib2
n_total = np.sum(hist_gfs_obs)
print(n_total)

obs_mesh, gfs_mesh = np.meshgrid(obs_ctr, gfs_ctr)
gfs_count = np.sum(hist_gfs_obs, axis=0)
obs_count = np.sum(hist_gfs_obs, axis=1)
#print(gfs_count)
#print(obs_count)

gfs_mean = np.sum(
    gfs_mesh * hist_gfs_obs, axis=0) \
    / gfs_count


# plot
#data_max=100000
data_max=750000
#cmap = plt.get_cmap('gist_ncar')
cmap = plt.get_cmap('nipy_spectral')
levels = np.linspace(0.0, data_max, 51)
norm = BoundaryNorm(levels, ncolors=cmap.N, clip=True)
##hist = plt.pcolormesh(obs_mesh, gfs_mesh,
##    hist_gfs_obs,
##    cmap=cmap, norm=norm)
hist_gfs_obs_norm = 100*hist_gfs_obs / np.sum(np.sum(hist_gfs_obs))
hist = plt.pcolormesh(obs_mesh, gfs_mesh,
    hist_gfs_obs_norm,
    cmap = cmap, norm = colors.LogNorm(vmin = 0.00001, vmax = 0.05))
##
# hist_gfs_obs / n_total
ax = plt.gca()

## Increased linewidth from 1 to 2
#ax.plot(obs_ctr, gfs_mean, linewidth=2)
## Add grid lines 
ax.grid(True, which = 'major', axis = 'both', linestyle = '--', 
        color = (0.5, 0.5, 0.5))
##
ax.set_xlabel('RETOP obs' + ' ')
ax.set_ylabel('RETOP model' + ' ')
plt.xlim(0, 70)
plt.ylim(0, 70)
plt.title('MET GridDiag 2D Histogram')
##cbar = plt.colorbar(
##    hist, ticks = np.linspace(0.0, data_max, 11))
cbar = plt.colorbar()
cbar.ax.set_ylabel('Probability (%)')
##


#plt.savefig('2dhist_' + varname + start_date + '_' + end_date + '_fhr' + start_fhr + '-' + end_fhr + '.png', dpi=300)
plt.savefig('2dhist_test.png', dpi=300)

