#!/bin/sh
. /etc/init.d/functions
TMP=/application
Address=/server/script
PATH=/application/mysql-5.6.41
PASSWOED=123456
inspect=`lsof -i :3306 |grep mysql|wc -l`

[ -d $TMP -a -d $Address ]||{ 
	mkdir -p $Address $TMP
}

cd $Address
wget https://cdn.mysql.com//Addresss/MySQL-5.6/mysql-5.6.41-linux-glibc2.12-x86_64.tar.gz
tar xf mysql-5.6.41-linux-glibc2.12-i686.tar.gz
mv mysql-5.6.41-linux-glibc2.12-i686 $PATH

chown -R mysql.mysql $PATH
useradd -s /sbin/nologin mysql -M

yum -y install autoconf
cd $PATH
./scripts/mysql_install_db --user=mysql --basedir=$PATH/ --datadir=$PATH/data

cp -a $PATH/bin/* /usr/local/sbin/
cp support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld

sed -i 's#/usr/local/#$TMP/#g' $PATH/bin/mysqld_safe /etc/init.d/mysqld
rm -f /etc/my.cnf

/etc/init.d/mysqld start

ln -s $PATH/ /$TMP/mysql
chkconfig --add mysqld
echo 'export PATH=$TMP/mysql/bin:$PATH' >> /etc/profile

mysqladmin -u root password '$PASSWOED'
mysql -uroot -p$PASSWOED
quit

if [ $inspect -gt 0 ];then
	rm -rf $Address/php-5.6.37*
	action "mysql start" /bin/true
else
	echo "mysql satrt" /bin/false
fi
