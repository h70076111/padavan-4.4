#!/bin/sh


#关闭nehxkj的防火墙
iptables -D INPUT -i nehxkj -j ACCEPT 2>/dev/null
iptables -D FORWARD -i nehxkj -o nehxkj -j ACCEPT 2>/dev/null
iptables -D FORWARD -i nehxkj -j ACCEPT 2>/dev/null
iptables -t nat -D POSTROUTING -o nehxkj -j MASQUERADE 2>/dev/null
killall netlink
killall -9 netlink
sleep 5
#清除nelink的虚拟网卡
ifconfig nehxkj down && ip tuntap del nehxkj mode tun

nelink_keyg=$(nvram get nelink_keyg)
echo $nelink_keyg
nelink_ip=$(nvram get nelink_ip)
echo $nelink_ip
nelink_inlan1=$(nvram get nelink_inlan1)
echo $nelink_inlan1
nelink_xuip1=$(nvram get nelink_xuip1)
echo $nelink_xuip1
nelink_inlan2=$(nvram get nelink_inlan2)
echo $netink_inlan2
nelink_xuip2=$(nvram get nelink_xuip2)
echo $nelink_xuip2
nelink_log=$(nvram get nelink_log)
echo $nelink_log

/usr/bin/netlink --tun-name nehxkj  -g $nelink_keyg -l 10.26.2.$nelink_ip/24 -p tcp://107.172.30.239:23333 &

sleep 5

route add -net $nelink_inlan1/24 gw $nelink_xuip1
$nelink_log route add -net $nelink_inlan2/24 gw $nelink_xuip2

if [ ! -z "`pidof netlink`" ] ; then
logger -t "netlink" "启动成功"
#放行netlink防火墙
iptables -I INPUT -i nehxkj -j ACCEPT
iptables -I FORWARD -i nehxkj -o nehxkj -j ACCEPT
iptables -I FORWARD -i nehxkj -j ACCEPT
iptables -t nat -I POSTROUTING -o nehxkj -j MASQUERADE

#开启arp
ifconfig nehxkj arp
else
logger -t "netlink" "启动失败"
fi
