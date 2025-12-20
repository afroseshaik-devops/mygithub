# Spring Boot Demo Application

A demo Spring Boot application with CI/CD pipeline using Jenkins and Kubernetes deployment with Helm.

## 🚀 Quick Start

This repository contains a Spring Boot application that can be automatically built and deployed to Kubernetes using Jenkins and Helm.

### For First-Time Setup
📖 **Read**: [DEPLOYMENT.md](DEPLOYMENT.md) - Complete step-by-step deployment guide

### For Quick Reference
📋 **See**: [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Quick commands and troubleshooting

## 📁 Project Structure

```
.
├── src/                          # Spring Boot application source code
├── helm/                         # Helm chart for Kubernetes deployment
│   └── demo/                     # Helm chart files
│       ├── Chart.yaml           # Chart metadata
│       ├── values.yaml          # Default configuration values
│       ├── templates/           # Kubernetes resource templates
│       └── README.md            # Helm chart documentation
├── Jenkinsfile                  # Jenkins CI/CD pipeline definition
├── Dockerfile                   # Docker image build configuration
├── pom.xml                      # Maven project configuration
├── DEPLOYMENT.md                # Complete deployment documentation
├── QUICK_REFERENCE.md           # Quick reference guide
└── README.md                    # This file
```

## 🔧 Technology Stack

- **Application**: Spring Boot 4.0.0 with Java 17
- **Build Tool**: Maven
- **Container**: Docker
- **Container Registry**: AWS ECR
- **CI/CD**: Jenkins
- **Orchestration**: Kubernetes
- **Package Manager**: Helm 3.x

## 📋 Prerequisites

- Jenkins server with Maven, Java 17, Docker, Helm, and kubectl installed
- Kubernetes cluster (EKS, GKE, AKS, or self-managed)
- AWS ECR repository for Docker images
- AWS credentials configured on Jenkins server

## 🚀 Deployment Process

### Automated Deployment (Jenkins Pipeline)

The Jenkins pipeline automatically:

1. **Checkout** - Clones the repository from GitHub
2. **Build JAR** - Compiles the Spring Boot application using Maven
3. **Build Docker Image** - Creates a Docker image
4. **Login to ECR** - Authenticates with AWS Elastic Container Registry
5. **Push to ECR** - Pushes the image with a unique build number tag
6. **Deploy to Kubernetes** - Deploys to Kubernetes using Helm

### Manual Deployment

```bash
# 1. Build the application
./mvnw clean package

# 2. Build Docker image
docker build -t my-spring-app .

# 3. Tag and push to registry
docker tag my-spring-app:latest <your-registry>/my-spring-app:v1.0.0
docker push <your-registry>/my-spring-app:v1.0.0

# 4. Deploy with Helm
helm upgrade --install my-spring-app ./helm/demo \
  --set image.repository=<your-registry>/my-spring-app \
  --set image.tag=v1.0.0
```

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [DEPLOYMENT.md](DEPLOYMENT.md) | Complete step-by-step deployment guide with prerequisites, setup instructions, and troubleshooting |
| [QUICK_REFERENCE.md](QUICK_REFERENCE.md) | Quick reference for common commands and troubleshooting |
| [helm/demo/README.md](helm/demo/README.md) | Helm chart documentation and configuration options |

## 🎯 Key Features

### Jenkinsfile Updates for Helm

The Jenkinsfile has been updated to support Helm-based Kubernetes deployment:

- ✅ Uses build numbers for image tags (enables version tracking)
- ✅ Deploys to Kubernetes cluster using Helm
- ✅ Automatic rollout with health checks
- ✅ Zero-downtime deployments
- ✅ Easy rollback capabilities

### Benefits Over Previous EC2 Deployment

| Feature | EC2 Docker | Kubernetes + Helm |
|---------|-----------|-------------------|
| Scalability | Manual | Auto-scaling |
| High Availability | Single instance | Multiple replicas |
| Rolling Updates | Downtime | Zero-downtime |
| Rollback | Manual | One command |
| Health Checks | Basic | Liveness & Readiness |
| Load Balancing | Not available | Built-in |

## 🔍 Verification Commands

After deployment, verify the application:

```bash
# Check Helm release
helm list -n default

# Check pods
kubectl get pods -n default -l app.kubernetes.io/name=demo

# View logs
kubectl logs -n default -l app.kubernetes.io/name=demo

# Port-forward to access locally
kubectl port-forward -n default svc/my-spring-app-demo 8080:80

# Access the application
curl http://localhost:8080
```

## 🔄 Rollback

If you need to rollback to a previous version:

```bash
# View release history
helm history my-spring-app -n default

# Rollback to previous version
helm rollback my-spring-app -n default

# Rollback to specific revision
helm rollback my-spring-app <revision-number> -n default
```

## 🛠️ Configuration

### Helm Values

The Helm chart can be customized by modifying `helm/demo/values.yaml` or using `--set` flags:

```bash
helm upgrade --install my-spring-app ./helm/demo \
  --set replicaCount=3 \
  --set resources.limits.memory=512Mi \
  --set ingress.enabled=true
```

### Environment-Specific Values

Create environment-specific value files:

```bash
# Development
helm upgrade --install my-spring-app ./helm/demo -f values-dev.yaml

# Production
helm upgrade --install my-spring-app ./helm/demo -f values-prod.yaml
```

## 🐛 Troubleshooting

For common issues and solutions, see:
- [DEPLOYMENT.md - Troubleshooting Section](DEPLOYMENT.md#troubleshooting)
- [QUICK_REFERENCE.md - Troubleshooting Commands](QUICK_REFERENCE.md#troubleshooting)

### Quick Fixes

**ImagePullBackOff Error:**
```bash
# Refresh ECR token
kubectl delete secret ecr-registry-secret -n default
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=339713053602.dkr.ecr.ap-south-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region ap-south-1) \
  --namespace=default
```

**Pod CrashLoopBackOff:**
```bash
# Check logs
kubectl logs -n default -l app.kubernetes.io/name=demo --previous

# Check events
kubectl get events -n default --sort-by='.lastTimestamp'
```

## 📝 Jenkins Configuration

Required Jenkins tools:
- Maven: `MAVEN3`
- JDK: `JAVA17`

Required Jenkins environment:
- Kubeconfig: `/var/lib/jenkins/.kube/config`
- AWS credentials configured

For detailed Jenkins setup, see [DEPLOYMENT.md](DEPLOYMENT.md).

## 🔐 Security Notes

- ECR authentication tokens expire after 12 hours
- For production, set up automated token refresh (see DEPLOYMENT.md)
- Use Kubernetes Secrets for sensitive data
- Follow the principle of least privilege for IAM roles

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Test locally
4. Submit a pull request

## 📞 Support

For issues or questions:
1. Check the [DEPLOYMENT.md](DEPLOYMENT.md) troubleshooting section
2. Review Jenkins console logs
3. Check Kubernetes pod logs: `kubectl logs -n default -l app.kubernetes.io/name=demo`

## 📄 License

[Add your license information here]

## 📖 Additional Resources

- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Jenkins Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)

---

**Last Updated**: December 2025
