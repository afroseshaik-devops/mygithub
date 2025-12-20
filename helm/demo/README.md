# Demo Spring Boot Application Helm Chart

This Helm chart deploys the Spring Boot demo application to Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Docker image built and available in a registry
- For AWS ECR: ECR pull secret configured in Kubernetes cluster

## Quick Start with Jenkins

This chart is designed to work with the Jenkins CI/CD pipeline. The Jenkinsfile automatically:
1. Builds the Spring Boot application
2. Creates a Docker image
3. Pushes to AWS ECR
4. Deploys to Kubernetes using this Helm chart

See [DEPLOYMENT.md](../../DEPLOYMENT.md) in the root directory for complete step-by-step deployment instructions.

## Installing the Chart

To install the chart with the release name `my-demo`:

```bash
helm install my-demo ./helm/demo
```

## Uninstalling the Chart

To uninstall/delete the `my-demo` deployment:

```bash
helm uninstall my-demo
```

## Configuration

The following table lists the configurable parameters of the Demo chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `spring-boot-demo` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.tag` | Image tag | `""` (defaults to chart appVersion) |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `service.targetPort` | Container port | `8080` |
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.hosts` | Ingress hosts | `[demo.local]` |
| `resources` | CPU/Memory resource requests/limits | `{}` |
| `autoscaling.enabled` | Enable horizontal pod autoscaler | `false` |
| `autoscaling.minReplicas` | Minimum number of replicas | `1` |
| `autoscaling.maxReplicas` | Maximum number of replicas | `100` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```bash
helm install my-demo ./helm/demo --set replicaCount=2
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart:

```bash
helm install my-demo ./helm/demo -f my-values.yaml
```

## Building and Pushing the Docker Image

### Manual Deployment
Before deploying with Helm manually, build and push your Docker image:

```bash
# Build the Spring Boot application
./mvnw clean package

# Build the Docker image
docker build -t your-registry/spring-boot-demo:0.0.1-SNAPSHOT .

# Push to registry
docker push your-registry/spring-boot-demo:0.0.1-SNAPSHOT

# Install with custom image
helm install my-demo ./helm/demo --set image.repository=your-registry/spring-boot-demo --set image.tag=0.0.1-SNAPSHOT
```

### Jenkins Automated Deployment
When using Jenkins (recommended), the pipeline automatically:
- Builds the application with Maven
- Creates Docker image with build number as tag
- Pushes to AWS ECR
- Deploys using Helm with the command:
  ```bash
  helm upgrade --install my-spring-app ./helm/demo \
    --set image.repository=339713053602.dkr.ecr.ap-south-1.amazonaws.com/my-spring-app \
    --set image.tag=${BUILD_NUMBER} \
    --set image.pullPolicy=Always
  ```

## AWS ECR Configuration

This chart is configured for AWS ECR by default. You need to:

1. Create a Kubernetes secret for ECR authentication:
   ```bash
   kubectl create secret docker-registry ecr-registry-secret \
     --docker-server=339713053602.dkr.ecr.ap-south-1.amazonaws.com \
     --docker-username=AWS \
     --docker-password=$(aws ecr get-login-password --region ap-south-1) \
     --namespace=default
   ```

2. The secret is automatically used by the deployment (configured in values.yaml)

**Note**: ECR tokens expire after 12 hours. See [DEPLOYMENT.md](../../DEPLOYMENT.md) for automated token refresh setup.

## Accessing the Application

After installation, follow the instructions provided in the NOTES to access your application.

### Quick Access
```bash
# Port-forward to access locally
kubectl port-forward svc/my-spring-app-demo 8080:80

# Access at: http://localhost:8080
```

## Jenkins Integration

For complete Jenkins setup and deployment instructions, see:
- [DEPLOYMENT.md](../../DEPLOYMENT.md) - Comprehensive deployment guide
- [Jenkinsfile](../../Jenkinsfile) - Jenkins pipeline configuration
