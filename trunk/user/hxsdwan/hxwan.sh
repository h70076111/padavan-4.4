#!/bin/sh

hxwan_enable=$(nvram get hxwan_enable)
hxwan_token=$(nvram get hxwan_token)
hxwan_desname=$(nvram get hxwan_desname)
hxwan_ip=$(nvram get hxwan_ip)
hxwan_localadd=$(nvram get hxwanlocaladd)
hxwan_serverw=$(nvram get hxwan_serverw)
lan_ipaddr=$(nvram get lan_ipaddr) 


user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36'
github_proxys="$(nvram get github_proxy)"
[ -z "$github_proxys" ] && github_proxys=" "
if [ ! -z "$hxwan_port" ] ; then
	if [ ! -z "$(echo $hxwan_port | grep ',' )" ] ; then
		hxwan_tcp_port="${hxwan_port%%,*}"
	else
		hxwan_tcp_port="$hxwan_port"
	fi
fi
hxwan_renum=`nvram get hxwan_renum`

hxwan_restart () {
relock="/var/lock/hxwan_restart.lock"
if [ "$1" = "o" ] ; then
	nvram set hxwan_renum="0"
	[ -f $relock ] && rm -f $relock
	return 0
fi
if [ "$1" = "x" ] ; then
	hxwan_renum=${hxwan_renum:-"0"}
	hxwan_renum=`expr $hxwani_renum + 1`
	nvram set hxwan_renum="$hxwan_renum"
	if [ "$hxwan_renum" -gt "3" ] ; then
		I=19
		echo $I > $relock
		logger -t "【HX客户端】" "多次尝试启动失败，等待【"`cat $relock`"分钟】后自动尝试重新启动"
		while [ $I -gt 0 ]; do
			I=$(($I - 1))
			echo $I > $relock
			sleep 60
			[ "$(nvram get hxwan_renum)" = "0" ] && break
   			#[ "$(nvram get hxwan_enable)" = "0" ] && exit 0
			[ $I -lt 0 ] && break
		done
		nvram set hxwan_renum="1"
	fi
	[ -f $relock ] && rm -f $relock
fi

}

start_hxwan() {

	[ "$hxwan_enable" = "0" ] && exit 1
	logger -t "【HX客户端】" "正在启动hx-cli"
CMD="/usr/bin/hxsdwan -n $hxwan_token -s $hxwan_serverw --tun-name hx2_tun --device-id $hxwan_desname"
	routenum=`nvram get hxwan_routenum_x`
	for r in $(seq 1 $routenum)
	do
		i=`expr $r - 1`
		hxwan_route=`nvram get hxwan_route_x$i`
		hxwan_ip=`nvram get hxwan_ip_x$i`
		hxwan_peer="${hxwan_route},${hxwan_ip}"
		hxwan_peer="$(echo $hxwan_peer | tr -d ' ')"
		CMD="${CMD} -i ${hxwan_peer}"
	done	
hxwancmd="${CMD} -o $lan_ipaddr/24 --ip $hxwan_ip >/tmp/hxwan.log 2>&1"   

echo "$hxwancmd" >/tmp/hxwan.CMD 
logger -t "【宏兴智能组网2】" "运行${hxwancmd}"
eval "$hxwancmd" &

sleep 4
if [ ! -z "`pidof hxsdwan`" ] ; then
logger -t "异地组网" "启动成功"
#放行vpn防火墙
iptables -I INPUT -i hx2_tun -j ACCEPT
iptables -I FORWARD -i hx2_tun -o hx2_tun -j ACCEPT
iptables -I FORWARD -i hx2_tun -j ACCEPT
iptables -t nat -I POSTROUTING -o hx2_tun -j MASQUERADE
#开启arp
ifconfig hx2_tun arp
else
logger -t "异地组网" "启动失败"
fi
logger -t "【宏兴智能组网2】" "守护进程启动"
if [ -s /tmp/script/_opt_script_check ]; then
sed -Ei '/【宏兴智能组网2】|^$/d' /tmp/script/_opt_script_check
if [ -z "$hxwan_tunname" ] ; then
tunname="hx2_tun"
else
tunname="${hxwan_tunname}"
fi
cat >> "/tmp/script/_opt_script_check" <<-OSC
[ -z "\`pidof hxsdwan\`" ] && logger -t "进程守护" "宏兴智能组网 进程掉线" && eval "$scriptfilepath start &" && sed -Ei '/【宏兴智能组网2】|^$/d' /tmp/script/_opt_script_check #【宏兴智能组网】
[ -z "\$(iptables -L -n -v | grep '$tunname')" ] && logger -t "进程守护" "hxwan 防火墙规则失效" && eval "$scriptfilepath start &" && sed -Ei '/【宏兴智能组网】|^$/d' /tmp/script/_opt_script_check #【宏兴智能组网】
OSC
if [ ! -z "$hx_tcp_port" ] ; then
cat >> "/tmp/script/_opt_script_check" <<-OSC
[ -z "\$(iptables -L -n -v | grep '$hxwan_tcp_port')" ] && logger -t "进程守护" "hxwan 防火墙规则失效" && eval "$scriptfilepath start &" && sed -Ei '/【宏兴智能组网】|^$/d' /tmp/script/_opt_script_check #【宏兴智能组网】
OSC
fi
fi
}

stop_hxwan() {
	logger -t "【HX客户端】" "正在关闭hxwan..."
	sed -Ei '/【HX客户端】|^$/d' /tmp/script/_opt_script_check
	scriptname=$(basename $0)
	/usr/bin/hx-cli --stop >>/tmp/hxwan.log
	if [ -z "$hxwan_tunname" ] ; then
		tunname="hx2_tun"
	else
		tunname="${hxwan_tunname}"
	fi
	killall hxsdwan >/dev/null 2>&1
	if [ ! -z "$hx_tcp_port" ] ; then
		 iptables -D INPUT -p tcp --dport $hx_tcp_port -j ACCEPT 2>/dev/null
		 ip6tables -D INPUT -p tcp --dport $hx_tcp_port -j ACCEPT 2>/dev/null
	fi
	iptables -D INPUT -i ${tunname} -j ACCEPT 2>/dev/null
	iptables -D FORWARD -i ${tunname} -o ${tunname} -j ACCEPT 2>/dev/null
	iptables -D FORWARD -i ${tunname} -j ACCEPT 2>/dev/null
	iptables -t nat -D POSTROUTING -o ${tunname} -j MASQUERADE 2>/dev/null
	[ ! -z "`pidof hx-cli`" ] && logger -t "【HX客户端】" "进程已关闭!"
	if [ ! -z "$scriptname" ] ; then
		eval $(ps -w | grep "$scriptname" | grep -v $$ | grep -v grep | awk '{print "kill "$1";";}')
		eval $(ps -w | grep "$scriptname" | grep -v $$ | grep -v grep | awk '{print "kill -9 "$1";";}')
	fi
}

hxwan_status() {
	if [ ! -z "$hx_process" ] ; then
		hxwancpu="$(top -b -n1 | grep -E "$(pidof hxsdwan)" 2>/dev/null| grep -v grep | awk '{for (i=1;i<=NF;i++) {if ($i ~ /hxsdwan/) break; else cpu=i}} END {print $cpu}')"
		echo -e "\t\t hxsdwan 运行状态\n" >$cmdfile
		[ ! -z "$hxwancpu" ] && echo "CPU占用 ${hxwancpu}% " >>$cmdfile 2>&1
		hxwanram="$(cat /proc/$(pidof hxsdwan | awk '{print $NF}')/status|grep -w VmRSS|awk '{printf "%.2fMB\n", $2/1024}')"
		[ ! -z "$hxwanram" ] && echo "内存占用 ${hxwanram}" >>$cmdfile 2>&1
		hxwantime=$(cat /tmp/hxwan_time) 
		if [ -n "$hxwantime" ] ; then
			time=$(( `date +%s`-hxwantime))
			day=$((time/86400))
			[ "$day" = "0" ] && day=''|| day=" $day天"
			time=`date -u -d @${time} +%H小时%M分%S秒`
		fi
		[ ! -z "$time" ] && echo "已运行 ${day}${time}" >>$cmdfile 2>&1
		cmdtart=$(cat /tmp/hx-cli.CMD)
		[ ! -z "$cmdtart" ] && echo "启动参数  $cmdtart" >>$cmdfile 2>&1
		
	else
		echo "$hxwan_error" >$cmdfile
        fi
	exit 1
}

case $1 in
start)
	start_hxwan &
	;;
stop)
	stop_hxwan
	;;
restart)
	stop_hxwan
	start_hxwan &
	;;
*)
	echo "check"
	#exit 0
	;;
esac
