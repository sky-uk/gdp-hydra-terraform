# Hydra Terraform Module

Used for terraforming a highly available set of clusters across multiple cloud vendors. Currently this module is designed to create 4 clusters across Azure and GCP with each cluster being in a different availability zone within the rprovider. It will also then use Akamai Traffic Manager to balance traffic across the cluster.

## Pre-requisites

You should be familiar with some basic Terraform concepts such as

- Variables
- Outputs
- Modules
- Backends

You can find out more in the [Terraform Documentation](https://www.terraform.io/docs/index.html)

## Getting Started

To get started using this module you will need to create a new Terraform file and reference the module in git. You should ensure that you have specified a specific version in `ref=` section to ensure you get consistent results. This can be either a branch or a tag reference.

``` terraform
module "hydra" {
  "source" = "git@github.com:sky-uk/gdp-hydra-terraform?ref=v0.0.1"
}
```

You will then need to add the required varibles as described below. Your final module configuration should look something like this.

```
module "hydra" {
  "source" = "git@github.com:sky-uk/gdp-hydra-terraform?ref=v0.0.1"

  "project_name"          = "myclusters"
  "azure_client_id"       = ""
  "azure_client_secret"   = ""
  "azure_tenant_id"       = ""
  "azure_subscription_id" = ""
  "azure_node_ssh_key"    = ""
  "gcp_creds_base64"      = ""
  "google_project_id"     = "my-project-101"
  "akamai_host"           = ""
  "akamai_client_secret"  = ""
  "akamai_access_token"   = ""
  "akamai_client_token"   = ""
}
```

You must supply values for all of these variables. You can choose to use any of the other optional variables as required by your deployment.

## Authenticating

### Azure

You will need to create a service principal to use for authentication when applying your Terraform configuration.

Because this service principal will need to create other principals as part of the provisioning it must have permissions to both "Read and write all applications" and "Sign in and read user profile" within the "Windows Azure Active Directory" API. You grant these permissions via the Application Registrations blade in the Azure portal.

The Terraform sevice principal will need to be an Owner on the subscription. This is because it needs the ability to create all types of resources.

### Google Compute Cloud

You must create a user that has asmin priviledges within your project.
You must also activate the relevante IAM management APIs within the project

When you create a new service account you will be provided with a JSON credentials file for GCP. You will need to base64 encode the file content to pass it into the hydra module.

``` bash
cat ./creds/gcp.private.json | base64 > ./creds/gcp.base64.txt
```

You can then pass that into the hydra module.

## Variables

### Azure Athentication

The following properties are required for authenticating into the Azure platform to create resources. See the Authenticating section above for more information on creating credentials

- azure_client_id - (Required) 
- azure_client_secret - (Required) 
- azure_tenant_id - (Required) 
- azure_subscription_id - (Required) 

### Google Compute Platform Credentials

These variables are requried configuration to create resources within GCP. See the Authenticating section above for more information on creating credentials

- google_project_id - (Required) 
- gcp_creds_base64 - (Required) The service account json file base64 encoded

### Akamain API Authentication

- akamai_host - (Required) Host for akamai API
- akamai_client_secret - (Required) 
- akamai_access_token - (Required) 
- akamai_client_token - (Required) 

### Cluster Configuration

These variables are used to configure aspects of the clusters that are created by hydra.

- project_name - (Required) Name of the project that is used across the deployment for naming resources. This will be used in cluster names, DNS entries and all other configuration and will enable you to identify resources.
- azure_node_ssh_key - (Required) SSH key for nodes created in AKS. This SSH key is used as the access key for each of the nodes created in AKS. Keep this safe as it will allow you to remote onto nodes should you need to. You can create a new key with `ssh-keygen -f ./id_rsa -N "" -C "aks-key"`
- azure_resource_locations - (Optional) List of locations used for deploying resources. The first location is the default location that any tooling such as the docker registry will be created in. Only two values are required, others will be ignored. They should be valid Azure region strings. Defaults to westeurope and northeurope. 
- kubernetes_version - (Optional) The version of kubernetes to deploy. You should ensure that this version is available in each region. Changing this property will result in an upgrade of clusters. Defaults to 1.10.5
- node_type - (Optional) Size of nodes to provision in each cluster, options are small, medium, large. Defaults to small. Changing this will result in a full rebuild of all clusters.
- node_count - (Optional) Number of nodes in each cluster. Defaults to 1

### Cluster Load Balancing

The following variables configure which clusters should be active in the Akamai load balancing configuration. You can use these variables to remove a cluster from the traffic manager so that you can perform maintenance or upgrades. Setting a property to false will disable it in the traffic manager configuration.

- aks_cluster_1_enabled - (Optional) Defaults to true
- aks_cluster_2_enabled - (Optional) Defaults to true
- gke_cluster_1_enabled - (Optional) Defaults to true
- gke_cluster_2_enabled - (Optional) Defaults to true

## Outputs

- ips - A list of all the cluster IP addresses
- kubeconfigs - A map containing all of the configs in a map |
- edge_url - The configured edge URL on akamai
- gcr_location
- gcr_credentials
- acr_location
- acr_username
- acr_password
- kubeconfig_url - Azure storage URL for zip file containing all of the cluster kubeconfigs, this link includes a SAS token and will grant access to all users. This can be used as part of CI processes to access all clusters.

You can run `terraform output` from an initialised terraform directory to get the outputs of the terrafom config to use in things like CI or to get access details for different resources.
