#/bin/bash
jdk_name=jdk-8u171-linux-x64.tar.gz
src_dir=$(pwd)/app
des_dir=/usr/java

echo "Now is start instll jdk..."
if [ -f $src_dir/$jdk_name ];then
   rm -rf $des_dir
   mkdir -p $des_dir
   tar zxf  $src_dir/$jdk_name -C $des_dir
   ln -s $des_dir/jdk1.8.0_171 $des_dir/jdk
   echo  "export JAVA_HOME=$des_dir/jdk"  >> /etc/profile
   echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
   echo "JAVA install is ok!!"
else
   echo "安装失败,没有java程序包。"
   exit 1	
fi
echo "请执命令:source /etc/profile"
