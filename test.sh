#!/bin/bash
BIN_DIR="./bin/"
PBS_DIR="./pbs/"
RUNLOG_DIR="./runlog/"
TIMELOG_DIR="./timelog/"
TEMPLATE="./submit-template.pbs"
OUT_DATA="./outdata.txt"
CONFIG="./config"
NODE_INFO="./node.txt"
test -d $BIN_DIR && rm -rf $BIN_DIR 
mkdir $BIN_DIR
test -d $PBS_DIR && rm -rf $PBS_DIR
mkdir $PBS_DIR
test -d $RUNLOG_DIR && rm -rf $RUNLOG_DIR
mkdir $RUNLOG_DIR
test -d $TIMELOG_DIR && rm -rf $TIMELOG_DIR
mkdir $TIMELOG_DIR
test -f $OUT_DATA && rm $OUT_DATA
touch $OUT_DATA
test -f $NODE_INFO && rm $NODE_INFO
touch $NODE_INFO
id_index=0
tmp=`grep "start_thread_num" $CONFIG`
start_thread_num=${tmp#*:}
tmp=`grep "end_thread_num" $CONFIG`
end_thread_num=${tmp#*:}
tmp=`grep "stride" $CONFIG`
stride=${tmp#*:}
tmp=`grep "args" $CONFIG`
args=${tmp#*:}
tmp=`grep "repeat" $CONFIG`
repeat=${tmp#*:}
for file in *.c *.cpp
do
if [ $file = "*.c" -o $file = "*.cpp" ]
then
continue
fi
fname="${file%.*}"
fnamelist[$c]="$fname"
icc -pthread $file -o $BIN_DIR$fname
echo "Compiled Successfully! $file"
echo "Submitting..."
for((j=start_thread_num;j<=end_thread_num;j=j+stride))
do
for((k=1;k<=repeat;k++))
do
test -d $PBS_DIR$fname/ || mkdir $PBS_DIR$fname/
cp $TEMPLATE $PBS_DIR$fname/$fname-$j-$k.pbs
replace="s/T_NUM/$j/g"
sed -i $replace $PBS_DIR$fname/$fname-$j-$k.pbs
replace="s/TESTFILE_NAME/$fname/g"
sed -i $replace $PBS_DIR$fname/$fname-$j-$k.pbs
replace="s/TESTFILE/.\/bin\/$fname/g"
sed -i $replace $PBS_DIR$fname/$fname-$j-$k.pbs
replace="s/ARGS/$args/g"
sed -i $replace $PBS_DIR$fname/$fname-$j-$k.pbs
replace="s/RUNLOG/.\/runlog\/$fname-$j-$k.log/g"
sed -i $replace $PBS_DIR$fname/$fname-$j-$k.pbs
this_id=`qsub $PBS_DIR$fname/$fname-$j-$k.pbs`
id[id_index]="${this_id%.*}"
file_to_id[id_index]=$fname-$j-$k.log
echo "id: ${id[id_index]} task: ${file_to_id[id_index]%.*}"
echo ${id[id_index]} >> $NODE_INFO
((id_index++))
done
done
done
echo
all_flag=false
sin_flag=true
postfix=('|' '/' '-' '\')
num=0
until $all_flag
do
let now_num=id_index
sin_flag=true
for((i=0;i<id_index;i++))
do
if ! test -f $RUNLOG_DIR${file_to_id[$i]}
then
sin_flag=false
let now_num=now_num-1
fi
done
let index=num%4
printf "Running...%c [%d/%d]\r" "${postfix[$index]}" "$now_num" "$id_index"
let num=num+1
if $sin_flag
then
all_flag=true
fi
sleep 1
done
printf "\n"
sleep 1
echo
echo "Extracting Time Information..."
cat $CONFIG >> $OUT_DATA
echo >> $OUT_DATA
sleep 1
for((i=0;i<id_index;i++))
do
echo ${file_to_id[$i]%.*} >> $OUT_DATA
until find *${id[$i]}* > /dev/null 2>&1
do
sleep 1
done
time_log_name=`find *${id[$i]}*`
echo $time_log_name
grep "real" $time_log_name >> $OUT_DATA
done
mv *.o* $TIMELOG_DIR
echo "Finished!"
