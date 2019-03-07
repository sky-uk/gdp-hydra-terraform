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
    
    echo "Downloading kubectl"
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    mv ./kubectl /usr/local/bin/kubectl
    
    echo "Downloading Helm"
    curl -LO https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-linux-amd64.tar.gz
    tar xzvf helm-v2.11.0-linux-amd64.tar.gz
    mv linux-amd64/helm /usr/local/bin/
    mv linux-amd64/tiller /usr/local/bin/
fi