#!/usr/bin/env bash

set -eo pipefail

terraform_state=$1

function log {
    tput bold; tput setaf 1; echo "------------------------"
    tput bold; tput setaf 1; echo $1
    tput bold; tput setaf 1; echo "------------------------"
}

function get_configs {
  CONFIG_SAS_URL=$(terraform output -state=$terraform_state kubeconfig_url)

  log "Downloading kubeconfigs from Terraform"
  curl -sS $CONFIG_SAS_URL > kube_configs.zip

  log "Extract configs"
  unzip kube_configs.zip
}

function install_hc_app {
  kubeconfig=$1
  echo "kubectl apply -f hc-app/ --kubeconfig=$kubeconfig"
}

get_configs
for kconfig in $(find kubeconfig -type f)
do
  install_hc_app $kconfig
done

