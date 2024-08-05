#!/bin/zsh

if [[ $(cat /proc/sys/kernel/hostname) != "archlinux-pc" ]]; then
    echo 'Not home PC'
    exit 0
fi

sudo sed -i -e "s#^nameserver .*#nameserver 9.9.9.9#" /etc/resolv.conf

IP_FILE="$HOME/.ip"
CURRENT_IP=$(curl -s http://checkip.amazonaws.com)
if [[ -f $IP_FILE ]]; then
    PREVIOUS_IP=$(cat $IP_FILE)

    if [[ $CURRENT_IP == $PREVIOUS_IP ]]; then
        echo 'IP unchanged'
        sudo sed -i -e "s#^nameserver .*#nameserver 10.0.0.1#" /etc/resolv.conf
        exit 0
    fi
fi

cd ~/dev/cloudblock/aws/ || exit

sed -i -e "s#^mgmt_cidr = .*#mgmt_cidr = \"$CURRENT_IP/32\"#" aws.tfvars

yes | terraform apply -var-file="aws.tfvars"

sudo sed -i -e "s#^nameserver .*#nameserver 10.0.0.1#" /etc/resolv.conf

echo "Updated ip to $CURRENT_IP"
echo $CURRENT_IP >$IP_FILE
