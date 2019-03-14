#!/usr/bin/env bash

set -eo pipefail

terraform_state=$1

function get_configs {
  CONFIG_SAS_URL=$(terraform output -state=$terraform_state kubeconfig_url)

  echo "Downloading kubeconfigs from Terraform"
  curl -sS $CONFIG_SAS_URL > kube_configs.zip

  echo "Extract configs"
  unzip kube_configs.zip
}

function install_hc_app {
  kubeconfig=$1
  kubectl create namespace healthcheck --kubeconfig=$kubeconfig
  kubectl create -f hc-app/ --kubeconfig=$kubeconfig
}

get_configs
for conf in $(find . -type f -name 'kubeconfig_*' | grep -v monitoring)
do
  echo "Installing hc-app for kubeconf: $conf"
  install_hc_app $conf
done
