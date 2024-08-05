#!/bin/sh

IP_FILE="$HOME/.ip"

if [[ $(cat /proc/sys/kernel/hostname) != "archlinux-pc" ]]; then
    echo 'Not home pc'
    exit 0
fi

cd ~/dev/cloudblock/aws/

sudo sed -i -e "s#^nameserver .*#nameserver 9.9.9.9#" /etc/resolv.conf

ip=$(curl -s http://checkip.amazonaws.com)
sed -i -e "s#^mgmt_cidr = .*#mgmt_cidr = \"$ip/32\"#" aws.tfvars

yes | terraform apply -var-file="aws.tfvars"

sudo sed -i -e "s#^nameserver .*#nameserver 10.0.0.1#" /etc/resolv.conf
