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

function install_hotrod {
  kubeconfig=$1
  kubectl create -f hotrod/ --kubeconfig=$kubeconfig
}

function install_jaeger {
  kubeconfig=$1
  kubectl create -f jaeger/ --kubeconfig=$kubeconfig
}

function install_jaeger_monitoring {
    kubeconfig=$1
    kubectl create -f jaeger-monitoring/ --kubeconfig=$kubeconfig
}

# hydra clusters only
get_configs
for conf in $(find . -type f -name 'kubeconfig_*' | grep -v monitoring)
do
  echo "Installing hc-app for kubeconf: $conf"
  install_hc_app $conf
  install_hotrod $conf
  install_jaeger $conf
done

# monitoring clusters only
for conf in $(find . -type f -name 'kubeconfig_*' | grep  monitoring)
do
    install_jaeger_monitoring $conf
done
