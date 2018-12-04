#!/bin/bash

set -eu

if [ "$(uname)" == "Darwin" ]; then
    echo "Downloading custom providers for MacOS"
    curl -L -o - https://github.com/Comcast/terraform-provider-akamai/releases/download/0.2.2/terraform-provider-akamai-darwin_amd64-0.2.2.tgz | tar xvf - > terraform-provider-akamai
    chmod +x terraform-provider-akamai

    curl -L -o - https://github.com/sl1pm4t/terraform-provider-kubernetes/releases/download/v1.0.7-custom/terraform-provider-kubernetes_darwin-amd64.gz | gunzip > terraform-provider-kubernetes
    chmod +x ./terraform-provider-kubernetes

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Downloading custom providers for linux"
    curl -L -o - https://github.com/sl1pm4t/terraform-provider-kubernetes/releases/download/v1.0.7-custom/terraform-provider-kubernetes_linux-amd64.gz | gunzip > terraform-provider-kubernetes
    chmod +x terraform-provider-kubernetes

    curl -L -o - https://github.com/Comcast/terraform-provider-akamai/releases/download/0.2.2/terraform-provider-akamai-linux_amd64-0.2.2.tgz | tar xvfz - > terraform-provider-akamai
    chmod +x terraform-provider-akamai    
    
fi