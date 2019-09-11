#!/bin/bash
#the scripts is install mysql 5.7.17 on centos 7.4
des_dir=/data
src_dir=$(pwd)/app
user=root
passwd=123
package=./app/mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz
db_name=console_cmcc

yum install make gcc-c++ cmake bison-devel ncurses-devel libaio  libaio-devel perl-Data-Dumper net-tools ncurses-devel openssl-devel  autocake -y
systemctl stop mysqld
yum install  libaio  libaio-devel  -y >/dev/null 2>&1
groupadd mysql
useradd -g mysql -s /sbin/nologin mysql

rm $des_dir/mysql* -rf
echo "now is decompression package..."
tar -zxf $package -C $des_dir
cd $des_dir
ln -s mysql-5.7.17-linux-glibc2.5-x86_64 mysql
ln -s /data/mysql /usr/local/mysql

echo "export PATH=\$PATH:$des_dir/mysql/bin" >> /etc/profile
source /etc/profile

mkdir -p $des_dir/mysql/{data,log,binlogs}
chown -R mysql.mysql ./mysql/

rm -rf /etc/my.cnf.bak

>/etc/my.cnf
cat >/etc/my.cnf<< EOF
[client]
port = 3306
socket = /data/mysql/mysql.sock

[mysqld]
port = 3306
socket = /data/mysql/mysql.sock
pid_file = /data/mysql/mysql.pid
datadir = /data/mysql/data/
default_storage_engine = InnoDB
max_allowed_packet = 512M
max_connections = 2048
open_files_limit = 65535

skip-name-resolve
lower_case_table_names=1

character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
init_connect='SET NAMES utf8mb4'

innodb_buffer_pool_size = 1024M
innodb_log_file_size = 2048M
innodb_file_per_table = 1
innodb_flush_log_at_trx_commit = 0

key_buffer_size = 64M

log-error = /data/mysql/log/mysql_error.log
log-bin = /data/mysql/binlogs/mysql-bin
slow_query_log = 1
slow_query_log_file = /data/mysql/log/mysql_slow_query.log
long_query_time = 5

tmp_table_size = 32M
max_heap_table_size = 32M
query_cache_type = 0
query_cache_size = 0
server-id=1
EOF

#初始化
mysqld --initialize --user=mysql --basedir=$des_dir/mysql --datadir=$des_dir/mysql/data

###设置自启动
cat >/usr/lib/systemd/system/mysqld.service<< EOF
[Unit]
Description=MySQL Server
Documentation=man:mysqld
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target

[Service]
User=mysql
Group=mysql

Type=forking

PIDFile=/data/mysql/mysqld.pid

# Disable service start and stop timeout logic of systemd for mysqld service.
TimeoutSec=0

# Execute pre and post scripts as root
PermissionsStartOnly=true

# Needed to create system tables
#ExecStartPre=/usr/bin/mysqld_pre_systemd

# Start main service
ExecStart=/data/mysql/bin/mysqld --daemonize --pid-file=/data/mysql/mysqld.pid $MYSQLD_OPTS

# Use this to switch malloc implementation
EnvironmentFile=-/etc/sysconfig/mysql

# Sets open_files_limit
LimitNOFILE = 65535

Restart=on-failure
RestartPreventExitStatus=1
PrivateTmp=false
EOF

echo "no is start mysql....."
systemctl daemon-reload
systemctl enable mysqld.service
echo "now set mysqld boot start status is:"
systemctl is-enabled mysqld
systemctl start mysqld.service 

password=`grep 'temporary password' $des_dir/mysql/log/mysql_error.log |awk '{print $NF}'`
echo "root 密码为:$password"

###重置密码
echo "now is change mysql password: $passwd"
mysqladmin -uroot -p"$password" password "$passwd"

cd $src_dir
#alter user 'root'@'localhost' identified by '123456';

mysql -uroot -p$passwd -e"grant all privileges on *.* to root@'%' identified by $passwd;"
mysql -uroot -p$passwd -e"create database $db_name;"
mysql -uroot -p$passwd console_cmcc < $des_dir/db/${db_name}.*sql
mysql -uroot -p$passwd -e"use $db_name;show tables;"

echo "--------mysql install end !-----------"

