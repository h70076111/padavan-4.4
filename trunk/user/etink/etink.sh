#!/bin/sh

etink_keyg=$(nvram get etink_keyg)
echo $etink_keyg
etink_pass=$(nvram get etink_pass)
echo $etink_pass
etink_xyip=$(nvram get etink_xyip)
echo $etink_xyip
etink_log=$(nvram get etink_log)
echo $etink_log
etink_log2=$(nvram get etink_log2)
echo $etink_log2
etink_log3=$(nvram get etink_log3)
echo $etink_log3

start_core() {
	[ "$etink_enable" = "0" ] && return 1
	[ "$etweb_enable" = "1" ] && return 1
	logg "正在启动easytier-core"
ARCH="mipsel"
USERNAME=""

SCRIPT_PATH="$(
  cd "$(dirname "$0")"
  pwd
)/$(basename "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

#echo "脚本绝对路径: $SCRIPT_PATH"
#echo "脚本所在目录: $SCRIPT_DIR"
# === 日志输出函数 ===
LOG_TAG="easytier"
log() {
    logger -t "$LOG_TAG" "$1"
}

EASYTIER_DIR="/usr/bin"
EASYTIER_TXT="/etc/storage/easytier.txt"
echo $EASYTIER_TXT

# 下载链接适配

EASYTIER_BIN="$EASYTIER_DIR/easytier-core"
EASYTIER_CLI_BIN="$EASYTIER_DIR/easytier-cli"
# ---------- 生成/读取 machine_id，并初始化 easytier.txt 默认节点 ----------
if [ ! -f "$EASYTIER_TXT" ]; then
    MACHINE_ID=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c32)
    {
        echo "machine_id:$MACHINE_ID"
        echo "#若需要代理本地网络，在下面添加（仅一行生效）:"
        echo "#proxy:192.168.100.0/24 "
        echo "# 可添加更多节点，每行一个，例如："
        echo "node tcp://public.easytier.cn:11010"
        

    } > "$EASYTIER_TXT"
fi

# ---------- 读取 machine_id ----------
MACHINE_ID=$(grep '^machine_id:' "$EASYTIER_TXT" | sed 's/^machine_id://')

# ---------- 读取节点列表 ----------
PEER_PARAMS=""
if [ -f "$EASYTIER_TXT" ]; then
    while IFS= read -r line; do
        case "$line" in
            node\ *)
                NODE_URL=${line#node }
                [ -n "$NODE_URL" ] && PEER_PARAMS="$PEER_PARAMS --peers "$NODE_URL""
                ;;
        esac
    done < "$EASYTIER_TXT"
fi

# ---------- 检查并读取 proxy: 配置 ----------
PROXY_NET=""
if [ -f "$EASYTIER_TXT" ]; then
    PROXY_LINE=$(grep '^proxy:' "$EASYTIER_TXT" | head -n1)
    if [ -n "$PROXY_LINE" ]; then
        # 去掉注释部分
        PROXY_NET=$(echo "$PROXY_LINE" | sed -e 's/^proxy://' -e 's/[[:space:]]*#.*$//')
        PROXY_NET=$(echo "$PROXY_NET" | tr -d ' ')
    fi
fi

if [ -n "$etink_inlan1" ]; then
    PROXY_PARAM="-n $etink_inlan1"
else
    PROXY_PARAM=""
fi

# ---------- Padavan方式开启网关转发 ----------
echo 1 > /proc/sys/net/ipv4/ip_forward

# ---------- 自动添加防火墙转发规则，避免重复 ----------
if [ -n "$PROXY_NET" ]; then
    iptables -C FORWARD -s "$PROXY_NET" -j ACCEPT 2>/dev/null || iptables -A FORWARD -s "$PROXY_NET" -j ACCEPT
    iptables -C FORWARD -d "$PROXY_NET" -j ACCEPT 2>/dev/null || iptables -A FORWARD -d "$PROXY_NET" -j ACCEPT
    log "已放行 $PROXY_NET 的FORWARD转发"
fi




# ---------- 检查服务是否已运行 ----------
if pidof easytier-core > /dev/null 2>&1; then
    log "EasyTier 服务已经运行。"
    echo "EasyTier 服务已经运行。"
    exit 0
fi
CMD="$EASYTIER_BIN --network-name $etink_keyg --network-secret $etink_pass -i $etink_xyip -p $etink_log $etink_log2"

 [ "$(nvram get et_ipv6_enable)" = "1" ] && CMD="${CMD} --disable-ipv6"
 [ "$(nvram get et_use_enable)" = "1" ] && CMD="${CMD} --use-smoltcp"
 [ "$(nvram get et_latency_enable)" = "1" ] && CMD="${CMD} --latency-first"
 [ "$(nvram get et_kcp_enable)" = "1" ] && CMD="${CMD} --enable-kcp-proxy"
 [ "$(nvram get et_quic_enable)" = "1" ] && CMD="${CMD} --enable-quic-proxy"
 [ "$(nvram get et_udp_enable)" = "1" ] && CMD="${CMD} --disable-udp-hole-punching"
 [ "$(nvram get et_device_enable)" = "1" ] && CMD="${CMD} --bind-device"
 [ "$(nvram get et_system_enable)" = "1" ] && CMD="${CMD} --proxy-forward-by-system"
 [ "$(nvram get et_p2p_enable)" = "1" ] && CMD="${CMD} --disable-p2p"
 [ "$(nvram get et_encryption_enable)" = "1" ] && CMD="${CMD} --disable-encryption"
 [ "$(nvram get et_thread_enable)" = "1" ] && CMD="${CMD} --multi-thread" 
 [ "$(nvram get et_dns_enable)" = "1" ] && CMD="${CMD} --accept-dns"
 [ "$(nvram get et_rpc_enable)" = "1" ] && CMD="${CMD} --relay-all-peer-rpc"
 [ "$(nvram get et_mode_enable)" = "1" ] && CMD="${CMD} --private-mode"

CMD="${CMD} --machine-id "$MACHINE_ID" >/tmp/easytier.log 2>&1"

echo $CMD
log $CMD
eval $CMD
sleep 3
# 获取 easytier-cli node 的输出
$EASYTIER_CLI_BIN node
output=$($EASYTIER_CLI_BIN node)
sleep 5
et_restart 
}

start_web() {
	[ "$etweb_enable" = "0" ] && return 1
	[ "$etink_enable" = "1" ] && return 1
	logg "正在启动easytier-core"
ARCH="mipsel"
USERNAME=""

SCRIPT_PATH="$(
  cd "$(dirname "$0")"
  pwd
)/$(basename "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

#echo "脚本绝对路径: $SCRIPT_PATH"
#echo "脚本所在目录: $SCRIPT_DIR"
# === 日志输出函数 ===
LOG_TAG="easytier"
log() {
    logger -t "$LOG_TAG" "$1"
}

EASYTIER_DIR="/usr/bin"
EASYTIER_TXT="/etc/storage/easytier.txt"
echo $EASYTIER_TXT

# 下载链接适配

EASYTIER_BIN="$EASYTIER_DIR/easytier-core"
EASYTIER_CLI_BIN="$EASYTIER_DIR/easytier-cli"
# ---------- 生成/读取 machine_id，并初始化 easytier.txt 默认节点 ----------
if [ ! -f "$EASYTIER_TXT" ]; then
    MACHINE_ID=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c32)
    {
        echo "machine_id:$MACHINE_ID"
        echo "#若需要代理本地网络，在下面添加（仅一行生效）:"
        echo "#proxy:192.168.100.0/24 "
        echo "# 可添加更多节点，每行一个，例如："
        echo "node tcp://public.easytier.cn:11010"
        

    } > "$EASYTIER_TXT"
fi

# ---------- 读取 machine_id ----------
MACHINE_ID=$(grep '^machine_id:' "$EASYTIER_TXT" | sed 's/^machine_id://')

# ---------- 读取节点列表 ----------
PEER_PARAMS=""
if [ -f "$EASYTIER_TXT" ]; then
    while IFS= read -r line; do
        case "$line" in
            node\ *)
                NODE_URL=${line#node }
                [ -n "$NODE_URL" ] && PEER_PARAMS="$PEER_PARAMS --peers "$NODE_URL""
                ;;
        esac
    done < "$EASYTIER_TXT"
fi

# ---------- 检查并读取 proxy: 配置 ----------
PROXY_NET=""
if [ -f "$EASYTIER_TXT" ]; then
    PROXY_LINE=$(grep '^proxy:' "$EASYTIER_TXT" | head -n1)
    if [ -n "$PROXY_LINE" ]; then
        # 去掉注释部分
        PROXY_NET=$(echo "$PROXY_LINE" | sed -e 's/^proxy://' -e 's/[[:space:]]*#.*$//')
        PROXY_NET=$(echo "$PROXY_NET" | tr -d ' ')
    fi
fi

if [ -n "$etink_inlan1" ]; then
    PROXY_PARAM="-n $etink_inlan1"
else
    PROXY_PARAM=""
fi

# ---------- Padavan方式开启网关转发 ----------
echo 1 > /proc/sys/net/ipv4/ip_forward

# ---------- 自动添加防火墙转发规则，避免重复 ----------
if [ -n "$PROXY_NET" ]; then
    iptables -C FORWARD -s "$PROXY_NET" -j ACCEPT 2>/dev/null || iptables -A FORWARD -s "$PROXY_NET" -j ACCEPT
    iptables -C FORWARD -d "$PROXY_NET" -j ACCEPT 2>/dev/null || iptables -A FORWARD -d "$PROXY_NET" -j ACCEPT
    log "已放行 $PROXY_NET 的FORWARD转发"
fi




# ---------- 检查服务是否已运行 ----------
if pidof easytier-core > /dev/null 2>&1; then
    log "EasyTier 服务已经运行。"
    echo "EasyTier 服务已经运行。"
    exit 0
fi
CMD="$EASYTIER_BIN -w $etink_keyg --machine-id "$MACHINE_ID" >/tmp/easytier.log 2>&1"
echo $CMD
log $CMD
eval $CMD
sleep 3
# 获取 easytier-cli node 的输出
$EASYTIER_CLI_BIN node
output=$($EASYTIER_CLI_BIN node)
sleep 5
et_restart 
}

et_rules() {
if [ -z "$et_tunname" ] ; then
		tunname="tun0"
	else
		tunname="${et_tunname}"
	fi
	iptables -I INPUT -i ${tunname} -j ACCEPT
	iptables -I FORWARD -i ${tunname} -o ${tunname} -j ACCEPT
	iptables -I FORWARD -i ${tunname} -j ACCEPT
	iptables -t nat -I POSTROUTING -o ${tunname} -j MASQUERADE
	sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1
	if [ ! -z "$et_ports" ] ; then
		et_portss=$(echo $et_ports | tr -d '\r')
		for et_port in $et_portss ; do
			[ -z "$et_port" ] && continue
			iptables -I INPUT -p tcp --dport "$et_port" -j ACCEPT 
		 	ip6tables -I INPUT -p tcp --dport "$et_port" -j ACCEPT 
		 	iptables -I INPUT -p udp --dport "$et_port" -j ACCEPT
		 	ip6tables -I INPUT -p udp --dport "$et_port" -j ACCEPT 
		done	
	fi
sleep 3
	logg "Core守护进程启动"
	if [ -s /tmp/script/_opt_script_check ]; then
	sed -Ei '/【EasyTier_core】|^$/d' /tmp/script/_opt_script_check
	if [ -z "$et_tunname" ] ; then
		tunname="tun0"
	else
		tunname="${et_tunname}"
	fi
	cat >> "/tmp/script/_opt_script_check" <<-OSC
	[ -z "\`pidof easytier-core\`" ] && logger -t "进程守护" "EasyTier_core 进程掉线" && eval "$scriptfilepath start &" && sed -Ei '/【EasyTier_core】|^$/d' /tmp/script/_opt_script_check #【EasyTier_core】
	[ -z "\$(iptables -L -n -v | grep '$tunname')" ] && logger -t "进程守护" "EasyTier_core 防火墙规则失效" && eval "$scriptfilepath start &" && sed -Ei '/【EasyTier_core】|^$/d' /tmp/script/_opt_script_check #【EasyTier_core】
 	[ -s /tmp/easytier.log ] && [ "\$(stat -c %s /tmp/easytier.log)" -gt 4194304 ] && echo "" > /tmp/easytier.log & #【EasyTier_core】
	OSC
	if [ ! -z "$et_ports" ] ; then
		et_portss=$(echo $et_ports | tr -d '\r')
		for et_port in $et_portss ; do
			[ -z "$et_port" ] && continue
			cat >> "/tmp/script/_opt_script_check" <<-OSC
	[ -z "\$(iptables -L -n -v | grep '$et_port')" ] && logger -t "进程守护" "EasyTier_core 防火墙规则失效" && eval "$scriptfilepath start &" && sed -Ei '/【EasyTier_core】|^$/d' /tmp/script/_opt_script_check #【EasyTier_core】
	OSC
		done	
	fi
	fi

}
start_etink() {
	start_core
	start_web
}

stop_et() {
	logg  "正在关闭..."
	scriptname=$(basename $0)
	if [ -z "$et_tunname" ] ; then
		tunname="tun0"
	else
		tunname="${et_tunname}"
	fi
	killall easytier-core >/dev/null 2>&1
	killall easytier-web >/dev/null 2>&1
	if [ ! -z "$et_ports" ] ; then
		et_portss=$(echo $et_ports | tr -d '\r')
		for et_port in $et_portss ; do
			[ -z "$et_port" ] && continue
			iptables -D INPUT -p tcp --dport "$et_port" -j ACCEPT >/dev/null 2>&1
		 	ip6tables -D INPUT -p tcp --dport "$et_port" -j ACCEPT >/dev/null 2>&1
		 	iptables -D INPUT -p udp --dport "$et_port" -j ACCEPT >/dev/null 2>&1
		 	ip6tables -D INPUT -p udp --dport "$et_port" -j ACCEPT >/dev/null 2>&1
		done
	fi
	iptables -D INPUT -i ${tunname} -j ACCEPT 2>/dev/null
	iptables -D FORWARD -i ${tunname} -o ${tunname} -j ACCEPT 2>/dev/null
	iptables -D FORWARD -i ${tunname} -j ACCEPT 2>/dev/null
	iptables -t nat -D POSTROUTING -o ${tunname} -j MASQUERADE 2>/dev/null
 	iptables -D INPUT -p tcp --dport "$et_web_port" -j ACCEPT >/dev/null 2>&1
	ip6tables -D INPUT -p tcp --dport "$et_web_port" -j ACCEPT >/dev/null 2>&1
	iptables -D INPUT -p udp --dport "$et_web_port" -j ACCEPT >/dev/null 2>&1
	ip6tables -D INPUT -p udp --dport "$et_web_port" -j ACCEPT >/dev/null 2>&1
  	iptables -D INPUT -p tcp --dport "$et_web_api" -j ACCEPT >/dev/null 2>&1
	ip6tables -D INPUT -p tcp --dport "$et_web_api" -j ACCEPT >/dev/null 2>&1
	iptables -D INPUT -p udp --dport "$et_web_api" -j ACCEPT >/dev/null 2>&1
	ip6tables -D INPUT -p udp --dport "$et_web_api" -j ACCEPT >/dev/null 2>&1
	if [ ! -z "$et_html_port" ] ; then
		iptables -D INPUT -p tcp --dport "$et_html_port" -j ACCEPT >/dev/null 2>&1
		ip6tables -D INPUT -p tcp --dport "$et_html_port" -j ACCEPT >/dev/null 2>&1
	fi
	[ -z "`pidof easytier-core`" ] && [ -z "`pidof easytier-web`" ] && logg "进程已关闭!"
	if [ ! -z "$scriptname" ] ; then
		eval $(ps -w | grep "$scriptname" | grep -v $$ | grep -v grep | awk '{print "kill "$1";";}')
		eval $(ps -w | grep "$scriptname" | grep -v $$ | grep -v grep | awk '{print "kill -9 "$1";";}')
	fi
}


case $1 in
start)
	start_etink &
	;;
stop)
	stop_et
	;;
restart)
	stop_et
	start_etink &
	;;
*)
	echo "check"
	#exit 0
	;;
esac
