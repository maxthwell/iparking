#!/bin/bash

case "$1" in
start)
/opt/openresty/nginx/sbin/nginx -p `pwd`
;;
stop)
/opt/openresty/nginx/sbin/nginx -p `pwd` -s quit
;;
restart)
/opt/openresty/nginx/sbin/nginx -p `pwd` -s quit && /opt/openresty/nginx/sbin/nginx -p `pwd`
;;
reload)
/opt/openresty/nginx/sbin/nginx -p `pwd` -s reload
;;
clean)
/opt/openresty/nginx/sbin/nginx -p `pwd` -s reopen
;;
esac

