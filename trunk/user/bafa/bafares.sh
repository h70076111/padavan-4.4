#!/bin/sh

result=$(echo $1 | grep -o 'on')
if [ ! -z "$result" ] ; then
    logger -t "巴法云" "收到命令 $1"
    reboot &
fi
