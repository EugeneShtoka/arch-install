#!/bin/zsh

if [[ $(cat /proc/sys/kernel/hostname) != "archlinux-pc" ]]; then
    echo 'Not home pc'
    exit 0
fi

IP_FILE="$HOME/.ip"
CURRENT_IP=$(curl -s http://checkip.amazonaws.com)
if [[ -f $IP_FILE ]]; then
    PREVIOUS_IP=$(cat $IP_FILE)

    if [[ $CURRENT_IP == $PREVIOUS_IP ]]; then
        exit 0
    fi
fi

cd ~/dev/cloudblock/aws/ || exit

sudo sed -i -e "s#^nameserver .*#nameserver 9.9.9.9#" /etc/resolv.conf

sed -i -e "s#^mgmt_cidr = .*#mgmt_cidr = \"$ip/32\"#" aws.tfvars

yes | terraform apply -var-file="aws.tfvars"

sudo sed -i -e "s#^nameserver .*#nameserver 10.0.0.1#" /etc/resolv.conf
