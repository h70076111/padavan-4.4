#!/bin/sh

/usr/bin/hx-cli --stop
#关闭vnt的防火墙
iptables -D INPUT -i hxsdwan -j ACCEPT 2>/dev/null
iptables -D FORWARD -i hxsdwan -o hxsdwan -j ACCEPT 2>/dev/null
iptables -D FORWARD -i hxsdwan -j ACCEPT 2>/dev/null
iptables -t nat -D POSTROUTING -o hxsdwan -j MASQUERADE 2>/dev/null
killall hx-cli
killall -9 hx-cli
sleep 4

hxcli_enable=$(nvram get hxcli_enable)
echo $hxcli_enable
hxcli_token=$(nvram get hxcli_token)
echo $hxcli_token
hxcli_desname=$(nvram get hxcli_desname)
echo $hxcli_desname
hxcli_ip=$(nvram get hxcli_ip)
echo $hxcli_ip
hxcli_localadd=$(nvram get hxcli_localadd)
echo $hxcli_localadd
hxcli_serverw=$(nvram get hxcli_serverw)
echo $hxcli_serverw
lan_ipaddr=$(nvram get lan_ipaddr) 
echo $lan_ipaddr

user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36'
github_proxys="$(nvram get github_proxy)"
[ -z "$github_proxys" ] && github_proxys=" "
if [ ! -z "$hxcli_port" ] ; then
	if [ ! -z "$(echo $hxcli_port | grep ',' )" ] ; then
		hx_tcp_port="${hxcli_port%%,*}"
	else
		hx_tcp_port="$hxcli_port"
	fi
fi
hxcli_renum=`nvram get hxcli_renum`

hxcli_restart () {
relock="/var/lock/hxcli_restart.lock"
if [ "$1" = "o" ] ; then
	nvram set hxcli_renum="0"
	[ -f $relock ] && rm -f $relock
	return 0
fi
if [ "$1" = "x" ] ; then
	hxcli_renum=${hxcli_renum:-"0"}
	hxcli_renum=`expr $hxcli_renum + 1`
	nvram set hxcli_renum="$hxcli_renum"
	if [ "$hxcli_renum" -gt "3" ] ; then
		I=19
		echo $I > $relock
		logger -t "【HX客户端】" "多次尝试启动失败，等待【"`cat $relock`"分钟】后自动尝试重新启动"
		while [ $I -gt 0 ]; do
			I=$(($I - 1))
			echo $I > $relock
			sleep 60
			[ "$(nvram get hxcli_renum)" = "0" ] && break
   			#[ "$(nvram get hxcli_enable)" = "0" ] && exit 0
			[ $I -lt 0 ] && break
		done
		nvram set hxcli_renum="1"
	fi
	[ -f $relock ] && rm -f $relock
fi
start_hxcli() {

	[ "$hxcli_enable" = "0" ] && exit 1
	logger -t "【HX客户端】" "正在启动hx-cli"
CMD="/usr/bin/hx-cli -k $hxcli_token $hxcli_serverw -d $hxcli_desname --nic hxsdwan"
	routenum=`nvram get hxcli_routenum_x`
	for r in $(seq 1 $routenum)
	do
		i=`expr $r - 1`
		hx_route=`nvram get hxcli_route_x$i`
		hx_ip=`nvram get hxcli_ip_x$i`
		hx_peer="${hx_route},${hx_ip}"
		hx_peer="$(echo $hx_peer | tr -d ' ')"
		CMD="${CMD} -i ${hx_peer}"
	done	
hxclicmd="${CMD} -o $lan_ipaddr/24 --ip $hxcli_ip >/tmp/hx-cli.log 2>&1"   

echo "$hxclicmd" >/tmp/hx-cli.CMD 
logger -t "【宏兴智能组网】" "运行${hxclicmd}"
eval "$hxclicmd" &

sleep 4
if [ ! -z "`pidof hx-cli`" ] ; then
logger -t "异地组网" "启动成功"
#放行vpn防火墙
iptables -I INPUT -i hxsdwan -j ACCEPT
iptables -I FORWARD -i hxsdwan -o hxsdwan -j ACCEPT
iptables -I FORWARD -i hxsdwan -j ACCEPT
iptables -t nat -I POSTROUTING -o hxsdwan -j MASQUERADE
	[ "$hxcli_proxy" = "1" ] && sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1
	if [ ! -z "$hx_tcp_port" ] ; then
		 iptables -I INPUT -p tcp --dport $hx_tcp_port -j ACCEPT
		 ip6tables -I INPUT -p tcp --dport $hx_tcp_port -j ACCEPT
	fi
#开启arp
ifconfig hxcli arp
else
logger -t "异地组网" "启动失败"
fi
logger -t "【宏兴智能组网】" "守护进程启动"
if [ -s /tmp/script/_opt_script_check ]; then
sed -Ei '/【宏兴智能组网】|^$/d' /tmp/script/_opt_script_check
if [ -z "$hxcli_tunname" ] ; then
tunname="hxsdwan"
else
tunname="${hxcli_tunname}"
fi
cat >> "/tmp/script/_opt_script_check" <<-OSC
[ -z "\`pidof hx-cli\`" ] && logger -t "进程守护" "宏兴智能组网 进程掉线" && eval "$scriptfilepath start &" && sed -Ei '/【宏兴智能组网】|^$/d' /tmp/script/_opt_script_check #【宏兴智能组网】
[ -z "\$(iptables -L -n -v | grep '$tunname')" ] && logger -t "进程守护" "hx-cli 防火墙规则失效" && eval "$scriptfilepath start &" && sed -Ei '/【宏兴智能组网】|^$/d' /tmp/script/_opt_script_check #【宏兴智能组网】
OSC
if [ ! -z "$hx_tcp_port" ] ; then
cat >> "/tmp/script/_opt_script_check" <<-OSC
[ -z "\$(iptables -L -n -v | grep '$hx_tcp_port')" ] && logger -t "进程守护" "hx-cli 防火墙规则失效" && eval "$scriptfilepath start &" && sed -Ei '/【宏兴智能组网】|^$/d' /tmp/script/_opt_script_check #【宏兴智能组网】
OSC
fi
fi
}

stop_hx() {
	logger -t "【HX客户端】" "正在关闭hx-cli..."
	sed -Ei '/【HX客户端】|^$/d' /tmp/script/_opt_script_check
	scriptname=$(basename $0)
	/usr/bin/hx-cli --stop >>/tmp/hx-cli.log
	if [ -z "$hxcli_tunname" ] ; then
		tunname="hxsdwan"
	else
		tunname="${hxcli_tunname}"
	fi
	killall hx-cli >/dev/null 2>&1
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

hx_status() {
	if [ ! -z "$hx_process" ] ; then
		hxcpu="$(top -b -n1 | grep -E "$(pidof hx-cli)" 2>/dev/null| grep -v grep | awk '{for (i=1;i<=NF;i++) {if ($i ~ /hx-cli/) break; else cpu=i}} END {print $cpu}')"
		echo -e "\t\t hx-cli 运行状态\n" >$cmdfile
		[ ! -z "$hxcpu" ] && echo "CPU占用 ${hxcpu}% " >>$cmdfile 2>&1
		hxram="$(cat /proc/$(pidof hx-cli | awk '{print $NF}')/status|grep -w VmRSS|awk '{printf "%.2fMB\n", $2/1024}')"
		[ ! -z "$hxram" ] && echo "内存占用 ${hxram}" >>$cmdfile 2>&1
		hxtime=$(cat /tmp/hxcli_time) 
		if [ -n "$hxtime" ] ; then
			time=$(( `date +%s`-hxtime))
			day=$((time/86400))
			[ "$day" = "0" ] && day=''|| day=" $day天"
			time=`date -u -d @${time} +%H小时%M分%S秒`
		fi
		[ ! -z "$time" ] && echo "已运行 ${day}${time}" >>$cmdfile 2>&1
		cmdtart=$(cat /tmp/hx-cli.CMD)
		[ ! -z "$cmdtart" ] && echo "启动参数  $cmdtart" >>$cmdfile 2>&1
		
	else
		echo "$hx_error" >$cmdfile
        fi
	exit 1
}

case $1 in
start)
	start_hxcli &
	;;
stop)
	stop_hx
	;;
restart)
	stop_hx
	start_hxcli &
	;;
*)
	echo "check"
	#exit 0
	;;
esac
