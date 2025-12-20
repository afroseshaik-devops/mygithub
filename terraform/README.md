# Terraform Configuration for My Spring App Helm Chart

This directory contains Terraform configuration files to deploy the Spring Boot application using Helm on a Kubernetes cluster.

## Prerequisites

Before using these Terraform files, ensure you have the following installed:

1. **Terraform** (>= 1.0): [Install Terraform](https://www.terraform.io/downloads.html)
2. **kubectl**: [Install kubectl](https://kubernetes.io/docs/tasks/tools/)
3. **Helm** (>= 3.0): [Install Helm](https://helm.sh/docs/intro/install/)
4. **Access to a Kubernetes cluster** with a valid kubeconfig file

## Directory Structure

```
terraform/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── terraform.tfvars.example   # Example variables file
├── values.yaml.tpl            # Helm values template
└── README.md                  # This file
```

## Configuration Files

### main.tf
Contains the main Terraform configuration including:
- Terraform and provider requirements
- Helm provider configuration
- Helm release resource definition

### variables.tf
Defines all configurable variables:
- Kubernetes configuration (kubeconfig path, context)
- Helm release settings (name, namespace, chart path)
- Application image settings (repository, tag)
- Deployment settings (replicas, resources)
- Service configuration (type, port)
- Optional features (ingress, autoscaling)

### outputs.tf
Defines outputs that will be displayed after deployment:
- Release information (name, namespace, status, version)
- Kubernetes resource names (service, deployment)
- Application URL

## Usage

### 1. Configure Variables

Copy the example variables file and update it with your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` to customize your deployment:

```hcl
# Kubernetes Configuration
kubeconfig_path = "~/.kube/config"
kube_context    = "my-cluster-context"

# Application Configuration
release_name     = "my-spring-app"
namespace        = "production"
image_tag        = "v1.0.0"
replica_count    = 3

# Enable optional features
enable_ingress     = true
ingress_host       = "myapp.example.com"
enable_autoscaling = true
```

### 2. Initialize Terraform

Initialize the Terraform working directory:

```bash
cd terraform
terraform init
```

This will download the required provider plugins (Helm and Kubernetes).

### 3. Plan the Deployment

Preview the changes that Terraform will make:

```bash
terraform plan
```

Review the output to ensure the configuration is correct.

### 4. Apply the Configuration

Deploy the application to your Kubernetes cluster:

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### 5. Verify the Deployment

After successful deployment, verify the resources:

```bash
# Check Helm release
helm list -n production

# Check Kubernetes resources
kubectl get all -n production

# View application logs
kubectl logs -n production -l app.kubernetes.io/name=my-spring-app
```

## Configuration Options

### Image Configuration

```hcl
image_repository = "339713053602.dkr.ecr.ap-south-1.amazonaws.com/my-spring-app"
image_tag        = "latest"
```

### Scaling Configuration

```hcl
# Manual scaling
replica_count = 3

# Or enable autoscaling
enable_autoscaling       = true
autoscaling_min_replicas = 2
autoscaling_max_replicas = 10
```

### Resource Limits

```hcl
cpu_limit      = "500m"
memory_limit   = "512Mi"
cpu_request    = "250m"
memory_request = "256Mi"
```

### Service Configuration

```hcl
service_type = "LoadBalancer"  # Options: ClusterIP, NodePort, LoadBalancer
service_port = 80
```

### Ingress Configuration

```hcl
enable_ingress = true
ingress_host   = "myapp.example.com"
```

Note: Ensure you have an Ingress controller installed in your cluster.

## Outputs

After deployment, Terraform will display:

- **release_name**: Name of the Helm release
- **release_namespace**: Namespace where the app is deployed
- **release_status**: Current status of the release
- **release_version**: Version number of the release
- **chart_version**: Version of the Helm chart used
- **service_name**: Name of the Kubernetes service
- **deployment_name**: Name of the Kubernetes deployment
- **app_url**: URL to access the application

## Updating the Deployment

To update the deployment with new values:

1. Modify `terraform.tfvars` or variables
2. Run `terraform plan` to preview changes
3. Run `terraform apply` to apply changes

Terraform will perform an in-place update of the Helm release.

## Destroying the Deployment

To remove the application from your cluster:

```bash
terraform destroy
```

Type `yes` when prompted to confirm the destruction.

## Advanced Usage

### Using Different Kubernetes Contexts

```bash
terraform apply -var="kube_context=my-cluster"
```

### Deploying with a Specific Image Tag

```bash
terraform apply -var="image_tag=v2.0.0"
```

### Enabling Ingress at Deploy Time

```bash
terraform apply -var="enable_ingress=true" -var="ingress_host=myapp.example.com"
```

## Troubleshooting

### Helm Release Failed

Check the Helm release status:
```bash
helm status my-spring-app -n production
```

View deployment logs:
```bash
kubectl logs -n production -l app.kubernetes.io/name=my-spring-app
```

### Connection Issues

Verify your kubeconfig:
```bash
kubectl config current-context
kubectl cluster-info
```

### Resource Issues

Check if resources are being created:
```bash
kubectl get all -n production
kubectl describe pod <pod-name> -n production
```

## Integration with CI/CD

This Terraform configuration can be integrated into your CI/CD pipeline:

```bash
# In your CI/CD script
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Notes

- The Helm chart is located at `../helm/my-spring-app` relative to this directory
- Default values are configured for AWS ECR in the `ap-south-1` region
- The application exposes port 8080 internally
- LoadBalancer service type is used by default for external access
- All configurations can be overridden via variables

## Support

For issues or questions:
1. Check the Terraform logs: `terraform show`
2. Check Helm release: `helm status my-spring-app`
3. Check Kubernetes events: `kubectl get events -n production`
