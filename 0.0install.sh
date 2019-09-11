#!/bin/bash

dir_name=$(pwd)
local_ip=$(ip add |grep inet.*brd|egrep -v 'docker'|awk -F"[ |/]+" 'NR==1 {print$3}')

host_name=`grep "$local_ip " $dir_name/ip.txt |awk -F"-" '{print$2}'`
type=${host_name::2}

if [ "$type" == "db" ];then
    commds=$(ls *.sh|egrep -v "0.0|1\.")
else
    commds=$(ls *.sh|egrep -v "0.0|2\.")
fi

echo "Now is tarting install... $dir_name"

>install.log

for i in $commds
do
	echo -e "....................now is install \033[31m$i\033[0m........................"
	# ./$i

	if [ $? -eq 0 ];then
		echo -e "$i install \033[32m success\033[0m !"
		echo "$i install success !" >> install.log
		sleep 1
	else
		echo -e "$i install \033[31mfail\033[0m !"
		break
	fi
	sleep 5
done
