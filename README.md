# Hydra Terraform Module

Used for terraforming a highly available set of clusters across multiple cloud vendors.

## Variables

- azure_client_id - (Required) 
- azure_client_secret - (Required) 
- azure_tenant_id - (Required) 
- azure_subscription_id - (Required) 
- azure_resource_locations - (Optional) List of locations used for deploying resources. Defaults to westeurope and northeurope,
- project_name - Name of the project that is used across the deployment for naming resources
- azure_node_ssh_key - (Required) SSH key for nodes created in AKS
- google_project_id - (Required) 
- gcp_creds_base64 - (Required) The service account json file base64 encoded
- akamai_host - (Required) Host for akamai API
- akamai_client_secret - (Required) 
- akamai_access_token - (Required) 
- akamai_client_token - (Required) 
- kubernetes_version - (Optional) The version of kubernetes to deploy. Defaults to 1.10.5
- node_type - (Optional) Size of nodes to provision in each cluster, options are small, medium, large. Defaults to small.
- node_count - (optional) Number of nodes in each cluster. Defaults to 1
- aks_cluster_1_enabled - (Optional) Defaults to true
- aks_cluster_2_enabled - (Optional) Defaults to true
- gke_cluster_1_enabled - (Optional) Defaults to true
- gke_cluster_2_enabled - (Optional) Defaults to true

## Outputs

- ips - A list of all the cluster IP addresses
- kubeconfigs - A map containing all of the configs in a map |
- edge_url - The configured edge URL on akamai
- gcr_location - 
- gcr_credentials
- acr_location
- acr_username
- acr_password
- kubeconfig_url - Azure storage URL for zip file containing all of the cluster kubeconfigs
