cd ~/dev/cloudblock/aws/

ip=$(curl -s http://checkip.amazonaws.com)
echo $ip
#sed -i -e "s#^mgmt_cidr = .*#mgmt_cidr = \"$1/32\"#" aws.tfvars

#terraform apply -var-file="aws.tfvars"
