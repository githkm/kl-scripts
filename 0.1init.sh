#!/bin/bash
#diable firewalld
systemctl disable firewalld
systemctl stop firewalld
systemctl status firewalld

# disable selinux
setenforce 0
getenforce
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config 

# ulimit
cat >>/etc/security/limits.conf<<EOF
* soft nofile 204800
* hard nofile 204800
* soft nproc 204800
* hard nproc 204800
$(whoami) soft nofile 204800
$(whoami) hard nofile 204800
$(whoami) soft nproc 204800
$(whoami) hard nproc 204800
EOF


#vim
echo "alias vi=vim" >>/etc/profile
echo "alias vi=vim" >>/root/.bashrc

#yum
cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
#wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

#yum install
yum install epel-release bash-completion -y
yum install vim wget axel curl telnet nmap tcpdump unzip htop ntp lrzsz -y

timedatectl set-ntp yes

#crontab
# [ `rpm -qa ntpdate` ] || yum install ntpdate -y

# echo "*/50 * * * * /sbin/ntpdate ntp1.aliyun.com" >>/var/spool/cron/root

hwclock -w
