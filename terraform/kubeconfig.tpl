apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${ca_data}
    server: ${endpoint}
  name: ${cluster_name}
contexts:
- context:
    cluster: ${cluster_name}
    user: ${cluster_name}
  name: ${cluster_name}
current-context: ${cluster_name}
users:
- name: ${cluster_name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1
      command: aws
      args:
        - eks
        - get-token
        - --cluster-name
        - ${cluster_name}
      # Uncomment and adjust this if you're using a specific profile
      # env:
      # - name: AWS_PROFILE
      #   value: "your-profile"
