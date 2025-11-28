NETWORK_NAME=$etink_keyg
NETWORK_SECRET=$etink_pass


if [ -z "$USERNAME" ]; then
    USERNAME="$NETWORK_NAME"
fi

EASYTIER_DIR="/tmp/easytier"
EASYTIER_TXT="/etc/storage/easytier.txt"
echo $EASYTIER_TXT

EASYTIER_BIN="/usr/bin/easytier-core"
EASYTIER_CLI_BIN="/usr/bin/easytier-cli"
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

# 检查并添加 INPUT 规则
iptables -D INPUT -i tun0 -j ACCEPT 2>/dev/null
iptables -D FORWARD -i tun0 -o tun0 -j ACCEPT 2>/dev/null
iptables -D FORWARD -i tun0 -j ACCEPT 2>/dev/null
iptables -t nat -D POSTROUTING -o tun0 -j MASQUERADE 2>/dev/null
killall easytier-core
killall -9 easytier-core
sleep 3
#清除vnt的虚拟网卡
ifconfig tun0 down && ip tuntap del tun0 mode tun


# ---------- 检查服务是否已运行 ----------
if pidof easytier-core > /dev/null 2>&1; then
    log "EasyTier 服务已经运行。"
    echo "EasyTier 服务已经运行。"
    exit 0
fi


CMD="$EASYTIER_BIN --network-name $etink_keyg --network-secret $etink_pass -i $etink_xyip -p $etink_log $etink_log2 $etink_log3 --machine-id "$MACHINE_ID" &"

echo $CMD
log $CMD
eval $CMD
sleep 3
# 获取 easytier-cli node 的输出
$EASYTIER_CLI_BIN node
output=$($EASYTIER_CLI_BIN node)

# 提取信息#放行vnt防火墙
iptables -I INPUT -i tun0 -j ACCEPT
iptables -I FORWARD -i tun0 -o vnt-tun0 -j ACCEPT
iptables -I FORWARD -i tun0 -j ACCEPT
iptables -t nat -I POSTROUTING -o tun0 -j MASQUERADE

VirtualIP=$(echo "$output" | awk -F'│' '/Virtual IP/ {gsub(/^[ \t]+|[ \t]+$/,"",$3); print $3}')
Hostname=$(echo "$output" | awk -F'│' '/Hostname/ {gsub(/^[ \t]+|[ \t]+$/,"",$3); print $3}')
PeerID=$(echo "$output" | awk -F'│' '/Peer ID/ {gsub(/^[ \t]+|[ \t]+$/,"",$3); print $3}')

# 以 log 格式输出
echo $output
echo  "Virtual IP: $VirtualIP"
log "Virtual IP: $VirtualIP"
log "Hostname: $Hostname"
log "Peer ID: $PeerID"
