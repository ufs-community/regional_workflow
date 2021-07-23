#
#-----------------------------------------------------------------------
#
# Mathematical and physical constants.
#
#-----------------------------------------------------------------------
#

# Pi.
pi_geom="3.14159265358979323846264338327"

# Degrees per radian.
degs_per_radian=$( bc -l <<< "360.0/(2.0*$pi_geom)" )

# Radius of the Earth in meters.
radius_Earth="6371200.0"

