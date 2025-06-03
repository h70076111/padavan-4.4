#!/bin/sh

killall stdoutsubc
killall -9 stdoutsubc

zero_afykey=$(nvram get zero_afykey) 
echo $zero_afykey
zero_afynen=$(nvram get zero_afynen) 
echo $zero_afynen

/usr/bin/stdoutsubc $zero_afynen --clientid $zero_afykey --qos 1 --script /usr/bin/bafa.sh  &

sleep 4
if [ ! -z "`pidof stdoutsubc`" ] ; then
logger -t "巴法云" "启动成功"

else
logger -t "巴法云" "启动失败"
fi
