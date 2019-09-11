#!/bin/bash

app_name=ffmpeg-4.1.3.tar.bz2
app_dir=$(pwd)/app
des_dir=/usr/local/ffmpeg

#wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
yum install -y bzip2 -y

cd $app_dir

rm -rf yasm-1.3.0

tar xf yasm-1.3.0.tar.gz

cd yasm-1.3.0

./configure

make && make install

#---------ffmpeg-----------
cd $app_dir

rm -rf ffmpeg-4.1.3

tar xf $app_name

cd ffmpeg-4.1.3

rm -rf $des_dir

./configure --enable-shared --prefix=$des_dir

make && make install


#-----变量----------

cat >> /etc/profile <<EOF
export FFMPEG_HOME=$des_dir
export PATH=\$FFMPEG_HOME/bin:\$PATH
EOF

echo "/usr/local/ffmpeg/lib" >>/etc/ld.so.conf

ldconfig -v

#$des_dir/bin/ffmpeg



