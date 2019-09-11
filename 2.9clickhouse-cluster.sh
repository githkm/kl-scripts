#!/bin/bash

sudo yum -q makecache -y --disablerepo='*' --enablerepo='altinity_clickhouse'
#安装
yum install clickhouse-server clickhouse-common clickhouse-server-common clickhouse-client  -y

systemctl enable clickhouse-server.service

#sed -i s%var/lib%data%g /etc/clickhouse-server/config.xml
#sed -i '72i   <listen_host>::</listen_host>' /etc/clickhouse-server/config.xml

mv /etc/clickhouse-server/config.xml /etc/clickhouse-server/config.xml.bak
cp ./conf/config.xml /etc/clickhouse-server/config.xml 

systemctl start clickhouse-server.service
systemctl status clickhouse-server.service
