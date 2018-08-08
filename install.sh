#!/bin/bash

set -eu

if [ "$(uname)" == "Darwin" ]; then
    echo "Downloading custom providers for MacOS"
    curl -L -o - https://github.com/Comcast/terraform-provider-akamai/releases/download/0.2.2/terraform-provider-akamai-darwin_amd64-0.2.2.tgz | tar xvf - > terraform-provider-akamai
    chmod +x terraform-provider-akamai

    curl -L -o - https://github.com/mcuadros/terraform-provider-helm/releases/download/v0.5.1/terraform-provider-helm_v0.5.1_darwin_amd64.tar.gz | tar xvf - --strip-components=1 > terraform-provider-helm
    chmod +x ./terraform-provider-helm

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Downloading custom providers for linux"

    curl -L -o - https://github.com/Comcast/terraform-provider-akamai/releases/download/0.2.2/terraform-provider-akamai-linux_amd64-0.2.2.tgz | tar xvfz - > terraform-provider-akamai
    chmod +x terraform-provider-akamai    

    curl -L -o - https://github.com/mcuadros/terraform-provider-helm/releases/download/v0.5.1/terraform-provider-helm_v0.5.1_linux_amd64.tar.gz | tar xvfz - --strip-components=1 > terraform-provider-helm
    chmod +x ./terraform-provider-helm
fi