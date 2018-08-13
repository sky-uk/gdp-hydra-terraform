# Hydra Terraform Module

Used for terraforming a highly available set of clusters across multiple cloud vendors. Currently this module is designed to create 4 clusters across Azure and GCP with each cluster being in a different availability zone within the rprovider. It will also then use Akamai Traffic Manager to balance traffic across the cluster.

## Pre-requisites

You should be familiar with some basic Terraform concepts such as

- Variables
- Outputs
- Modules
- Backends

You can find out more in the [Terraform Documentation](https://www.terraform.io/docs/index.html)

The provider also requires a set of additional Terraform Providers. These are installed by the `install.sh` script:

- [Helm (mcuadros)](https://github.com/mcuadros/terraform-provider-helm)
- [Akamai (Comcast)](https://github.com/Comcast/terraform-provider-akamai)

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
  "google_creds_base64"   = ""
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

## Rolling Update

Terraform supports targeting specific resources during an `tf apply` command. The module has been designed to allow a rolling cluster update to be performed using this targetting. There is a sample script [here](./example/rolling_update.sh), it does the following for each cluster:

- Disables the cluster from Akamai or Cloudflare to stop new traffic using the cluster
- Applies any required updates to that cluster 
- Checks the `/healthz` endpoint in the cluster, provided by the [k8s-healthcheck](https://github.com/emrekenci/k8s-healthcheck) project. 
- If that endpoint returns healthy: Renables the cluster in Akamai or Cloudflare

There are a number of limitation to the current script, called out inline with the `[Placeholder]` calls:

1. It doesn't wait for requests to stop arriving before updating the cluster. For example Akamai uses DNS based routing so some requests may continue to arrive even after the change has been made to Akamai's config due to the DNS TTL.
2. The healthcheck is limited to K8s infrastructure, if this is being used to roll out an app you would want to also check the apps health. 

It serves to demonstrate how a zero downtime rollout, for example updating K8's versions, could be handled but for a production system this flow would best be split out into a CD pipeline with more checks, automated approval steps and possibly manual ones too. 

## Variables

### Azure Athentication

The following properties are required for authenticating into the Azure platform to create resources. See the Authenticating section above for more information on creating credentials

 Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| azure_client_id |  | string | - | yes |
| azure_client_secret |  | string | - | yes |
| azure_subscription_id |  | string | - | yes |
| azure_tenant_id |  | string | - | yes |

### Google Compute Platform Credentials

These variables are requried configuration to create resources within GCP. See the Authenticating section above for more information on creating credentials

 Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| google_project_id |  | string | - | yes |
| google_creds_base64 | The service account json file base64 encoded | string | - | yes |

### Akamain API Authentication

 Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| akamai_access_token |  | string | - | yes |
| akamai_client_secret |  | string | - | yes |
| akamai_client_token |  | string | - | yes |
| akamai_host | Host for akamai API | string | - | yes |

### Cluster Configuration

These variables are used to configure aspects of the clusters that are created by hydra.

 Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| project_name | Name of the project that is used across the deployment for naming resources. This will be used in cluster names, DNS entries and all other configuration and will enable you to identify resources. | string | - | yes |
| azure_node_ssh_key | SSH key for nodes created in AKS. This SSH key is used as the access key for each of the nodes created in AKS. Keep this safe as it will allow you to remote onto nodes should you need to. You can create a new key with `ssh-keygen -f ./id_rsa -N '' -C aks-key` | string | - | yes |
| azure_resource_locations | List of locations used for deploying resources. The first location is the default location that any tooling such as the docker registry will be created in. Only two values are required, others will be ignored. They should be valid Azure region strings. Defaults to westeurope and northeurope. | string | `<list>` | no |
| kubernetes_version | The version of kubernetes to deploy. You should ensure that this version is available in each region. Changing this property will result in an upgrade of clusters. Defaults to 1.10.5 | string | `1.10.5` | no |
| node_count | Number of nodes in each cluster. | string | `1` | no |
| node_type | Size of nodes to provision in each cluster, options are small, medium, large. Defaults to small. Changing this will result in a full rebuild of all clusters. | string | `small` | no |

### Cluster Load Balancing

The following variables configure which clusters should be active in the Akamai load balancing configuration. You can use these variables to remove a cluster from the traffic manager so that you can perform maintenance or upgrades. Setting a property to false will disable it in the traffic manager configuration.

 Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| traffic_manager_aks_cluster_1_enabled |  | string | `true` | no |
| traffic_manager_aks_cluster_2_enabled |  | string | `true` | no |
| traffic_manager_gke_cluster_1_enabled |  | string | `true` | no |
| traffic_manager_gke_cluster_2_enabled |  | string | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| acr_password | The password for the docker registry for Azure clusters |
| acr_url | The URL of the docker registry for Azure clusters |
| acr_username | The username for the docker registry for Azure clusters |
| edge_url | The URL of the Akamai Traffic Manager edge |
| gcr_credentials | JSON credentials file for the docker registry for GCP clusters |
| gcr_url | The URL of the docker registry for GCP clusters |
| ips | Map of the cluster IPs |
| kubeconfig_url | URL for zip file containing all of the cluster kubeconfigs, this link includes a SAS token and will grant access to all users. This can be used as part of CI processes to access all clusters. |
| kubeconfigs | Map of the kuber config files for all clusters. These files are also zipped up and uploaded to kubeconfig_url |

You can run `terraform output` from an initialised terraform directory to get the outputs of the terrafom config to use in things like CI or to get access details for different resources.

## Documentation

Parts of this documentation have been generated from the module souce via https://github.com/segmentio/terraform-docs
