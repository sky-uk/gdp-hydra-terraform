#!/usr/bin/env bash

set +x
num_failures=0
pids=( )

function az_login {
    az login --service-principal -u http://CircleCI -p $TF_VAR_azure_client_secret --tenant $TF_VAR_azure_tenant_id > /dev/null
}

function gcp_login {
    gcloud auth activate-service-account --key-file=<(echo $TF_VAR_google_creds_base64 | base64 -d) --project=$TF_VAR_google_project_id
}

function clean_gcp {
    clusters=$(gcloud container clusters list "--format=value[separator=','](name, zone)" --filter="resourceLabels.hydra_project=$TF_VAR_project_name")
    for c in $clusters
    do
        name=$(echo $c | cut -f 1 -d,)
        zone=$(echo $c | cut -f 2 -d,)
        gcloud container clusters delete -q $name --zone $zone
    done
}

function clean_azure {
    groups=$(az group list --query "[?tags.hydra_project=='$TF_VAR_project_name' && properties.provisioningState != 'Deleting'].name" -o tsv)
    for g in $groups
    do
        az group delete -y --name $g & pids+=( $! )
    done
}

function clean_az_creds {
    app_ids=$(az ad app list --all --query "[?contains(displayName,'$TF_VAR_project_name')].appId" -o tsv)
    for app_id in $app_ids
    do
        az ad app delete --id $app_id & pids+=( $! )
    done
}

function clean_akamai {
    cat << EOF > $HOME/.edgerc
    [default]
    client_secret = $akamai_client_secret
    host = $akamai_host
    access_token = $akamai_access_token
    client_token = $akamai_client_token
EOF
    http --auth-type edgegrid -a default: GET :/config-gtm/v1/domains/$TF_VAR_edge_dns_zone/datacenters
}

function clean_state {
    rm terraform.tfstate
}

function clean_gcp_creds {

    users=$(gcloud iam service-accounts list --filter="displayName='Registry User'" --format="value(email)")
    for u in $users
    do
      gcloud iam service-accounts delete -q --project $TF_VAR_google_project_id $u & pids+=( $! )
    done
}

function clean_gcp_disks {
  disks=$(gcloud compute disks list --filter="name~'$TF_VAR_project_name'" --format="value[separator=','](id, zone)")
  for d in $disks
  do
    id=$(echo $d | cut -f 1 -d,)
    zone=$(echo $d | cut -f 2 -d,)
    gcloud compute disks delete -q $id --zone $zone & pids+=( $! )
  done
}

function wait_for_processing {
  for pid in "${pids[@]}"; do
    wait "$pid" || (( ++num_failures ))
  done

  if (( num_failures > 0 )); then
    echo "Warning: $num_failures background processes (out of ${#pids[@]} total) failed" >&2
  fi
  pids=( )
}
#clean_akamai

gcp_login
az_login
clean_azure
clean_gcp
clean_gcp_disks
wait_for_processing
clean_az_creds
clean_gcp_creds
wait_for_processing
exit $num_failures
