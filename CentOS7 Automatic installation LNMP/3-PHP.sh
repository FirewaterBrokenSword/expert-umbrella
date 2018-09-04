#!/bin/sh
. /etc/init.d/functions
TMP=/application
Address=/server/script
PATH=/application/php-5.6.37
inspect=`lsof -i :9000|grep php|wc -l`

[ -d $TMP -a -d $Address ]||{ 
	mkdir -p $Address $TMP
}

yum install gcc bison bison-devel zlib-devel libmcrypt-devel mcrypt mhash-devel openssl-devel libxml2-devel libcurl-devel bzip2-devel readline-devel libedit-devel sqlite-devel jemalloc jemalloc-devel libjpeg-devel libpng-devel freetype-devel libxslt libxslt-devel -y
cd $Address
wget http://cn2.php.net/distributions/php-5.6.4.tar.gz
tar zxf php-5.6.4.tar.gz
cd php-5.6.4

./configure \
--prefix=$PATH \
--with-mysql=$TMP/mysql \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-openssl \
--with-iconv-dir=/usr/local/libiconv \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-libxml-dir=/usr \
--enable-xml \
--disable-rpath \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--with-curl \
--enable-mbregex \
--enable-fpm \
--enable-mbstring \
--with-mcrypt \
--with-gd \
--enable-gd-native-ttf \
--with-mhash \
--with-xmlrpc \
--enable-soap \
--enable-short-tags \
--enable-static \
--with-xsl \
--with-fpm-user=www \
--with-fpm-group=www \
--enable-ftp \
--enable-opcache=no

make &&make install
ln -s $PATH $TMP/php

cd $TMP/php/etc/
cp php-fpm.conf.default php-fpm.conf

cd $Address/php-5.6.37/sapi/fpm/ 
cp init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
service php-fpm start

if [ $inspect -gt 0 ];then
	rm -rf $Address/php-5.6.37*
	action "php start" /bin/true
else
	echo "php satrt" /bin/false
fi

