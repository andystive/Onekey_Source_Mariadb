#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

################### 源码包安装mariadb #####################################

'####################################################################'
'##   本脚本为自动部署Mariadb  支持系统为centos7  软件为源码包安装     ##'
'####################################################################'

# 更新、安装依赖
apt-get update
apt-get install cmake -y
apt-get install g++ openssl libssl-dev libncurses5-dev libboost-dev bison -y

# 下载源码包并解压
cd /usr/local/src
wget -c http://mirrors.neusoft.edu.cn/mariadb//mariadb-10.3.13/source/mariadb-10.3.13.tar.gz
tar -xzvf mariadb-10.3.13.tar.gz

# 切换到源码文件夹进行编译安装
cd mariadb-10.3.13
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_DATADIR=/usr/local/mysql/data \
-DSYSCONFDIR=/etc \
-DWITHOUT_TOKUDB=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STPRAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWIYH_READLINE=1 \
-DWIYH_SSL=system \
-DVITH_ZLIB=system \
-DWITH_LOBWRAP=0 \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci
if [ $? -eq 0 ]; then
	make && make install
	echo "Mariadb 安装成功！"
else
	echo "Mariadb 安装失败，请检查！"
	read -p "Press Enter to continue."
fi

# 创建mysql用户组和用户名
groupadd mysql
useradd -g mysql -s /sbin/nologin mysql

# 修改mysql文件夹属主
chown -R mysql:mysql /usr/local/mysql

# 复制mysql启动文件到/etc/init.d目录
cp /usr/local/mysql/support-files/mysql.server  /etc/init.d/mysqld

# 删除可能之前存在的mysql配置文件
rm -f /etc/my.cnf

#初始化MySQL数据库
/usr/local/mysql/scripts/mysql_install_db --user=mysql --datadir=/usr/local/mysql/data

#启动mysql服务
/etc/init.d/mysqld start

#执行MySQL安全配置向导
echo 1、为root用户设置密码
echo 2、删除匿名账号
echo 3、取消root用户远程登录
echo 4、删除test库和对test库的访问权限
echo 5、刷新授权表使修改生效
/usr/local/mysql/bin/mysql_secure_installation