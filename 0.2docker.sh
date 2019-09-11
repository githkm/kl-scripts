#!/bin/bash
# install docker
#wget -O /etc/yum.repos.d/docker-ce.repo  https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

#-----------------------------
yum clean all
yum makecache 
yum install docker-ce -y
docker -v
systemctl enable docker
systemctl start docker
\cp ./images-conf/daemon.json  /etc/docker/
systemctl  daemon-reload
systemctl stop docker
systemctl start docker
systemctl status docker


