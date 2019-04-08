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
    auth-provider:
      config:
        access-token: ${access_token}
        cmd-args: config config-helper --format=json
        cmd-path: /usr/local/google-cloud-sdk/bin/gcloud
        expiry: "${timeadd(timestamp(), "1h")}"
        expiry-key: '{.credential.token_expiry}'
        token-key: '{.credential.access_token}'
      name: gcp
