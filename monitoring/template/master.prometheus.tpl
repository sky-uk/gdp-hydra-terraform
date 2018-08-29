global:
  scrape_interval:     15s
  evaluation_interval: 30s
  # scrape_timeout is set to the global default (10s).

  external_labels:
    cluster: master

scrape_configs:
- job_name: 'federate'
  scrape_interval: 15s

  honor_labels: true
  metrics_path: '/federate'

  params:
    'match[]':
      - '{job="prometheus"}'
      - '{__name__=~"traefik.*"}'

  static_configs:
    - targets:
      - '${AKS_CLUSTER_PROMETEHUS_SVC_IP_1}:80'
      - '${AKS_CLUSTER_PROMETEHUS_SVC_IP_2}:80'
      - '${GKE_CLUSTER_PROMETHEUS_SVC_IP_1}:80'
      - '${GKE_CLUSTER_PROMETHEUS_SVC_IP_2}:80'