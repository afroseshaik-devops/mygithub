replicaCount: ${replica_count}

image:
  repository: ${image_repository}
  pullPolicy: IfNotPresent
  tag: "${image_tag}"

service:
  type: ${service_type}
  port: ${service_port}
  targetPort: 8080

resources:
  limits:
    cpu: ${cpu_limit}
    memory: ${memory_limit}
  requests:
    cpu: ${cpu_request}
    memory: ${memory_request}
