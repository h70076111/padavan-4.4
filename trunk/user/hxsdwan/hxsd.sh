#!/bin/sh

sd_error="错误：组网未运行，请运行成功后执行此操作！"
sd_process=$(pidof hxsdwan)
sdpath=$(dirname "$HXSDWAN")
cmdfile="/tmp/hxwan_cmd.log"

sd_info() {
	if [ ! -z "$sd_process" ] ; then
		cd $hxpath
		/usr/bin/hxsdwan --info >$cmdfile 2>&1
	else
		echo "$sd_error" >$cmdfile 2>&1
	fi
	exit 1
}

sd_all() {
	if [ ! -z "$sd_process" ] ; then
		cd $sdpath
		/usr/bin/hx-cli --all >$cmdfile 2>&1
	else
		echo "$hx_error" >$cmdfile 2>&1
	fi
	exit 1
}

sd_list() {
	if [ ! -z "$hx_process" ] ; then
		cd $vntpath
		/usr/bin/hx-cli --list >$cmdfile 2>&1
	else
		echo "$hx_error" >$cmdfile 2>&1
	fi
	exit 1
}

sd_route() {
	if [ ! -z "$hx_process" ] ; then
		cd $vntpath
		/usr/bin/hx-cli --route >$cmdfile 2>&1
	else
		echo "$hx_error" >$cmdfile 2>&1
	fi
	exit 1
}

sd_status() {
	if [ ! -z "$hx_process" ] ; then
		hxcpu="$(top -b -n1 | grep -E "$(pidof hx-cli)" 2>/dev/null| grep -v grep | awk '{for (i=1;i<=NF;i++) {if ($i ~ /hx-cli/) break; else cpu=i}} END {print $cpu}')"
		echo -e "\t\t 组网 运行状态\n" >$cmdfile
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
		[ ! -z "$time" ] && echo "已运行 $time" >>$cmdfile 2>&1
		cmdtart=$(cat /tmp/hx-cli.CMD)
		[ ! -z "$cmdtart" ] && echo "启动参数  $cmdtart" >>$cmdfile 2>&1
		
	else
		echo "$hx_error" >$cmdfile
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
update)
	update_hxwan &
	;;
sdinfo)
	sd_info
	;;
sdall)
	sd_all
	;;
sdlist)
	sd_list
	;;
sdroute)
	sd_route
	;;
sdstatus)
	sd_status
	;;
*)
	echo "check"
	#exit 0
	;;
esac
