#! /bin/sh

dom=${1}

username=$USER

# bcnodes = 21 if want to run all simultaneously
# bcnodes = 11 should get in queue faster and still run pretty quickly

if [ $dom == 'conus' ]
then
fcstnodes=76
bcnodes=11
postnodes=2
goespostnodes=15
goespostthrottle=3

elif [ $dom == 'ak' ]
then
fcstnodes=68
bcnodes=11
postnodes=2
goespostnodes=5
goespostthrottle=6

elif [ $dom == 'hi' ]
then
fcstnodes=7
bcnodes=11
postnodes=1
goespostnodes=1
goespostthrottle=9

elif [ $dom == 'pr' ]
then
fcstnodes=10
bcnodes=11
postnodes=1
goespostnodes=1
goespostthrottle=9

elif [ $dom == 'guam' ]
then
fcstnodes=7
bcnodes=11
postnodes=1
goespostnodes=1
goespostthrottle=9


else
echo "Bad entry...domain ${dom} not recognized"
echo "Use one of conus, ak, hi, pr, or guam"

exit

fi

echo username is $username

cat drive_fv3sar_template.xml \
    | sed s:_USER_:${username}:g \
    | sed s:_DOMAIN_:${dom}:g \
    | sed s:_BCNODES_:${bcnodes}:g \
    | sed s:_FCSTNODES_:${fcstnodes}:g \
    | sed s:_POSTNODES_:${postnodes}:g \
    | sed s:_GOESPOSTNODES_:${goespostnodes}:g \
    | sed s:_GOESPOSTTHROTTLE_:${goespostthrottle}:g  > drive_fv3sar_${dom}.xml

