#!/bin/bash
export JAVA_HOME=/usr/java/jdk
export PATH=$JAVA_HOME/bin:$PATH
rm -rf /usr/zookeeper*
mkdir -pv /data/zookeeper/{data,log}

local_ip=$(ip add |grep inet.*brd|egrep -v 'docker'|awk -F"[ |/]+" 'NR==1 {print$3}')

host_name=`grep "$local_ip " $dir_name/ip.txt |awk  '{print$3}'`
id=${host_name:3:1}

echo $id > /data/zookeeper/data/myid

tar -zxvf ./app/zookeeper-3.4.8.tar.gz -C /usr/
ln -s /usr/zookeeper-3.4.8/ /usr/zookeeper

echo "解压成功，初始化配置文件"
cat >>/usr/zookeeper/conf/zoo.cfg<<EOF
tickTime = 2000
dataDir =  /data/zookeeper/data
dataLogDir = /data/zookeeper/log
tickTime = 2000
clientPort = 2181
initLimit = 5
syncLimit = 2
server.1=db01:12888:13888
server.2=db01:12888:13888
server.3=db03:12888:13888
EOF
echo “添加环境变量”
echo "export ZOOKEEPER_HOME=/usr/zookeeper"  >>/etc/profile
echo 'PATH=$ZOOKEEPER_HOME/bin:$PATH'  >> /etc/profile

echo “ 启动zookeeper”
#/usr/zookeeper/bin/zkServer.sh start
/usr/zookeeper/bin/zkServer.sh status 
pid=`ps -ef | grep  zookeeper | gawk '{ print $2}' | head -n 1`
echo "检查是否启动成功"  
if [ ! -z $pid  ] ; then  
  
 	echo "检测到zookeeper进程，zookeeper启动成功"
else
	echo "zookeeper启动失败"
  
fi

echo "set start boot.."

cat>/etc/init.d/zookeeper<<EOF
#!/bin/bash
#chkconfig:2345 20 90
#description:service zookeeper
export     JAVA_HOME=/usr/java/jdk
export     ZOO_LOG_DIR=/data/zookeeper/log/
ZOOKEEPER_HOME=/usr/zookeeper
case  \$1   in
     start)  su  root  /usr/zookeeper/bin/zkServer.sh  start;;
     start-foreground)  su  root /usr/zookeeper//bin/zkServer.sh   start-foreground;;
     stop)  su  root  /usr/zookeeper/bin/zkServer.sh  stop;;
     status)  su root  /usr/zookeeper/bin/zkServer.sh    status;;
     restart)  su root   /usr/zookeeper/bin/zkServer.sh   restart;;
     upgrade)su root  /usr/zookeeper/bin/zkServer.sh  upgrade;;
     print-cmd)su root  /usr/zookeeper/bin/zkServer.sh  print-cmd;;
     *)  echo "requirestart|start-foreground|stop|status|restart|print-cmd";;
esac
EOF

chmod +x /etc/init.d/zookeeper
chkconfig --add zookeeper
chkconfig --list
chmod +x /etc/rc.d/rc.local
/etc/init.d/zookeeper start
sleep 5
/usr/zookeeper/bin/zkCli.sh <<EOF
create /seye seye
create /seye/compute compute
create /seye/analysis analysis
create /seye/media_server media_server
create /seye/platform platform
create /seye/compute_lock compute_lock
ls /seye
EOF
