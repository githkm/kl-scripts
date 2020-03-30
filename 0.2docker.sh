#!/bin/bash
# install docker
#-----------------------------
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache fast	
yum -y install docker-ce
docker -v
systemctl enable docker
systemctl start docker
cat >/etc/docker/daemon.json <<EOF
{
	"registry-mirrors": ["https://6bsrrf2m.mirror.aliyuncs.com"]
}
EOF
systemctl daemon-reload
systemctl restart docker
systemctl status docker


