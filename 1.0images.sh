#!/bin/bash

dir=$(pwd)/images
images=$(ls $dir/seye*)

for i in $images
do
	echo "now is load images [$i] ..."
        docker load <$i
done 

#conf
cp -r images-conf/* /data/

#/data/seye-compute/compute.sh start
#/data/seye-analysis/analysis.sh start
#/data/seye-realtime/realtime.sh start
#/data/seye-data/data.sh start

