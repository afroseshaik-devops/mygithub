# Quick Reference: Jenkinsfile Helm Deployment

## Summary of Changes

This repository has been updated to deploy the Spring Boot application to Kubernetes using Helm instead of direct Docker deployment to EC2.

## What Changed?

### 1. Jenkinsfile
- **Removed**: EC2 SSH deployment stage
- **Added**: Kubernetes Helm deployment stage
- **Updated**: Image tags now use build numbers instead of "latest"

### 2. Helm Chart (helm/demo/)
- **Updated**: values.yaml with ECR repository configuration
- **Updated**: README.md with Jenkins integration instructions

### 3. Documentation
- **Added**: DEPLOYMENT.md - Complete step-by-step deployment guide
- **Added**: This quick reference

## Prerequisites Checklist

Before running the Jenkins pipeline, ensure:

- [ ] Jenkins server has Helm 3.x installed
- [ ] Jenkins server has kubectl installed
- [ ] Kubeconfig file exists at `/var/lib/jenkins/.kube/config`
- [ ] AWS credentials configured for Jenkins user
- [ ] Kubernetes cluster is accessible
- [ ] ECR pull secret created in Kubernetes:
  ```bash
  kubectl create secret docker-registry ecr-registry-secret \
    --docker-server=339713053602.dkr.ecr.ap-south-1.amazonaws.com \
    --docker-username=AWS \
    --docker-password=$(aws ecr get-login-password --region ap-south-1) \
    --namespace=default
  ```

## Quick Start

### Option 1: Full Setup (First Time)
Follow the complete guide: [DEPLOYMENT.md](DEPLOYMENT.md)

### Option 2: Quick Deploy (If prerequisites are met)
1. Push code to GitHub
2. Trigger Jenkins build
3. Wait for pipeline to complete
4. Verify deployment:
   ```bash
   kubectl get pods -n default -l app.kubernetes.io/name=demo
   kubectl port-forward -n default svc/my-spring-app-demo 8080:80
   ```
5. Access: http://localhost:8080

## Pipeline Stages

1. **Checkout** - Clone repository from GitHub
2. **Build JAR** - Compile Spring Boot app with Maven
3. **Build Docker Image** - Create Docker image
4. **Login to ECR** - Authenticate with AWS ECR
5. **Push to ECR** - Push image with build number tag
6. **Deploy to Kubernetes with Helm** - Deploy using Helm chart

## Key Commands

### Check Deployment Status
```bash
# List Helm releases
helm list -n default

# Get pods
kubectl get pods -n default -l app.kubernetes.io/name=demo

# Get services
kubectl get svc -n default

# View logs
kubectl logs -n default -l app.kubernetes.io/name=demo --tail=50
```

### Rollback
```bash
# View history
helm history my-spring-app -n default

# Rollback to previous version
helm rollback my-spring-app -n default
```

### Troubleshooting
```bash
# Check pod details
kubectl describe pod -n default -l app.kubernetes.io/name=demo

# Check events
kubectl get events -n default --sort-by='.lastTimestamp'

# Refresh ECR secret (if ImagePullBackOff)
kubectl delete secret ecr-registry-secret -n default
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=339713053602.dkr.ecr.ap-south-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region ap-south-1) \
  --namespace=default
```

## Environment Variables in Jenkinsfile

| Variable | Value | Purpose |
|----------|-------|---------|
| `AWS_REGION` | ap-south-1 | AWS region for ECR |
| `ECR_REPO` | 339713053602.dkr.ecr.ap-south-1.amazonaws.com/my-spring-app | ECR repository URL |
| `IMAGE_TAG` | ${BUILD_NUMBER} | Unique tag for each build |
| `KUBECONFIG` | /var/lib/jenkins/.kube/config | Kubernetes config path |
| `HELM_RELEASE_NAME` | my-spring-app | Helm release name |
| `HELM_NAMESPACE` | default | Kubernetes namespace |

## Comparing Old vs New Deployment

### Old (EC2 Docker)
```bash
ssh to EC2 → docker pull → docker run
```
- Single instance
- Manual scaling
- Downtime during updates
- No built-in health checks

### New (Kubernetes Helm)
```bash
helm upgrade --install → Kubernetes manages deployment
```
- Multiple replicas (configurable)
- Auto-scaling support
- Zero-downtime rolling updates
- Built-in health checks
- Easy rollback

## Need Help?

1. **Full Documentation**: [DEPLOYMENT.md](DEPLOYMENT.md)
2. **Helm Chart Details**: [helm/demo/README.md](helm/demo/README.md)
3. **Troubleshooting**: See DEPLOYMENT.md troubleshooting section
4. **Logs**: Check Jenkins console output and Kubernetes pod logs

## Important Notes

⚠️ **ECR Token Expiration**: ECR authentication tokens expire after 12 hours. For production, set up automated token refresh (instructions in DEPLOYMENT.md).

✅ **Version Tags**: Each build creates a unique image tag using the build number, enabling easy rollback to any previous version.

🔄 **Rolling Updates**: Helm performs zero-downtime deployments by default, gradually replacing old pods with new ones.

---
For detailed information, see [DEPLOYMENT.md](DEPLOYMENT.md)
