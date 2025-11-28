#!/bin/sh

et_error="错误：${et_core} 未运行，请运行成功后执行此操作！"
et_process=$(pidof easytier-core)
etpath=$(dirname "$et_core")
cmdfile="/tmp/easytier_cmd.log"

peer() {
	if [ ! -z "$et_process" ] ; then
		cd $etpath
  		[ ! -x "${etpath}/easytier-cli" ] && chmod +x ${etpath}/easytier-cli
		/usr/bin/easytier-cli peer >$cmdfile 2>&1
	else
		echo "$et_error" >$cmdfile 2>&1
	fi
	exit 1
}

connector() {
	if [ ! -z "$et_process" ] ; then
		cd $etpath
  		[ ! -x "${etpath}/easytier-cli" ] && chmod +x ${etpath}/easytier-cli
		/usr/bin/easytier-cli connector >$cmdfile 2>&1
	else
		echo "$et_error" >$cmdfile 2>&1
	fi
	exit 1
}

stun() {
	if [ ! -z "$et_process" ] ; then
		cd $etpath
  		[ ! -x "${etpath}/easytier-cli" ] && chmod +x ${etpath}/easytier-cli
		/usr/bin/easytier-cli stun >$cmdfile 2>&1
	else
		echo "$et_error" >$cmdfile 2>&1
	fi
	exit 1
}

route() {
	if [ ! -z "$et_process" ] ; then
		cd $etpath
  		[ ! -x "${etpath}/easytier-cli" ] && chmod +x ${etpath}/easytier-cli
		/usr/bin/easytier-cli route >$cmdfile 2>&1
	else
		echo "$et_error" >$cmdfile 2>&1
	fi
	exit 1
}

peer_center() {
	if [ ! -z "$et_process" ] ; then
		cd $etpath
  		[ ! -x "${etpath}/easytier-cli" ] && chmod +x ${etpath}/easytier-cli
		/usr/bin/easytier-cli peer-center >$cmdfile 2>&1
	else
		echo "$et_error" >$cmdfile 2>&1
	fi
	exit 1
}

vpn_portal() {
	if [ ! -z "$et_process" ] ; then
		cd $etpath
  		[ ! -x "${etpath}/easytier-cli" ] && chmod +x ${etpath}/easytier-cli
		/usr/bin/easytier-cli vpn-portal >$cmdfile 2>&1
	else
		echo "$et_error" >$cmdfile 2>&1
	fi
	exit 1
}

node() {
	if [ ! -z "$et_process" ] ; then
		cd $etpath
  		[ ! -x "${etpath}/easytier-cli" ] && chmod +x ${etpath}/easytier-cli
		/usr/bin/easytier-cli node >$cmdfile 2>&1
	else
		echo "$et_error" >$cmdfile 2>&1
	fi
	exit 1
}

proxy() {
	if [ ! -z "$et_process" ] ; then
		cd $etpath
  		[ ! -x "${etpath}/easytier-cli" ] && chmod +x ${etpath}/easytier-cli
		/usr/bin/easytier-cli proxy >$cmdfile 2>&1
	else
		echo "$et_error" >$cmdfile 2>&1
	fi
	exit 1
}

status() {
	if [ ! -z "$et_process" ] ; then
		etcpu="$(top -b -n1 | grep -E "$(pidof easytier-core)" 2>/dev/null| grep -v grep | awk '{for (i=1;i<=NF;i++) {if ($i ~ /easytier-core/) break; else cpu=i}} END {print $cpu}')"
		echo -e "\t\t easytier-core 运行状态\n" >$cmdfile
		[ ! -z "$etcpu" ] && echo "CPU占用 ${etcpu}% " >>$cmdfile 2>&1
		etram="$(cat /proc/$(pidof easytier-core | awk '{print $NF}')/status|grep -w VmRSS|awk '{printf "%.2fMB\n", $2/1024}')"
		[ ! -z "$etram" ] && echo "内存占用 ${etram}" >>$cmdfile 2>&1
		ettime=$(cat /tmp/easytier_time) 
		if [ -n "$ettime" ] ; then
			time=$(( `date +%s`-ettime))
			day=$((time/86400))
			[ "$day" = "0" ] && day=''|| day=" $day天"
			time=`date -u -d @${time} +%H小时%M分%S秒`
		fi
		[ ! -z "$time" ] && echo "已运行 $time" >>$cmdfile 2>&1
		cmdtart=$(cat /tmp/easytier.CMD)
		[ ! -z "$cmdtart" ] && echo "启动参数  $cmdtart" >>$cmdfile 2>&1
		
	else
		echo "$et_error" >$cmdfile
	fi
	exit 1
}

case $1 in
start)
	start_et &
	;;
stop)
	stop_et
	;;
restart)
	stop_et
	start_et &
	;;
update)
	update_et &
	;;
peer)
	peer
	;;
connector)
	connector
	;;
stun)
	stun
	;;
route)
	route
	;;
peer-center)
	peer_center
	;;
vpn-portal)
	vpn_portal
	;;
node)
	node
	;;
proxy)
	proxy
	;;
status)
	status
	;;
*)
	echo "check"
	#exit 0
	;;
esac
