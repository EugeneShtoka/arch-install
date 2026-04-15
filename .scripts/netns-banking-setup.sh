#!/bin/zsh
NS=direct
IFACE=wlan0

ip netns list | grep -q "^$NS " && exit 0

ip netns add $NS
ip link add veth0 type veth peer name veth1
ip link set veth1 netns $NS
ip addr add 192.168.99.1/24 dev veth0
ip link set veth0 up
ip netns exec $NS ip addr add 192.168.99.2/24 dev veth1
ip netns exec $NS ip link set veth1 up
ip netns exec $NS ip link set lo up
ip netns exec $NS ip route add default via 192.168.99.1
mkdir -p /etc/netns/$NS
echo "nameserver 1.1.1.1" > /etc/netns/$NS/resolv.conf
iptables -t nat -A POSTROUTING -s 192.168.99.0/24 -o $IFACE -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward
