cd ~/dev/cloudblock/aws/

ip=$(curl -s http://checkip.amazonaws.com)
sed -i -e "s#^mgmt_cidr = .*#mgmt_cidr = \"$ip/32\"#" aws.tfvars

terraform apply -var-file="aws.tfvars"
