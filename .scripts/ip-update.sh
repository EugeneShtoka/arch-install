cd ~/dev/cloudblock/aws/

sed -i -e "s#^mgmt_cidr = .*#mgmt_cidr = \"$1/32\"#" aws.tfvars

terraform apply -var-file="aws.tfvars"
