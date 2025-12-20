# Kubernetes Deployment with Helm and Terraform

This repository now includes comprehensive Kubernetes deployment configurations using Helm charts and Terraform.

## 📁 Repository Structure

```
.
├── helm/
│   └── my-spring-app/          # Helm chart for the Spring Boot application
│       ├── Chart.yaml          # Chart metadata
│       ├── values.yaml         # Default configuration values
│       ├── templates/          # Kubernetes resource templates
│       └── README.md           # Helm chart documentation
│
├── terraform/                  # Terraform configuration for deploying Helm chart
│   ├── main.tf                # Main Terraform configuration
│   ├── variables.tf           # Variable definitions
│   ├── outputs.tf             # Output definitions
│   ├── terraform.tfvars.example  # Example configuration
│   └── README.md              # Terraform documentation
│
├── src/                       # Spring Boot application source code
├── Dockerfile                 # Docker image configuration
├── Jenkinsfile               # Jenkins CI/CD pipeline
└── pom.xml                   # Maven build configuration
```

## 🚀 Quick Start

### Option 1: Deploy with Helm (Direct)

```bash
# Deploy to Kubernetes cluster
helm install my-spring-app ./helm/my-spring-app

# Deploy with custom values
helm install my-spring-app ./helm/my-spring-app \
  --set image.tag=v1.0.0 \
  --set replicaCount=3
```

### Option 2: Deploy with Terraform (Recommended)

```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Create configuration file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Preview changes
terraform plan

# Deploy
terraform apply
```

## 📦 What's Included

### Helm Chart Features

- **Deployment**: Configurable replica count, resource limits, and health checks
- **Service**: LoadBalancer, NodePort, or ClusterIP options
- **Ingress**: Optional ingress configuration for external access
- **Autoscaling**: Optional Horizontal Pod Autoscaler (HPA)
- **Service Account**: Automatic service account creation
- **Security**: Configurable pod and container security contexts
- **Flexibility**: Extensive configuration options via values.yaml

### Terraform Configuration Features

- **Infrastructure as Code**: Declarative deployment configuration
- **Version Control**: All infrastructure changes tracked in Git
- **Reusability**: Modular design with variables
- **Automation**: Easy integration with CI/CD pipelines
- **State Management**: Terraform state tracking for updates and rollbacks
- **Provider Integration**: Uses official Helm and Kubernetes providers

## 🔧 Configuration

### Key Helm Values

```yaml
# Image configuration
image:
  repository: 339713053602.dkr.ecr.ap-south-1.amazonaws.com/my-spring-app
  tag: "latest"

# Scaling
replicaCount: 2

# Service type
service:
  type: LoadBalancer
  port: 80

# Resources
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi
```

### Key Terraform Variables

```hcl
# Application image
image_repository = "339713053602.dkr.ecr.ap-south-1.amazonaws.com/my-spring-app"
image_tag        = "latest"

# Deployment
replica_count = 3
namespace     = "production"

# Service
service_type = "LoadBalancer"
service_port = 80
```

## 📚 Documentation

Detailed documentation is available in each directory:

- **Helm Chart**: See [helm/my-spring-app/README.md](helm/my-spring-app/README.md)
- **Terraform**: See [terraform/README.md](terraform/README.md)

## 🔄 CI/CD Integration

### Current Jenkins Pipeline

The existing Jenkins pipeline (`Jenkinsfile`) handles:
1. Building the Spring Boot application
2. Creating Docker image
3. Pushing to AWS ECR
4. Deploying to EC2

### Enhanced Deployment Options

You can now extend the pipeline to deploy to Kubernetes:

```groovy
stage('Deploy to Kubernetes') {
    steps {
        sh """
            cd terraform
            terraform init
            terraform apply -auto-approve \
              -var="image_tag=${IMAGE_TAG}"
        """
    }
}
```

Or using Helm directly:

```groovy
stage('Deploy with Helm') {
    steps {
        sh """
            helm upgrade --install my-spring-app ./helm/my-spring-app \
              --set image.tag=${IMAGE_TAG} \
              --namespace production \
              --create-namespace
        """
    }
}
```

## 🌐 Access the Application

### After Deployment with LoadBalancer

```bash
# Get the service external IP
kubectl get svc -n production

# Access the application
curl http://<EXTERNAL-IP>
```

### With Ingress Enabled

```bash
# Access via configured hostname
curl http://my-spring-app.example.com
```

## 🛠️ Common Operations

### Update Image Tag

**With Helm:**
```bash
helm upgrade my-spring-app ./helm/my-spring-app --set image.tag=v2.0.0
```

**With Terraform:**
```bash
terraform apply -var="image_tag=v2.0.0"
```

### Scale Replicas

**With Helm:**
```bash
helm upgrade my-spring-app ./helm/my-spring-app --set replicaCount=5
```

**With Terraform:**
```bash
terraform apply -var="replica_count=5"
```

### Enable Autoscaling

**With Helm:**
```bash
helm upgrade my-spring-app ./helm/my-spring-app \
  --set autoscaling.enabled=true \
  --set autoscaling.minReplicas=2 \
  --set autoscaling.maxReplicas=10
```

**With Terraform:**
```bash
terraform apply \
  -var="enable_autoscaling=true" \
  -var="autoscaling_min_replicas=2" \
  -var="autoscaling_max_replicas=10"
```

## 🔍 Monitoring and Troubleshooting

### Check Deployment Status

```bash
# Helm releases
helm list -n production

# Kubernetes resources
kubectl get all -n production

# Pod logs
kubectl logs -n production -l app.kubernetes.io/name=my-spring-app

# Describe pod
kubectl describe pod <pod-name> -n production
```

### Common Issues

1. **Image Pull Errors**: Ensure AWS ECR credentials are configured
2. **Service Not Accessible**: Check LoadBalancer provisioning or Ingress configuration
3. **Pod CrashLoopBackOff**: Check application logs and resource limits

## 🔐 Security Considerations

- Store sensitive data in Kubernetes Secrets
- Use image pull secrets for private registries
- Configure pod security policies
- Enable RBAC for access control
- Use network policies to restrict traffic
- Keep Terraform state secure (use remote backends)

## 📈 Next Steps

1. **Set up monitoring**: Integrate with Prometheus and Grafana
2. **Configure logging**: Set up centralized logging with ELK or Loki
3. **Implement GitOps**: Use ArgoCD or Flux for automated deployments
4. **Add tests**: Include integration tests in the pipeline
5. **Set up staging**: Create separate environments for testing

## 🤝 Contributing

When making changes:
1. Test Helm chart: `helm lint ./helm/my-spring-app`
2. Validate Terraform: `terraform validate`
3. Test deployment in a dev cluster
4. Update documentation

## 📝 License

This project follows the same license as the main application.
