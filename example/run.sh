#!/usr/bin/env sh

rm terraform.tfstate
rm *.kubeconfig

../install.sh
terraform init
terraform apply
