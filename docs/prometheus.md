# Prometheus

Prometheus is configured in each individual cluster using Prometheus Operator and will scrape any services that are configured with a ServiceMonitor configuration.

The metrics endpoint of each Prometheus service is then exposed via the ingress so that it can be federated. The endpoints are secured with basic authentication and HTTPS via the ingress configuration.

There is also another Prometheus instance that is configured in the monitoring cluster that scrapes the exposed Prometheus metrics endpoints to roll up the metrics from each of the clusters. Each cluster is configured as an external endpoint in the monitoring cluster. This allows Prometheus to use service discovery to find all of the cluster IPs pick up any changes that are made.

This is done via a custom chart that is embedded in this module. [You can see more of how this is configured here](../monitoring/prometheus.tf) as the `worker_endpoints` resource.

## Dashboard

The Prometheus dashboard is also available in the monitoring cluster and is secured via basic auth. The password is generated as part of hydra and is one of the outputs of the module.

Due to some limitation with terraform should you need to change the password to the Prometheus dashbaord you will need to run a command to trigger the change to be pushed out to the cluster. First change the password that you have in your variables and then

``` bash
terraform taint -module hydra.monitoring kubernetes_secret.prometheus_password
```

This will manually mark the secret that contains the password for recreation and will update it with your new password. Once you have run this you will need to run a `terraform apply` again.
