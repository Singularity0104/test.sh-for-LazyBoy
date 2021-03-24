#!/bin/bash
BIN_DIR="./bin/"
PBS_DIR="./pbs/"
RUNLOG_DIR="./runlog/"
TIMELOG_DIR="./timelog/"
TEMPLATE="./submit-template.pbs"
OUT_DATA="./outdata.txt"
CONFIG="./config"
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
((id_index++))
done
done
done
echo
echo "Information:"
for((i=0;i<id_index;i++))
do
echo "id: ${id[$i]} ${file_to_id[$i]%.*}"
done
echo
echo "Running..."
all_flag=false
sin_flag=true
until $all_flag
do
sin_flag=true
for((i=0;i<id_index;i++))
do
if ! test -f $RUNLOG_DIR${file_to_id[$i]}
then
sin_flag=false
fi
done
if $sin_flag
then
all_flag=true
fi
sleep 1
done
sleep 1
echo
echo "Extracting Time Information..."
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
