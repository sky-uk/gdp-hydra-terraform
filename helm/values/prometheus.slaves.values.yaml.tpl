config:
  specifiedInValues: true
  value: {}
labels:
  prometheus-operated: 'true'
externalLabels:
  datacenter: ${cluster_name}
externalUrl: ''
selfServiceMonitor: false
image:
  repository: quay.io/prometheus/prometheus
  tag: v2.2.1
paused: false
global:
  rbacEnable: false
  pspEnable: false
serviceAccount:
  create: true
replicaCount: 1
logLevel: info
podAntiAffinity: soft
remoteRead: {}
remoteWrite: {}
retention: 24h
routePrefix: /
rules:
  specifiedInValues: false
  additionalLabels: {}
  value: {}
service:
  sessionAffinity: None
  annotations: {}
  labels: {}
  loadBalancerSourceRanges: []
  type: ClusterIP