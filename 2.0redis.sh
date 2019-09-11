#!/bin/bash

#load images
dir=$(pwd)/images
images=$(ls $dir/*.tgz |grep -v seye*)

\cp $(pwd)/images-conf/daemon.json.db /etc/docker/daemon.json
systemctl daemon-reload
systemctl restart docker

for i in $images
do
	echo "now is load images [$i] ..."
        docker load <$i
done

docker rm -f redis-server zookeeper kafka

docker run -d -p 6379:6379 --restart=always  --name  redis-server  redis

#docker zk

docker run -d --name=zookeeper --restart=always  -p 1181:2181  wurstmeister/zookeeper

#docker kafka

docker run -d --name kafka  \
--restart=always --publish 9092:9092 \
--link zookeeper \
--env KAFKA_ZOOKEEPER_CONNECT=zookeeper:1181 \
--env KAFKA_ADVERTISED_HOST_NAME=192.168.2.171 \
--env KAFKA_ADVERTISED_PORT=9092 \
--volume /etc/localtime:/etc/localtime wurstmeister/kafka:latest
