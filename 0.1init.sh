#!/bin/bash

dir_name=$(pwd)

#hosts
cat $dir_name/ip.txt >> /etc/hosts

#diable firewalld
systemctl disable firewalld
systemctl stop firewalld
systemctl status firewalld

# data
mkdir /data

# disable selinux
getenforce 0
getenforce
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config 

# ulimit
cat >>/etc/security/limits.conf<<EOF
* soft nofile 204800
* hard nofile 204800
* soft nproc 204800
* hard nproc 204800
EOF

#vim
echo "alias vi=vim" >>/etc/profile
echo "alias vi=vim" >>/root/.bashrc

#rpm
mkdir /etc/yum.repos.d/back
mv  /etc/yum.repos.d/* mkdir /etc/yum.repos.d/back/
rpm -ivh /root/Installation/rpm/deltarpm-3.6-3.el7.x86_64.rpm  
rpm -ivh /root/Installation/rpm/python-deltarpm-3.6-3.el7.x86_64.rpm   
rpm -ivh /root/Installation/rpm/createrepo-0.9.9-28.el7.noarch.rpm
/usr/bin/createrepo -v $dir_name/rpm/

cat>/etc/yum.repos.d/seye.repo<<EOF
[seye]
name=seye
baseurl=file://$dir_name/rpm/
enabled=1
gpgcheck=0
EOF

#yum install
#yum install epel-release -y
yum install vim wget curl telnet nmap tcpdump unzip htop -y

#crontab
[ `rpm -qa ntpdate` ] || yum install ntpdate -y

echo "*/50 * * * * /sbin/ntpdate ntp1.aliyun.com" >>/var/spool/cron/root

/sbin/ntpdate ntp1.aliyun.com

hwclock -w
