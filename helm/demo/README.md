# Demo Spring Boot Application Helm Chart

This Helm chart deploys the Spring Boot demo application to Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Docker image built and available in a registry

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
| `image.repository` | Image repository | `demo` |
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

Before deploying with Helm, build and push your Docker image:

```bash
# Build the Spring Boot application
./mvnw clean package

# Build the Docker image
docker build -t your-registry/demo:0.0.1-SNAPSHOT .

# Push to registry
docker push your-registry/demo:0.0.1-SNAPSHOT

# Install with custom image
helm install my-demo ./helm/demo --set image.repository=your-registry/demo --set image.tag=0.0.1-SNAPSHOT
```

## Accessing the Application

After installation, follow the instructions provided in the NOTES to access your application.
