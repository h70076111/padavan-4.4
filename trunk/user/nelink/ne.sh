#!/bin/sh


nelink_keyg=$(nvram get nelink_keyg)
echo $nelink_keyg
nelink_ip=$(nvram get nelink_ip)
echo $nelink_ip
nelink_inlan1=$(nvram get nelink_inlan1)
echo $nelink_inlan1
nelink_xuip1=$(nvram get nelink_xuip1)
echo $nelink_xuip1
lan_ipaddr=$(nvram get lan_ipaddr) 
echo $lan_ipaddr
nelink_log=$(nvram get nelink_log)
echo $nelink_log
nelink_log2=$(nvram get nelink_log2)
echo $nelink_log2
nelink_log3=$(nvram get nelink_log3)
echo $nelink_log3

start_ne() {
/usr/bin/netlink --tun-name nehxkj  -g $nelink_keyg -l 10.26.2.$nelink_ip/24 -p $nelink_log --api-addr $lan_ipaddr:23336 &

sleep 5

if [ ! -z "`pidof netlink`" ] ; then
logger -t "netlink" "启动成功"
#放行netlink防火墙
iptables -I INPUT -i nehxkj -j ACCEPT
iptables -I FORWARD -i nehxkj -o nehxkj -j ACCEPT
iptables -I FORWARD -i nehxkj -j ACCEPT
iptables -t nat -I POSTROUTING -o nehxkj -j MASQUERADE

  routenum=`nvram get ntwon_routenum_x`
	for r in $(seq 1 $routenum)
	do
		i=`expr $r - 1`
		neink_route=`nvram get ntwon_route_x$i`
		neink_ip=`nvram get ntwon_ip_x$i`
		if [ "$1" = "add" ]; then
			if [ $neink_name -ne 0 ]; then
		route add -net $neink_route gw $neink_ip
		echo "$n2n"
		fi
	else
		route add -net $neink_route gw $neink_ip
	fi
	done
#开启arp
ifconfig nehxkj arp
else
logger -t "netlink" "启动失败"
fi

}

stop_ne() {

#关闭nehxkj的防火墙
iptables -D INPUT -i nehxkj -j ACCEPT 2>/dev/null
iptables -D FORWARD -i nehxkj -o nehxkj -j ACCEPT 2>/dev/null
iptables -D FORWARD -i nehxkj -j ACCEPT 2>/dev/null
iptables -t nat -D POSTROUTING -o nehxkj -j MASQUERADE 2>/dev/null
killall netlink
killall -9 netlink
sleep 3
#清除nelink的虚拟网卡
ifconfig nehxkj down && ip tuntap del nehxkj mode tun

}

case $1 in
start)
	start_ne
	;;
stop)
	stop_ne &
	;;
restart)
	stop_ne
	start_ne &
	;;
*)
	echo "check"
	#exit 0
	;;
esac
