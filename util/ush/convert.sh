IFS=''
while read line
do
   echo -n $line
   echo -n " " 
done < $1 > $2           # $1 --> file1.txt contain vertical text as mentioned in the question
echo "$(cat $2)"
