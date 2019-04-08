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
    kubectl create namespace observability --kubeconfig=$kubeconfig
    kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/crds/jaegertracing_v1_jaeger_crd.yaml --kubeconfig=$kubeconfig
    kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/service_account.yaml --kubeconfig=$kubeconfig
    kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/role.yaml --kubeconfig=$kubeconfig
    kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/role_binding.yaml --kubeconfig=$kubeconfig
    kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/operator.yaml --kubeconfig=$kubeconfig

    kubectl create -f jaeger-monitoring/ --kubeconfig=$kubeconfig
}

# hydra clusters only
get_configs
for conf in $(find . -type f -name 'kubeconfig_*' | grep -v monitoring)
do
  echo "Installing hotrod for kubeconf: $conf"
  install_hotrod $conf
  echo "Installing jaeger for kubeconf: $conf"
  install_jaeger $conf
done

# monitoring clusters only
for conf in $(find . -type f -name 'kubeconfig_*' | grep  monitoring)
do
    echo "Installing jaeger_monitoring for kubeconf: $conf"
    install_jaeger_monitoring $conf
done
