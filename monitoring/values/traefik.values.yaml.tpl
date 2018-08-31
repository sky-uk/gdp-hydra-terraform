# We override the fullname to give us a consistent name
fullnameOverride: traefik-ingress-controller
serviceType: LoadBalancer
replicas: ${replicas_count}
# Enabling RBAC will create a service account, cluster role
# and cluster role binding to give Traefik the required
# permissions
rbac:
  enabled: false
# Enabling the dashboard will allow you to view Traefik's
# current configuration and health.
dashboard:
  domain: "traefik.local"
  enabled: true

cpuRequest: 0.5
memoryRequest: 50M
cpuLimit: 2
memoryLimit: 300M

tracing:
  jaeger:
    samplingServerUrl: "http://jaeger-agent:5778/"
    samplingType: "const"
    localAgentHostPort: "jaeger-agent:6831"

# Enabling prometheus metrics will expose a /metrics
# endpoint that we can scrape with prometheus
metrics:
  prometheus:
    enabled: true
    buckets : [0.1,0.3,1.2,5.0]
# Define the namespace scope
# kubernetes:
#   namespaces:
#     - kube-system
#     - default