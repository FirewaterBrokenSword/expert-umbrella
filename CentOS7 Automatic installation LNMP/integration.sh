#!/bin/sh
Path1=wwww
Path2=simplify
Path3=ht5
IP1=80
IP2=80
IP3=80
HTML1=www.test.com
HTML2=test.com
HTML3=ht5.m.test.com
CURL1=`curl -I -m 2 http://www.test.com/test_info.php  2>/dev/null|egrep "200|302"|wc -l`
CURL2=`curl -I -m 2 http://www.test.com/test_mysql.php 2>/dev/null|egrep "200|302"|wc -l`
nginx(){
cd /application/nginx/conf
rm -f nginx.conf
echo "
vim nginx.conf
worker_processes  1;
events {
    worker_connections  1024;
    }
    http {
        include       mime.types;
        default_type  application/octet-stream;
        sendfile        on;
        keepalive_timeout  65;
        include extra/$(Path1).conf;
        include extra/$(Path2).conf;
        include extra/$(Path3).conf;
        }
" >>nginx.conf
}
function_html(){
mkdir extra && cd extra
echo "
server {
    listen     $IP1;
    server_name  $HTML1;
    location / {
        root   html/$Path1;         
        index  index.php index.html index.htm;
        }
   location ~ .*\.(php|php5)?$ {
   root   html/$Path1;
   fastcgi_pass 127.0.0.1:9000;
   fastcgi_index index.php;
   include fastcgi.conf;
   }
}
" >>$PATH1.conf
echo "
server {
    listen     $IP2;
    server_name  $HTML2;
    location / {
        root   html/$Path2;         
        index  index.html index.htm;
        }
	}
" >>$PATH2.conf
echo "
server {
    listen     $IP3;
    server_name  $HTML3;
    location / {
        root   html/$Path3;         
        index  index.html index.htm;
        }
	}
" >>$PATH3.conf
}

inspect(){
  /application/nginx/sbin/nginx -s reload
  cd /application/nginx/html/$Path1
  
  echo "
  	<?php
    phpinfo();
	?>
  " >>test_info.php

  echo "
  	<?php 
    $link=mysql_connect("localhost","root","12345") or mysql_error(); 
    if($link){
        echo "OK!可以连接"; 
        }
   else{
   echo mysql_error(); 
   }
	?> 
  ">>test_mysql.php
  if [ $CURL1 -eq 1 ];then
  	action "nginx+php"	/bin/true
  	rm -f /application/nginx/html/$Path1/test_info.php
  else
  	action "nginx+php"	/bin/false
  
  fi
  if [ $CURL2 -eq 1 ];then
  	action "mysql+php"	/bin/true
  	rm -f /application/nginx/html/$Path1/test_mysql.php
  else
  	action "mysql+php"	/bin/false
  
  fi
}


read -p "To execute this script, you need to install nginx, mysql, PHP.Are you ready? yes or no "  word
case "$word" in
	[yY]|[yY][eE][sS])
		nginx
		function_html
		inspect
		;;
	[nN]|[nN][oO])
		echo "Byby!"
		;;
		*)
		echo "Invalid Input!"
esac