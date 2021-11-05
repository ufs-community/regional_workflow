import os
import numpy as np
from netCDF4 import Dataset

import matplotlib.pyplot as plt
from matplotlib.colors import BoundaryNorm
## Added for logarithmic color scale
import matplotlib.colors as colors

import argparse
import sys

# Parse input arguments
parser = argparse.ArgumentParser()

parser.add_argument("-env", "--use_environment", help="If set, uses environment variables rather than arguments to set necessary variables", action="store_true")

parser.add_argument("-v1", "--var1", help="Variable 1, required unless '-env' flag used", type = str)
parser.add_argument("-v2", "--var2", help="Variable 2, required unless '-env' flag used", type = str)
parser.add_argument("-u1", "--var1_units", help="Variable 1 units (for plot axes)", type = str, default='')
parser.add_argument("-u2", "--var2_units", help="Variable 2 units (for plot axes)", type = str, default='')
parser.add_argument("-s", "--start_date", help="Start date, required unless '-env' flag used", type = str)
parser.add_argument("-e", "--end_date", help="End date, required unless '-env' flag used", type = str)
parser.add_argument("-sfhr", "--start_fhr", help="Start forecast hour, required unless '-env' flag used", type = str)
parser.add_argument("-efhr", "--end_fhr", help="End forecast hour, required unless '-env' flag used", type = str)
parser.add_argument("-ob", "--output_base", help="Base directory for METplus output (where nc file is located)", type = str)
parser.add_argument("-m", "--model", help="'Model name' specified in METplus batch script", type = str)
parser.add_argument("-v1l", "--var1_lev", help="Variable 1 level as defined in grib2 output", type = str, default='L0')
parser.add_argument("-v2l", "--var2_lev", help="Variable 2 level as defined in grib2 output", type = str, default='L0')
args = parser.parse_args()

output_base = None
model = None
if args.use_environment:
   
   var1 = os.environ.get('VAR1')
   var2 = os.environ.get('VAR2')
   start_date = os.environ.get('START_DATE')
   end_date = os.environ.get('END_DATE')
   start_fhr = os.environ.get('FHR_FIRST')
   end_fhr = os.environ.get('FHR_LAST')
   var1_units = os.environ.get('VAR1_UNITS')
   var2_units = os.environ.get('VAR2_UNITS')
   output_base = os.environ.get('OUTPUT_BASE')
   model = os.environ.get('MODEL')
   var1_lev = os.environ.get('VAR1_LEV')
   var2_lev = os.environ.get('VAR2_LEV')
 
   if var1 is None or var2 is None or start_date is None or end_date is None or start_fhr is None or end_fhr is None:
      print("ERROR: If -env flag is set, the following environment variables must be set:")
      print("VAR1, VAR2, START_DATE, END_DATE, START_FHR, END_FHR")
      sys.exit("Exiting")

else:
   if args.var1 is None or args.var2 is None or args.start_date is None or args.end_date is None or args.start_fhr is None or args.end_fhr is None:
      sys.exit("ERROR: Unless -env flag is set, you must provide all arguments")

   var1        = args.var1
   var2        = args.var2
   start_date  = args.start_date
   end_date    = args.end_date
   start_fhr   = args.start_fhr
   end_fhr     = args.end_fhr
   var1_units  = args.var1_units
   var2_units  = args.var2_units
   output_base = args.output_base
   model       = args.model
   var1_lev    = args.var1_lev
   var2_lev    = args.var2_lev

print("var1       = " + var1)
print("var2       = " + var2)
print("start_date = " + start_date)
print("end_date   = " + end_date)
print("start_fhr  = " + start_fhr)
print("end_fhr    = " + end_fhr)
print("var1_units = " + var1_units)
print("var2_units = " + var2_units)



if output_base is None or model is None:
   print("Output base and/or model have not been specified; falling back to METplus default path and filename")
   grid_diag_out = '/scratch2/BMC/fv3lam/RRFS_baseline/expt_dirs/RRFS_baseline_summer/GridDiag/grid_diag_out_FV3_RRFS_v1alpha_3km_summer_' + start_date + '-' + end_date + '_f' + start_fhr + '-' + end_fhr + '.nc'

else:
   grid_diag_out = output_base + '/grid_diag_out_' + model + '_' + var1 + '_' + var1_lev + '-' + var2 + '_' + var2_lev + '_' + start_date + '-' + end_date + '_f' + start_fhr + '-' + end_fhr + '.nc'

print("grid_diag_out = " + grid_diag_out)

#From here on, if we need "APCP" it should be read as "APCP_01"
if var1 == "APCP":
   var1 = "APCP_01"

if var2 == "APCP":
   var2 = "APCP_01"

file_id = Dataset(grid_diag_out, 'r')
hist_str = 'hist_' + var1 + '_' + var1_lev + '_' + var2 + '_' + var2_lev
var1_ctr_str = var1 + '_' + var1_lev + '_mid'
var2_ctr_str = var2 + '_' + var2_lev + '_mid'

hist_var1_var2 = file_id.variables[hist_str][:]
var1_ctr = file_id.variables[var1_ctr_str][:]
var2_ctr = file_id.variables[var2_ctr_str][:]

print("hist_var1_var2 = " + hist_str)
print("var1_ctr       = " + var1_ctr_str)
print("var2_ctr       = " + var2_ctr_str)


file_id.close()
#MergedReflectivityQCComposite_00.50_20191201-010000.grib2
#EchoTop_18_00.50_20191201-000000.grib2
n_total = np.sum(hist_var1_var2)
print(n_total)

var2_mesh, var1_mesh = np.meshgrid(var2_ctr, var1_ctr)
var1_count = np.sum(hist_var1_var2, axis=0)
var2_count = np.sum(hist_var1_var2, axis=1)
#print(var1_count)
#print(var2_count)

var1_mean = np.sum(
    var1_mesh * hist_var1_var2, axis=0) \
    / var1_count


# plot
#data_max=100000
data_max=750000
#cmap = plt.get_cmap('gist_ncar')
cmap = plt.get_cmap('nipy_spectral')
levels = np.linspace(0.0, data_max, 51)
norm = BoundaryNorm(levels, ncolors=cmap.N, clip=True)
##hist = plt.pcolormesh(var2_mesh, var1_mesh,
##    hist_var1_var2,
##    cmap=cmap, norm=norm)
hist_var1_var2_norm = 100*hist_var1_var2 / np.sum(np.sum(hist_var1_var2))
hist = plt.pcolormesh(var2_mesh, var1_mesh,
    hist_var1_var2_norm,
    cmap = cmap, norm = colors.LogNorm(vmin = 0.00001, vmax = 0.05))
##
# hist_var1_var2 / n_total
ax = plt.gca()

## Increased linewidth from 1 to 2
#ax.plot(var2_ctr, var1_mean, linewidth=2)
## Add grid lines 
ax.grid(True, which = 'major', axis = 'both', linestyle = '--', 
        color = (0.5, 0.5, 0.5))
##
ax.set_ylabel(var1 + ' ' + var1_lev + ' (' + var1_units + ')')
ax.set_xlabel(var2 + ' ' + var2_lev + ' (' + var2_units + ')')
#plt.xlim(0, 70)
#plt.ylim(0, 70)
plt.title('MET GridDiag 2D Histogram')
##cbar = plt.colorbar(
##    hist, ticks = np.linspace(0.0, data_max, 11))
cbar = plt.colorbar()
cbar.ax.set_ylabel('Probability (%)')
##

plotname='images/2dhist_' + var1 + '_' + var1_lev + '_' + var2 + '_' + var2_lev + '_' + start_date + '_' + end_date + '_fhr' + start_fhr + '-' + end_fhr
index=0
if os.path.exists(plotname + '.png'):
    while os.path.exists(plotname + '_' + str(index) + '.png'):
        index += 1
    plotname = plotname + '_' + str(index)

plt.savefig(plotname + '.png', dpi=300)
