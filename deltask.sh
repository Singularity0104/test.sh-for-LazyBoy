#!/bin/bash
NODE_INFO="./node.txt"
if test -f $NODE_INFO
then
for line in `cat $NODE_INFO`
do
qdel $line
rm *$line*
done
echo "Finished!"
else
echo "No Nodes Information"
fi