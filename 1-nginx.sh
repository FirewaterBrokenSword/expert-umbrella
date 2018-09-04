#!/bin/sh
. /etc/init.d/functions
TMP=/application
Address=/server/script
PATH=/application/nginx-1.12.2
inspect=`lsof -i :80 |grep nginx|wc -l`

[ -d $TMP -a -d $Address ]||{ 
	mkdir -p $Address $TMP
}

cd $Address
wget http://nginx.org/Address/nginx-1.12.2.tar.gz
tar xf nginx-1.12.2.tar.gz
cd nginx-1.12.2

useradd -s /sbin/nologin -M www

yum install -y gc gcc gcc-c++ pcre-devel zlib-devel openssl-devel

./configure
--prefix=$PATH \
--user=www \
--group=www \
--with-http_stub_status_module \
--with-http_ssl_module \
--with-http_sub_module \
--with-http_realip_module \
--with-http_image_filter_module  

make && make install
ln -s $PATH $TMP/nginx
/application/nginx/sbin/nginx  &&\

if [ $inspect -gt 0 ];then
	rm -f $Address/nginx-1.12.2*
	action "nginx start" /bin/true
else
	echo "nginx satrt" /bin/false
fi