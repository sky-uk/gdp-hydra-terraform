apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${certificate_authority_data}
    server: ${server}
  name: ${cluster_name}
contexts:
- context:
    cluster: ${cluster_name}
    user: user-${cluster_name}
  name: default-context
current-context: default-context
kind: Config
preferences: {}
users:
- name: user-${cluster_name}
  user:
    client-certificate-data: ${client_cert}
    client-key-data: ${client_key}

