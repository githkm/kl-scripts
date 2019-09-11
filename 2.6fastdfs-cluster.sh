#!/bin/bash
#vserson 5.0.8

src_dir=$(pwd)/fastdfs
des_dir=/usr/local

# init
yum install make cmake gcc gcc-c++ unzip -y

cd $src_dir
rm -rf libfastcommon-master
tar -zxf libfastcommon-master.tar.gz
cd libfastcommon-master
./make.sh
./make.sh install

cd $src_dir
rm -rf FastDFS 
tar xf  FastDFS_v5.08.tar.gz
cd FastDFS
./make.sh
./make.sh install

ll /etc/init.d/fdfs*

ll /usr/bin/fdfs_*

cd $src_dir
#------tracker----------
cp -rf ./tracker.conf  /etc/fdfs/tracker.conf

mkdir -p /data/fastdfs/tracker

#------storage------------
cp -rf ./storage.conf /etc/fdfs/storage.conf 
mkdir -p /data/fastdfs/storage

ln -s /data/fastdfs/storage/data/ /data/fastdfs/storage/data/M00

#-------client-----------
cp -rf ./client.conf /etc/fdfs/client.conf

#测试
#/usr/local/src/test.png 是需要上传文件路径
#/usr/bin/fdfs_upload_file /etc/fdfs/client.conf /usr/local/src/test.png
#Or :
#/usr/bin/fdfs_test /etc/fdfs/client.conf upload client.conf

#---------nginx---------

rm -rf ./fastdfs-nginx-module
tar -xzf fastdfs-nginx-module_v1.16.tar.gz
sed -i s%local/include%include%g ./fastdfs-nginx-module/src/config

yum -y install gcc gcc-c++ make automake autoconf libtool pcre* zlib openssl openssl-devel

rm -rf ./ngx_cache_purge-2.3
tar xf ngx_cache_purge-2.3.tar.gz 

pkill nginx
rm -rf /opt/nginx
tar -zxvf nginx-1.10.0.tar.gz 
cd nginx-1.10.0
./configure --prefix=/opt/nginx --add-module=../fastdfs-nginx-module/src/ --add-module=../ngx_cache_purge-2.3/
make && make install

cd  $src_dir
#cp /usr/local/fastdfs-nginx-module/src/mod_fastdfs.conf      /etc/fdfs/
\cp -rf ./mod_fastdfs.conf /etc/fdfs/mod_fastdfs.conf

\cp -rf ./http.conf /etc/fdfs/
\cp -rf ./mime.types /etc/fdfs/

\cp -rf ./nginx.conf /opt/nginx/conf/nginx.conf

#map
mkdir -p /data/map/
tar xf seye-map.tgz -C /data/map/

#start 
chmod +x /etc/rc.d/rc.local
chmod +x /etc/rc.local
echo '/opt/nginx/sbin/nginx' >>/etc/rc.local

systemctl enable fdfs_trackerd
systemctl start fdfs_trackerd
systemctl enable fdfs_storaged
systemctl start fdfs_storaged

/opt/nginx/sbin/nginx 

#/etc/init.d/fdfs_storaged start
#/etc/init.d/fdfs_trackerd start

