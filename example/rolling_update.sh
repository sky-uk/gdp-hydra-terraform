#!/bin/bash
# Run TF and connect to each cluster listing it's pods
set -eu

function log {
    tput bold; tput setaf 1; echo "------------------------"
    tput bold; tput setaf 1; echo $1
    tput bold; tput setaf 1; echo "------------------------"
}

if ! which jq > /dev/null; then
   log "JQ is required"
   exit 1
fi

if ! which terraform > /dev/null; then
   log "Terraform is required"
   exit 1
fi

if ! which curl > /dev/null; then
   log "Curl is required"
   exit 1
fi

if ! which kubectl > /dev/null; then
   log "Kubectl is required"
   exit 1
fi

if ! which unzip > /dev/null; then
   log "Unzip is required"
   exit 1
fi

function get_configs {
    CONFIG_SAS_URL=$(terraform output kubeconfig_url)

    log "Downloading kubeconfigs from Terraform"
    curl -sS $CONFIG_SAS_URL > kube_configs.zip

    log "Extract configs"
    unzip kube_configs.zip
}

function update_cluster {
    CLUSTER_NAME=$1
    NETWORK_PROVIDER=$2

    log "Disabling cluster: $CLUSTER_NAME in: $NETWORK_PROVIDER"
    if [ $NETWORK_PROVIDER == "cloudflare" ]
    then
        terraform apply -refresh=false -auto-approve -target module.hydra.module.cloudflare.cloudflare_load_balancer_pool.hydra_clusters -var traffic_manager_"$CLUSTER_NAME"_enabled=false
    elif [ $NETWORK_PROVIDER == "akamai" ]
    then
        terraform apply -refresh=false -auto-approve -target module.hydra.module.akamai_config.akamai_gtm_property.hydra_property -var traffic_manager_"$CLUSTER_NAME"_enabled=false
    else
        log "Unsupported network provider: $NETWORK_PROVIDER"
    fi

    # [Placeholder] Does you app have long running sessions of user state which isn't share between clusters
    # if so you need to look at gracefully draining the traffic here.

    log "Updating cluster $CLUSTER_NAME"
    terraform apply -auto-approve -target module.hydra.module.$CLUSTER_NAME

    log "Getting config and listing pods"
    terraform output -json kubeconfigs | jq -r ".value.$CLUSTER_NAME" > kubeconfig_$CLUSTER_NAME
    export KUBECONFIG=./kubeconfig_$CLUSTER_NAME
    kubectl get pods

    # Hit the deployed nginx service to check it's available
    log "Hitting ingress endpoint to check cluster responds"
    curl --silent --output /dev/null --fail $(terraform output -json ips | jq -r ".value.$CLUSTER_NAME")/healthz
    log "Health endpoint responded correctly!"

    log "Enabling cluster: $CLUSTER_NAME in: $NETWORK_PROVIDER"
    if [ $NETWORK_PROVIDER == "cloudflare" ]
    then
        terraform apply -auto-approve -target module.hydra.module.cloudflare
    elif [ $NETWORK_PROVIDER == "akamai" ]
    then
        terraform apply -auto-approve -target module.hydra.module.akamai_config
    else
        log "Unsupported network provider: $NETWORK_PROVIDER"
    fi
}

update_cluster "aks_cluster_1" "cloudflare"
# [Placeholder] run Application deployment 
# [Manual Acceptance] Email someone to sanity check 

update_cluster "aks_cluster_2" "cloudflare"
update_cluster "gke_cluster_1" "cloudflare"
update_cluster "gke_cluster_2" "cloudflare"

# Update any additional TF resources that haven't been handled by the 
# targetted cluster update
terraform apply -auto-approve
