#!/bin/bash
 
num=0
str=''
max=100
postfix=('|' '/' '-' '\')
while [ $num -le $max ]
do
	let index=num%4
	printf "[%-50s %-2d%% %c]\r" "$str" "$num" "${postfix[$index]}"
	let num++
	sleep 0.1
	if (($num % 2 == 0)); then
		str+='#'
	fi
done
printf "\n"
