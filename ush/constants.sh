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

#
#-----------------------------------------------------------------------
#
# Character (in bash) used in a string to reference the value stored in 
# a variable.  This is the dollar sign.  For example, if the string is
#
#   "Hello, my name is $NAME."
#
# then the dollar sign indicates that $NAME is a reference to the contents
# of the variable NAME.
#
#-----------------------------------------------------------------------
#
VARVALUE_REF_CHAR="\$"

