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


start_n2v() {
iptables -D INPUT -i n2v2_tun -j ACCEPT 2>/dev/null
iptables -D FORWARD -i n2v2_tun -o n2v2_tun -j ACCEPT 2>/dev/null
iptables -D FORWARD -i n2v2_tun -j ACCEPT 2>/dev/null
iptables -t nat -D POSTROUTING -o n2v2_tun -j MASQUERADE 2>/dev/null
killall ntwon
killall -9 ntwon
sleep 3

#清除vnt的虚拟网卡
ifconfig n2v2_tun down && ip tuntap del n2v2_tun mode tun

n2cmd="/usr/bin/ntwon -c $ntwon_keyg -a $ntwon_xuip -d n2v2_tun -l $ntwon_log >/tmp/ntwon.log 2>&1"
echo "$n2cmd" >/tmp/ntwon.CMD 
logger -t "【N2V2智能组网】" "运行${n2cmd}"
eval "$n2cmd" &
sleep 5
if [ ! -z "`pidof ntwon`" ] ; then
 logger -t "n2v2" "启动成功"
	
	n20=n2v2_tun
	routenum=`nvram get ntwon_routenum_x`
	for r in $(seq 1 $routenum)
	do
		i=`expr $r - 1`
		ntwon_route=`nvram get ntwon_route_x$i`
		ntwon_ip=`nvram get ntwon_ip_x$i`
		if [ "$1" = "add" ]; then
			if [ $ntwon_name -ne 0 ]; then
		ip route add $ntwon_route via $ntwon_ip dev $n20
		echo "$n20"
		fi
	else
		ip route add $ntwon_route via $ntwon_ip dev $n20
	fi
	done

#放行vnt防火墙
iptables -I INPUT -i n2v2_tun -j ACCEPT
iptables -I FORWARD -i n2v2_tun -o vnt-tun -j ACCEPT
iptables -I FORWARD -i n2v2_tun -j ACCEPT
iptables -t nat -I POSTROUTING -o n2v2_tun -j MASQUERADE
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
