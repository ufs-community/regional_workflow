set -x

cp $UTIL/convert.sh .

./convert.sh filelist03 filelist03_horiz

export file_list=`sort filelist03_horiz`
allfiles="$file_list"

num=1

for namefile in $allfiles
do
echo $namefile
export sizefile=`du -b $namefile | cut -c 1-10`
if [ $sizefile = 3944781588 ] ; then
  echo "enkf file $num is complete"
else
  echo "enkf file $num is incomplete, abort and run 3dvar"
  export HYB_ENS=".false."
  break
fi
let "num=num+1"
done
