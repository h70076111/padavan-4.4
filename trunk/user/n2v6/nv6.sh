#!/bin/sh

n2v6_enable=$(nvram get ntwon_enable)
n2v6_keyg=$(nvram get ntwon_keyg)
n2v6_xuip=$(nvram get ntwon_xuip)
n2v6_inlan1=$(nvram get ntwon_inlan1)
ntwon_xuip1=$(nvram get ntwon_xuip1)
lan_ipaddr=$(nvram get lan_ipaddr) 
n2v6_log=$(nvram get ntwon_log)
ntwon_log2=$(nvram get ntwon_log2)
ntwon_log3=$(nvram get ntwon_log3)
nv6name=nv6_tun

start_nv6() {
killall edge6
killall -9 edge6
sleep 3

#清除vnt的虚拟网卡

n6cmd="/usr/bin/ntwon -d $nv6name -c $n2v6_keyg -a $ntwon_xuip -R $n2v6_inlan1 -l $ntwon_log -r >/tmp/n2v6.log 2>&1"
echo "$n6cmd" >/tmp/n2v6.CMD 
logger -t "【N2V6智能组网】" "运行${n6cmd}"
eval "$n6cmd" &
sleep 5
iptables -t nat -A POSTROUTING -j MASQUERADE
#开启ip转发
echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -w net.ipv4.ip_forward=1
#允许n2n流量进入
iptables -A INPUT -i nv6_tun -j ACCEPT
iptables -A FORWARD -i nv6_tun -o nv6_tun -j ACCEPT
iptables -A FORWARD -i nv6_tun -j ACCEPT
iptables -t nat -A POSTROUTING -o nv6_tun -j MASQUERADE

if [ ! -z "`pidof edge6`" ] ; then
 logger -t "n2v6" "启动成功"
#开启arp
ifconfig nv6_tun arp
else
logger -t "n2v6" "启动失败"
fi

}

stop_nv6() {
 	
	iptables -D INPUT -i nv6_tun_tun -j ACCEPT 2>/dev/null
	iptables -D FORWARD -i nv6_tun_tun -o nv6_tun_tun -j ACCEPT 2>/dev/null
	iptables -D FORWARD -i nv6_tun_tun -j ACCEPT 2>/dev/null
	iptables -t nat -D POSTROUTING -o nv6_tun -j MASQUERADE 2>/dev/null
	
	n2v6_process=$(pidof edge6)
	if [ -n "$n2v6_process" ]; then
		logger -t "Nv6组网" "关闭进程..."
		killall edge6 >/dev/null 2>&1
		kill -9 "$n2v6_process" >/dev/null 2>&1
	fi
}

case $1 in
start)
	start_nv6
	;;
stop)
	stop_nv6 &
	;;
restart)
	stop_nv6
	start_nv6 &
	;;
*)
	echo "check"
	#exit 0
	;;
esac
