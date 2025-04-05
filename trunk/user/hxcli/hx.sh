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
#清除vnt的虚拟网卡
ifconfig hxsdwan down && ip tuntap del hxsdwan mode tun
#启动命令 更多命令去官方查看

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

/usr/bin/hx-cli -k $hxcli_token $hxcli_serverw -d $hxcli_desname --nic hxsdwan -i $hxcli_localadd -o $lan_ipaddr/24 --ip $hxcli_ip &

sleep 4
if [ ! -z "`pidof hx-cli`" ] ; then
logger -t "异地组网" "启动成功"
#放行vpn防火墙
iptables -I INPUT -i hxsdwan -j ACCEPT
iptables -I FORWARD -i hxsdwan -o hxsdwan -j ACCEPT
iptables -I FORWARD -i hxsdwan -j ACCEPT
iptables -t nat -I POSTROUTING -o hxsdwan -j MASQUERADE
#开启arp
ifconfig hxcli arp
else
logger -t "异地组网" "启动失败"
fi
