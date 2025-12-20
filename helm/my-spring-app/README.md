# My Spring App Helm Chart

A Helm chart for deploying the Spring Boot application on Kubernetes.

## Overview

This Helm chart deploys a containerized Spring Boot application with the following features:

- Configurable replica count
- Resource limits and requests
- Service (LoadBalancer, NodePort, or ClusterIP)
- Optional Ingress support
- Optional Horizontal Pod Autoscaling (HPA)
- Liveness and readiness probes
- Configurable environment variables
- Service account management

## Prerequisites

- Kubernetes cluster (1.19+)
- Helm 3.x
- kubectl configured to communicate with your cluster

## Installing the Chart

### From Local Chart

```bash
# Install with default values
helm install my-spring-app ./helm/my-spring-app

# Install in a specific namespace
helm install my-spring-app ./helm/my-spring-app --namespace production --create-namespace

# Install with custom values
helm install my-spring-app ./helm/my-spring-app -f custom-values.yaml

# Install with command-line overrides
helm install my-spring-app ./helm/my-spring-app \
  --set image.tag=v1.0.0 \
  --set replicaCount=3 \
  --set service.type=LoadBalancer
```

## Uninstalling the Chart

```bash
helm uninstall my-spring-app
```

## Configuration

The following table lists the configurable parameters of the chart and their default values.

### Image Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Docker image repository | `339713053602.dkr.ecr.ap-south-1.amazonaws.com/my-spring-app` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.tag` | Image tag | `latest` |
| `imagePullSecrets` | Image pull secrets | `[]` |

### Deployment Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `2` |
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override full name | `""` |

### Service Account

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceAccount.create` | Create service account | `true` |
| `serviceAccount.annotations` | Service account annotations | `{}` |
| `serviceAccount.name` | Service account name | `""` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type | `LoadBalancer` |
| `service.port` | Service port | `80` |
| `service.targetPort` | Container port | `8080` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts[0].host` | Hostname | `my-spring-app.local` |
| `ingress.hosts[0].paths[0].path` | Path | `/` |
| `ingress.hosts[0].paths[0].pathType` | Path type | `Prefix` |
| `ingress.tls` | TLS configuration | `[]` |

### Resource Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |
| `resources.requests.cpu` | CPU request | `250m` |
| `resources.requests.memory` | Memory request | `256Mi` |

### Autoscaling Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Minimum replicas | `2` |
| `autoscaling.maxReplicas` | Maximum replicas | `10` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU % | `80` |

### Health Checks

| Parameter | Description | Default |
|-----------|-------------|---------|
| `livenessProbe.httpGet.path` | Liveness probe path | `/` |
| `livenessProbe.httpGet.port` | Liveness probe port | `http` |
| `livenessProbe.initialDelaySeconds` | Initial delay | `30` |
| `livenessProbe.periodSeconds` | Check period | `10` |
| `readinessProbe.httpGet.path` | Readiness probe path | `/` |
| `readinessProbe.httpGet.port` | Readiness probe port | `http` |
| `readinessProbe.initialDelaySeconds` | Initial delay | `20` |
| `readinessProbe.periodSeconds` | Check period | `10` |

### Other Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `env` | Environment variables | `[]` |
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Affinity rules | `{}` |
| `podAnnotations` | Pod annotations | `{}` |
| `podSecurityContext` | Pod security context | `{}` |
| `securityContext` | Container security context | `{}` |

## Usage Examples

### Example 1: Deploy with Custom Image Tag

```bash
helm install my-spring-app ./helm/my-spring-app \
  --set image.tag=v1.2.3
```

### Example 2: Deploy with Ingress Enabled

Create a `values-ingress.yaml` file:

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: myapp-tls
      hosts:
        - myapp.example.com
```

Install the chart:

```bash
helm install my-spring-app ./helm/my-spring-app -f values-ingress.yaml
```

### Example 3: Deploy with Autoscaling

```bash
helm install my-spring-app ./helm/my-spring-app \
  --set autoscaling.enabled=true \
  --set autoscaling.minReplicas=3 \
  --set autoscaling.maxReplicas=15 \
  --set autoscaling.targetCPUUtilizationPercentage=75
```

### Example 4: Deploy with Custom Environment Variables

Create a `values-env.yaml` file:

```yaml
env:
  - name: SPRING_PROFILES_ACTIVE
    value: "production"
  - name: DATABASE_URL
    value: "jdbc:postgresql://db.example.com:5432/mydb"
  - name: LOG_LEVEL
    value: "INFO"
```

Install the chart:

```bash
helm install my-spring-app ./helm/my-spring-app -f values-env.yaml
```

### Example 5: Deploy with Resource Limits

```bash
helm install my-spring-app ./helm/my-spring-app \
  --set resources.limits.cpu=1000m \
  --set resources.limits.memory=1Gi \
  --set resources.requests.cpu=500m \
  --set resources.requests.memory=512Mi
```

## Upgrading the Chart

To upgrade an existing release:

```bash
# Upgrade with new image tag
helm upgrade my-spring-app ./helm/my-spring-app \
  --set image.tag=v2.0.0

# Upgrade with new values file
helm upgrade my-spring-app ./helm/my-spring-app -f new-values.yaml
```

## Verifying the Deployment

After installation, verify the deployment:

```bash
# Check release status
helm status my-spring-app

# Check pods
kubectl get pods -l app.kubernetes.io/name=my-spring-app

# Check service
kubectl get svc -l app.kubernetes.io/name=my-spring-app

# View logs
kubectl logs -l app.kubernetes.io/name=my-spring-app

# If using LoadBalancer, get the external IP
kubectl get svc -l app.kubernetes.io/name=my-spring-app -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}'
```

## Troubleshooting

### Pod Not Starting

Check pod events:
```bash
kubectl describe pod <pod-name>
```

Check logs:
```bash
kubectl logs <pod-name>
```

### Service Not Accessible

Check service:
```bash
kubectl get svc
kubectl describe svc <service-name>
```

### Image Pull Issues

Ensure image pull secrets are configured:
```yaml
imagePullSecrets:
  - name: ecr-secret
```

## Development

### Linting the Chart

```bash
helm lint ./helm/my-spring-app
```

### Testing the Chart

```bash
# Dry run
helm install my-spring-app ./helm/my-spring-app --dry-run --debug

# Template rendering
helm template my-spring-app ./helm/my-spring-app
```

### Packaging the Chart

```bash
helm package ./helm/my-spring-app
```

## Notes

- The application container exposes port 8080
- Health checks are configured for path `/` 
- Default service type is LoadBalancer for easy external access
- The chart supports Kubernetes 1.19+
- Helm 3.x is required

## Chart Maintainers

This chart is maintained as part of the My Spring App project.
