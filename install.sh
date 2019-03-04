#!/bin/bash

set -eu

if [ "$(uname)" == "Darwin" ]; then
    echo "Downloading custom providers for MacOS"
    curl -L -o terraform-provider-kubernetes.zip https://github.com/sl1pm4t/terraform-provider-kubernetes/releases/download/v1.3.0-custom/terraform-provider-kubernetes_v1.3.0-custom_darwin_amd64.zip && unzip terraform-provider-kubernetes.zip && mv terraform-provider-kubernetes_v1.3.0-custom_x4 terraform-provider-kubernetes
    chmod +x ./terraform-provider-kubernetes
    rm -f terraform-provider-kubernetes.zip

    curl -L -o - https://github.com/Comcast/terraform-provider-akamai/releases/download/0.2.2/terraform-provider-akamai-darwin_amd64-0.2.2.tgz | tar xvf - > terraform-provider-akamai
    chmod +x terraform-provider-akamai

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Downloading custom providers for linux"
    curl -L -o terraform-provider-kubernetes.zip https://github.com/sl1pm4t/terraform-provider-kubernetes/releases/download/v1.3.0-custom/terraform-provider-kubernetes_v1.3.0-custom_linux_amd64.zip && unzip terraform-provider-kubernetes.zip && rm terraform-provider-kubernetes.zip
    mv terraform-provider-kubernetes_v1.3.0-custom_x4 terraform-provider-kubernetes
    chmod +x terraform-provider-kubernetes

    curl -L -o - https://github.com/Comcast/terraform-provider-akamai/releases/download/0.2.2/terraform-provider-akamai-linux_amd64-0.2.2.tgz | tar xvfz - > terraform-provider-akamai
    chmod +x terraform-provider-akamai    
    
fi