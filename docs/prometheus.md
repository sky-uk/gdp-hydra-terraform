# Prometheus

Prometheus is configured in each individual cluster using Prometheus Operator and will scrape any services that are configured wil a ServiceMonitor configuration.

The metrics endpoint of each prometheus service is then exposed via the ingress so that it can be federated. The endpoints are secured with basic authentication and HTTPS via the ingress configuration.

There is also another prometheus instance that is configured in the monitoring cluster that scrapes the exposed prometheus metrics endpoints to roll up the metrics from each of the clusters. Each cluster is configured as an external endpoint in the monitoring cluster. This allows prometheus to use service discovery to find all of the cluster IPs pick up any changes that are made.

This is done via a custom chart that is embedded in this module. [You can see more of how this is configured here](../monitoring/prometheus.tf) as the `worker_endpoints` resource.