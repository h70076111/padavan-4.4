#!/bin/sh

killall gecoac
killall -9 gecoac

/usr/bin/gecoac -p 60650 -f /tmp/ -dbpath /etc/storage/bbn -token 1 -lang zh>/tmp/ac_gecoac.log &

sleep 4
if [ ! -z "`pidof gecoac`" ] ; then
logger -t "集客AC控制器" "启动成功"

else
logger -t "集客AC控制器" "启动失败"
fi
