#!/bin/sh

gecoac_enable=$(nvram get gecoac_enable)
gecoac_Save="$(nvram get gecoac_Save)"
gecoac_port="$(nvram get gecoac_port)"
gecoac_bin="$(nvram get gecoac_bin)"
gecoac_renum=`nvram get gecoac_renum`
acname="gecoac"

logg() {
  echo -e "\033[36;33m$(date +'%Y-%m-%d %H:%M:%S'):\033[0m\033[35;1m $1 \033[0m"
  echo "$(date +'%Y-%m-%d %H:%M:%S'): $1" >>/tmp/ac_gecoac.log
  logger -t "【集客AC】" "$1"
}

gecoac_restart () {
relock="/var/lock/gecoac_restart.lock"
if [ "$1" = "o" ] ; then
	nvram set gecoac_renum="0"
	[ -f $relock ] && rm -f $relock
	return 0
fi
if [ "$1" = "x" ] ; then
	gecoac_renum=${gecoac_renum:-"0"}
	gecoac_renum=`expr $gecoac_renum + 1`
	nvram set gecoac_renum="$gecoac_renum"
	if [ "$gecoac_renum" -gt "3" ] ; then
		I=19
		echo $I > $relock
		logg "多次尝试启动失败，等待【"`cat $relock`"分钟】后自动尝试重新启动"
		while [ $I -gt 0 ]; do
			I=$(($I - 1))
			echo $I > $relock
			sleep 60
			[ "$(nvram get gecoac_renum)" = "0" ] && break
   			#[ "$(nvram get gecoac_enable)" = "0" ] && exit 0
			[ $I -lt 0 ] && break
		done
		nvram set gecoac_renum="1"
	fi
	[ -f $relock ] && rm -f $relock
fi

start_gecoac
}

acscriptfilepath=$(cd "$(dirname "$0")"; pwd)/$(acname $0)

gecoac_keep() {
	logg "守护进程启动"
	if [ -s /tmp/script/_opt_script_check ]; then
	sed -Ei '/【集客AC】|^$/d' /tmp/script/_opt_script_check
	cat >> "/tmp/script/_opt_script_check" <<-OSC
	[ -z "\`pidof ${acname}\`" ] && logger -t "进程守护" "集客AC进程掉线" && eval "$acscriptfilepath start &" && sed -Ei '/【集客AC】|^$/d' /tmp/script/_opt_script_check #【集客AC】
 	[ -s /tmp/ac_gecoac.log ] && [ "\$(stat -c %s /tmp/ac_gecoac.log)" -gt 1194304 ] && echo "" > /tmp/ac_gecoac.log & #【集客AC】
	OSC
	fi

}


start_gecoac() {
	[ "$gecoac_enable" = "0" ] && exit 1
	logg "正在启动$gecoac_bin"
 	if [ -f "$gecoac_bin" ] ; then
		[ ! -x "$gecoac_bin" ] && chmod +x $gecoac_bin
  	fi
 	if [ ! -f "$gecoac_bin" ] ; then
		logg "程序${acname}不存在，请下载上传后重试！"
  		exit 1
  	fi
	sed -Ei '/【集客AC】|^$/d' /tmp/script/_opt_script_check
	killall $acname >/dev/null 2>&1
	CMD=""
	if [ -z "$gecoac_Save" ] ; then
		logg "主题为空，无法运行，退出！"
		exit 1
	else
		CMD="$gecoac_Save"
	fi
	gecoaccmd="${gecoac_bin} -p $gecoac_port -f /tmp/ -dbpath $gecoac_Save -token 1 -lang zh>/tmp/ac_gecoac.log 2>&1"
	logg "运行${gecoaccmd}"
	eval "$gecoaccmd" &
	sleep 4
	logg "运行成功！"
	gecoac_restart o
	gecoac_keep
}



stop_gecoac() {
	logg  "正在关闭..."
	sed -Ei '/【集客AC】|^$/d' /tmp/script/_opt_script_check
	acscriptname=$(acgoname $0)
	killall gecoac >/dev/null 2>&1
	[ -z "`pidof gecoac`" ] && logg "进程已关闭!"
	if [ ! -z "$acscriptname" ] ; then
		eval $(ps -w | grep "$acscriptname" | grep -v $$ | grep -v grep | awk '{print "kill "$1";";}')
		eval $(ps -w | grep "$acscriptname" | grep -v $$ | grep -v grep | awk '{print "kill -9 "$1";";}')
	fi
}


case $1 in
start)
	start_gecoac &
	;;
stop)
	stop_gecoac
	;;
restart)
	stop_gecoac
	start_gecoac &
	;;
*)
	echo "check"
	#exit 0
	;;
esac
