#!/bin/sh

ntwon_enable=$(nvram get ntwon_enable)
ntwon_keyg=$(nvram get ntwon_keyg)
ntwon_xuip=$(nvram get ntwon_xuip)
ntwon_inlan1=$(nvram get ntwon_inlan1)
ntwon_xuip1=$(nvram get ntwon_xuip1)
lan_ipaddr=$(nvram get lan_ipaddr) 
ntwon_log=$(nvram get ntwon_log)
ntwon_log2=$(nvram get ntwon_log2)
ntwon_log3=$(nvram get ntwon_log3)
n2nname=n2v2_tun

start_n2v() {
killall ntwon
killall -9 ntwon
sleep 3

#清除vnt的虚拟网卡

n2cmd="/usr/bin/ntwon -d $n2nname -a $ntwon_xuip -c $ntwon_keyg -l $ntwon_log -r -f 1>/tmp/ntwon.log 2>&1"
echo "$n2cmd" >/tmp/ntwon.CMD 
logger -t "【N2V2智能组网】" "运行${n2cmd}"
eval "$n2cmd" &
sleep 5
#iptables -t nat -A POSTROUTING -j MASQUERADE
#开启ip转发
#echo 1 > /proc/sys/net/ipv4/ip_forward
#sysctl -w net.ipv4.ip_forward=1
#允许n2n流量进入
iptables -A INPUT -i $n2nname -j ACCEPT
iptables -A FORWARD -i $n2nname -o $n2nname -j ACCEPT
iptables -A FORWARD -i $n2nname -j ACCEPT
iptables -t nat -A POSTROUTING -o $n2nname -j MASQUERADE

if [ ! -z "`pidof ntwon`" ] ; then
 logger -t "n2v2" "启动成功"
	
	routenum=`nvram get ntwon_routenum_x`
	for r in $(seq 1 $routenum)
	do
		i=`expr $r - 1`
		ntwon_route=`nvram get ntwon_route_x$i`
		ntwon_ip=`nvram get ntwon_ip_x$i`
		if [ "$1" = "add" ]; then
			if [ $ntwon_name -ne 0 ]; then
		route add -net $ntwon_route gw $ntwon_ip
		echo "$n2n"
		fi
	else
		route add -net $ntwon_route gw $ntwon_ip
	fi
	done
#开启arp
ifconfig n2v2_tun arp
else
logger -t "n2v2" "启动失败"
fi

}

stop_n2v() {
 	
	iptables -D INPUT -i n2v2_tun -j ACCEPT 2>/dev/null
	iptables -D FORWARD -i n2v2_tun -o n2v2_tun -j ACCEPT 2>/dev/null
	iptables -D FORWARD -i n2v2_tun -j ACCEPT 2>/dev/null
	iptables -t nat -D POSTROUTING -o n2v2_tun -j MASQUERADE 2>/dev/null
	
	n2v2_process=$(pidof ntwon)
	if [ -n "$n2v2_process" ]; then
		logger -t "N2组网" "关闭进程..."
		killall ntwon >/dev/null 2>&1
		kill -9 "$n2v2_process" >/dev/null 2>&1
	fi
}

case $1 in
start)
	start_n2v
	;;
stop)
	stop_n2v &
	;;
restart)
	stop_n2v
	start_n2v &
	;;
*)
	echo "check"
	#exit 0
	;;
esac
