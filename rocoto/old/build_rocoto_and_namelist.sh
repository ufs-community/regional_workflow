#! /bin/sh

dom=${1}
machine=${2}


if [ $# -ne 2 ]
then
echo "need domain (conus, ak, pr, hi)  and machine (theia, dell, ...)"
exit
fi

username=$USER


#############################

### job submission account

# theia
account="fv3-cam"


# WCOSS
# account="HREF-T2O"

#############################

## NOTE:

# bcnodes = 21 if want to run all simultaneously
# bcnodes = 11 should get in queue faster and still run pretty quickly

if [ $dom == 'conus' ]
then

## rocoto items

fcstnodes=76
bcnodes=11
postnodes=2
goespostnodes=15
goespostthrottle=3
sh=00
eh=12

## namelist items

task_layout_x=16
task_layout_y=48
npx=1921
npy=1297
target_lat=38.5
target_lon=-97.5

## model config items

write_groups=3
write_tasks_per_group=48
cen_lon=$target_lon
cen_lat=$target_lat
lon1=-25.0
lat1=-15.0
lon2=25.0
lat2=15.0
dlon=0.02
dlat=0.02



elif [ $dom == 'ak' ]
then

## rocoto items

fcstnodes=68
bcnodes=11
postnodes=2
goespostnodes=5
goespostthrottle=6
sh=06
eh=18

## namelist items

task_layout_x=16
task_layout_y=48
npx=1345
npy=1153
target_lat=61.0
target_lon=-153.0

## model config items

write_groups=2
write_tasks_per_group=24
cen_lon=$target_lon
cen_lat=$target_lat
lon1=-18.0
lat1=-14.79
lon2=18.0
lat2=14.79
dlon=0.03
dlat=0.03

elif [ $dom == 'hi' ]
then

## rocoto items

fcstnodes=7
bcnodes=11
postnodes=1
goespostnodes=1
goespostthrottle=9
sh=00
eh=12

## namelist items

task_layout_x=6
task_layout_y=12
npx=433
npy=361
target_lat=20.0
target_lon=-157.0

## model config items

write_groups=1
write_tasks_per_group=12
cen_lon=$target_lon
cen_lat=$target_lat
lon1=-5.4
lat1=-4.3
lon2=5.4
lat2=4.3
dlon=0.025
dlat=0.025

elif [ $dom == 'pr' ]
then

## rocoto items

fcstnodes=10
bcnodes=11
postnodes=1
goespostnodes=1
goespostthrottle=9
sh=06
eh=18

## namelist items

task_layout_x=6
task_layout_y=18
npx=577
npy=433
target_lat=18.0
target_lon=-69.0

## model config items

write_groups=1
write_tasks_per_group=12
cen_lon=$target_lon
cen_lat=$target_lat
lon1=-7.8
lat1=-5.2
lon2=7.8
lat2=5.2
dlon=0.025
dlat=0.025

elif [ $dom == 'guam' ]
then

## rocoto items

fcstnodes=7
bcnodes=11
ername is Matthew.Pyle
ostnodes=1
goespostnodes=1
goespostthrottle=9
sh=00
eh=12


## namelist items

task_layout_x=6
task_layout_y=12
npx=433
npy=361
target_lat=15.0
target_lon=146.0

## model config items

write_groups=1
write_tasks_per_group=12
cen_lon=$target_lon
cen_lat=$target_lat
lon1=-5.6
lat1=-4.8
lon2=5.6
lat2=4.8
dlon=0.025
dlat=0.025

else

echo "Bad entry...domain ${dom} not recognized"
echo "Use one of conus, ak, hi, pr, or guam"

exit

fi

echo username is $username

if [ ! -e drive_fv3sar_template_${machine}.xml ]
then
echo DO NOT HAVE NEEDED xml template file drive_fv3sar_template_${machine}.xml
echo ERROR EXIT
exit
fi


cat drive_fv3sar_template_${machine}.xml \
    | sed s:_USER_:${username}:g \
    | sed s:_DOMAIN_:${dom}:g \
    | sed s:_SH_:${sh}:g \
    | sed s:_EH_:${eh}:g \
    | sed s:_ACCT_:${account}:g \
    | sed s:_BCNODES_:${bcnodes}:g \
    | sed s:_FCSTNODES_:${fcstnodes}:g \
    | sed s:_POSTNODES_:${postnodes}:g \
    | sed s:_GOESPOSTNODES_:${goespostnodes}:g \
    | sed s:_GOESPOSTTHROTTLE_:${goespostthrottle}:g  > drive_fv3sar_${dom}.xml


cat ../parm/input_sar.nml_template \
    | sed s:_TASK_X_:${task_layout_x}:g \
    | sed s:_TASK_Y_:${task_layout_y}:g \
    | sed s:_NX_:${npx}:g \
    | sed s:_NY_:${npy}:g \
    | sed s:_TARG_LAT_:${target_lat}:g \
    | sed s:_TARG_LON_:${target_lon}:g  > ../parm/input_sar_${dom}.nml
   

cat ../parm/model_configure_sar.tmp_template \
    | sed s:_WG_:${write_groups}:g \
    | sed s:_WTPG_:${write_tasks_per_group}:g \
    | sed s:_CEN_LAT_:${cen_lat}:g \
    | sed s:_CEN_LON_:${cen_lon}:g \
    | sed s:_LON1_:${lon1}:g \
    | sed s:_LAT1_:${lat1}:g \
    | sed s:_LON2_:${lon2}:g \
    | sed s:_LAT2_:${lat2}:g \
    | sed s:_DLON_:${dlon}:g \
    | sed s:_DLAT_:${dlat}:g  > ../parm/model_configure_sar.tmp_${dom}

