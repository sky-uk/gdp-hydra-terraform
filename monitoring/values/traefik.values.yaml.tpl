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
  enabled: true
  serviceName: traefik
  backend: jaeger
  jaeger:
    localAgentHostPort: "jaeger-agent.monitoring:6831"
    samplingServerURL: http://localhost:5778/sampling
    samplingType: const
    samplingParam: "1.0"

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

ssl:
  enabled: true
  enforced: false

