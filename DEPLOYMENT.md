# Deployment Guide: Spring Boot Application with Jenkins and Helm

This guide provides step-by-step instructions for deploying the Spring Boot application to Kubernetes using Jenkins CI/CD pipeline and Helm package manager.

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Architecture](#architecture)
- [Step-by-Step Deployment Guide](#step-by-step-deployment-guide)
- [Jenkinsfile Changes for Helm](#jenkinsfile-changes-for-helm)
- [Troubleshooting](#troubleshooting)
- [Rollback Procedure](#rollback-procedure)

## Overview

The deployment pipeline has been updated to use Helm for Kubernetes deployments instead of direct Docker deployment to EC2. This provides better scalability, reliability, and follows Kubernetes best practices.

### Key Changes from Previous Setup:
- **Before**: Direct Docker deployment to EC2 instance
- **After**: Helm-based deployment to Kubernetes cluster

## Prerequisites

### 1. Jenkins Server Requirements
- Jenkins server with the following plugins installed:
  - Pipeline Plugin
  - Git Plugin
  - Docker Pipeline Plugin
  - Kubernetes CLI Plugin (optional but recommended)

### 2. Required Tools on Jenkins Server
```bash
# Maven 3.x
mvn --version

# Java 17
java -version

# Docker
docker --version

# AWS CLI
aws --version

# Helm 3.x
helm version

# kubectl
kubectl version --client
```

### 3. Kubernetes Cluster
- A running Kubernetes cluster (EKS, GKE, AKS, or self-managed)
- Cluster admin access for initial setup
- Kubeconfig file configured on Jenkins server at `/var/lib/jenkins/.kube/config`

### 4. AWS ECR Access
- AWS credentials configured on Jenkins server
- ECR repository created: `339713053602.dkr.ecr.ap-south-1.amazonaws.com/my-spring-app`
- Appropriate IAM permissions for ECR push/pull

### 5. Kubernetes Secret for ECR Authentication
Create a Kubernetes secret for pulling images from ECR:
```bash
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=339713053602.dkr.ecr.ap-south-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region ap-south-1) \
  --namespace=default
```

**Note**: ECR tokens expire after 12 hours. For production, use one of these solutions:
- AWS IAM Roles for Service Accounts (IRSA) - Recommended for EKS
- Automated secret refresh via CronJob
- Use aws-ecr-credential-helper

## Architecture

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐      ┌──────────────────┐
│  Developer  │─────>│    GitHub    │─────>│   Jenkins   │─────>│   AWS ECR        │
│   (Git)     │      │  Repository  │      │   Pipeline  │      │  (Container      │
└─────────────┘      └──────────────┘      └─────────────┘      │   Registry)      │
                                                   │              └──────────────────┘
                                                   │                       │
                                                   ▼                       │
                                            ┌──────────────┐              │
                                            │  Helm Chart  │              │
                                            │  Deployment  │              │
                                            └──────────────┘              │
                                                   │                       │
                                                   ▼                       │
                                            ┌──────────────────────────────▼──┐
                                            │     Kubernetes Cluster           │
                                            │  ┌────────────────────────────┐  │
                                            │  │  Pods (Spring Boot App)    │  │
                                            │  └────────────────────────────┘  │
                                            │  ┌────────────────────────────┐  │
                                            │  │  Service (LoadBalancer)    │  │
                                            │  └────────────────────────────┘  │
                                            └──────────────────────────────────┘
```

## Step-by-Step Deployment Guide

### Step 1: Prepare Jenkins Server

#### 1.1 Install Required Tools
```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify Helm installation
helm version

# Install kubectl (if not already installed)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify kubectl installation
kubectl version --client
```

#### 1.2 Configure Kubernetes Access
```bash
# Create .kube directory for Jenkins user
sudo mkdir -p /var/lib/jenkins/.kube

# Copy your kubeconfig file
sudo cp ~/.kube/config /var/lib/jenkins/.kube/config

# Set proper permissions
sudo chown jenkins:jenkins /var/lib/jenkins/.kube/config
sudo chmod 600 /var/lib/jenkins/.kube/config

# Verify access as Jenkins user
sudo -u jenkins kubectl get nodes
```

#### 1.3 Configure AWS Credentials
```bash
# Configure AWS CLI for Jenkins user
sudo -u jenkins aws configure
# Enter: AWS Access Key ID
# Enter: AWS Secret Access Key
# Enter: Default region (ap-south-1)
# Enter: Default output format (json)

# Verify ECR access
sudo -u jenkins aws ecr describe-repositories --region ap-south-1
```

### Step 2: Set Up Kubernetes Cluster

#### 2.1 Create Namespace (Optional)
```bash
kubectl create namespace default  # or your preferred namespace
```

#### 2.2 Create ECR Pull Secret
```bash
# Create the secret for pulling images from ECR
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=339713053602.dkr.ecr.ap-south-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region ap-south-1) \
  --namespace=default

# Verify the secret
kubectl get secret ecr-registry-secret -n default
```

#### 2.3 Set Up Automated ECR Token Refresh (Recommended for Production)
Create a CronJob to refresh the ECR token every 10 hours:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: ecr-token-refresh
  namespace: default
spec:
  schedule: "0 */10 * * *"  # Every 10 hours
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: ecr-token-refresh
          containers:
          - name: refresh-token
            image: amazon/aws-cli:latest
            command:
            - /bin/sh
            - -c
            - |
              TOKEN=\$(aws ecr get-login-password --region ap-south-1)
              kubectl delete secret ecr-registry-secret --ignore-not-found
              kubectl create secret docker-registry ecr-registry-secret \
                --docker-server=339713053602.dkr.ecr.ap-south-1.amazonaws.com \
                --docker-username=AWS \
                --docker-password=\$TOKEN
          restartPolicy: OnFailure
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ecr-token-refresh
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ecr-token-refresh
  namespace: default
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "create", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ecr-token-refresh
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ecr-token-refresh
subjects:
- kind: ServiceAccount
  name: ecr-token-refresh
EOF
```

### Step 3: Configure Jenkins Pipeline

#### 3.1 Configure Jenkins Tools
1. Go to Jenkins → Manage Jenkins → Global Tool Configuration
2. Configure Maven:
   - Name: `MAVEN3`
   - Install automatically or point to existing Maven installation
3. Configure JDK:
   - Name: `JAVA17`
   - Install automatically or point to existing Java 17 installation

#### 3.2 Create Jenkins Pipeline Job
1. Go to Jenkins Dashboard → New Item
2. Enter job name (e.g., "spring-boot-helm-deployment")
3. Select "Pipeline" and click OK
4. Under Pipeline section:
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: `https://github.com/afroseshaik-devops/mygithub.git`
   - Branch: `*/master` (or your preferred branch)
   - Script Path: `Jenkinsfile`
5. Save the configuration

### Step 4: Run the Deployment

#### 4.1 Trigger Jenkins Pipeline
1. Go to your Jenkins job
2. Click "Build Now"
3. Monitor the build progress in Console Output

#### 4.2 Pipeline Stages
The pipeline will execute the following stages:
1. **Checkout**: Clones the repository from GitHub
2. **Build JAR**: Compiles the Spring Boot application using Maven
3. **Build Docker Image**: Creates a Docker image from the JAR file
4. **Login to ECR**: Authenticates with AWS ECR
5. **Push to ECR**: Pushes the Docker image to ECR with build number as tag
6. **Deploy to Kubernetes with Helm**: Deploys the application using Helm

### Step 5: Verify Deployment

#### 5.1 Check Helm Release
```bash
# List Helm releases
helm list -n default

# Get release details
helm status my-spring-app -n default

# View release history
helm history my-spring-app -n default
```

#### 5.2 Check Kubernetes Resources
```bash
# Check pods
kubectl get pods -n default -l app.kubernetes.io/name=demo

# Check pod logs
kubectl logs -n default -l app.kubernetes.io/name=demo --tail=100

# Check service
kubectl get svc -n default -l app.kubernetes.io/name=demo

# Check deployment
kubectl get deployment -n default

# Describe pod for detailed information
kubectl describe pod -n default -l app.kubernetes.io/name=demo
```

#### 5.3 Access the Application
```bash
# If using ClusterIP (default), port-forward to access locally
kubectl port-forward -n default svc/my-spring-app-demo 8080:80

# Then access at: http://localhost:8080

# If service type is LoadBalancer, get external IP
kubectl get svc -n default my-spring-app-demo
# Access using the EXTERNAL-IP shown
```

### Step 6: Optional - Enable Ingress (For Production)

#### 6.1 Update Helm Values
Create a custom values file `values-prod.yaml`:
```yaml
ingress:
  enabled: true
  className: "nginx"  # or your ingress controller
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"  # if using cert-manager
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: myapp-tls
      hosts:
        - myapp.example.com

service:
  type: ClusterIP  # Use ClusterIP when ingress is enabled
```

#### 6.2 Update Jenkinsfile for Custom Values
Modify the Helm upgrade command in Jenkinsfile:
```groovy
helm upgrade --install ${HELM_RELEASE_NAME} ./helm/demo \
    --namespace ${HELM_NAMESPACE} \
    --create-namespace \
    --set image.repository=${ECR_REPO} \
    --set image.tag=${IMAGE_TAG} \
    --set image.pullPolicy=Always \
    -f ./helm/demo/values-prod.yaml \
    --wait \
    --timeout 5m
```

## Jenkinsfile Changes for Helm

### Summary of Changes Made

#### 1. Updated Environment Variables
**Before:**
```groovy
IMAGE_TAG = "latest"
DEPLOY_SERVER = "ec2-user@3.109.210.15"
KEY_PATH = "/var/lib/jenkins/.ssh/jenkins-key.pem"
```

**After:**
```groovy
IMAGE_TAG = "${BUILD_NUMBER}"  // Uses unique build number
KUBECONFIG = "/var/lib/jenkins/.kube/config"
HELM_RELEASE_NAME = "my-spring-app"
HELM_NAMESPACE = "default"
```

**Rationale:**
- Using build number for image tags enables better version tracking and rollback
- KUBECONFIG path is required for kubectl/helm commands
- Helm release name and namespace are parameterized for flexibility

#### 2. Replaced EC2 Deployment with Helm Deployment
**Before:**
```groovy
stage('Deploy to EC2') {
    steps {
        sh """
            ssh -o StrictHostKeyChecking=no -i $KEY_PATH $DEPLOY_SERVER << 'EOF'
            aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin $ECR_REPO
            docker pull $ECR_REPO:$IMAGE_TAG
            docker stop app || true
            docker rm app || true
            docker run -d --name app -p 8080:8080 $ECR_REPO:$IMAGE_TAG
            EOF
        """
    }
}
```

**After:**
```groovy
stage('Deploy to Kubernetes with Helm') {
    steps {
        script {
            sh """
                # Ensure Helm is installed
                helm version
                
                # Deploy or upgrade the application using Helm
                helm upgrade --install ${HELM_RELEASE_NAME} ./helm/demo \
                    --namespace ${HELM_NAMESPACE} \
                    --create-namespace \
                    --set image.repository=${ECR_REPO} \
                    --set image.tag=${IMAGE_TAG} \
                    --set image.pullPolicy=Always \
                    --wait \
                    --timeout 5m
                
                # Display deployment status
                kubectl get pods -n ${HELM_NAMESPACE} -l app.kubernetes.io/name=demo
                kubectl get svc -n ${HELM_NAMESPACE} -l app.kubernetes.io/name=demo
            """
        }
    }
}
```

**Rationale:**
- `helm upgrade --install`: Installs if not exists, upgrades if exists (idempotent)
- `--create-namespace`: Automatically creates namespace if it doesn't exist
- `--set` flags: Override values.yaml with dynamic values from Jenkins
- `--wait`: Ensures deployment completes before marking stage successful
- `--timeout 5m`: Fails the build if deployment takes longer than 5 minutes
- Post-deployment commands verify the deployment status

#### 3. Benefits of Helm Over Direct Docker Deployment

| Aspect | EC2 Docker Deployment | Helm Kubernetes Deployment |
|--------|----------------------|---------------------------|
| **Scalability** | Manual scaling | Auto-scaling with HPA |
| **High Availability** | Single instance | Multiple replicas across nodes |
| **Rolling Updates** | Downtime required | Zero-downtime deployments |
| **Rollback** | Manual | `helm rollback` |
| **Health Checks** | Basic | Liveness & Readiness probes |
| **Configuration** | Environment variables | ConfigMaps and Secrets |
| **Service Discovery** | IP address | Kubernetes Service |
| **Load Balancing** | Not available | Automatic |

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: Helm Command Not Found
**Error:** `helm: command not found`

**Solution:**
```bash
# Install Helm on Jenkins server
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
# Verify installation
helm version
```

#### Issue 2: Unable to Connect to Kubernetes Cluster
**Error:** `The connection to the server localhost:8080 was refused`

**Solution:**
```bash
# Verify kubeconfig exists
ls -la /var/lib/jenkins/.kube/config

# Check permissions
sudo chown jenkins:jenkins /var/lib/jenkins/.kube/config
sudo chmod 600 /var/lib/jenkins/.kube/config

# Test connection
sudo -u jenkins kubectl get nodes
```

#### Issue 3: ImagePullBackOff Error
**Error:** `Failed to pull image: authentication required`

**Solution:**
```bash
# Recreate ECR pull secret with fresh token
kubectl delete secret ecr-registry-secret -n default
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=339713053602.dkr.ecr.ap-south-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region ap-south-1) \
  --namespace=default

# Restart deployment
kubectl rollout restart deployment -n default -l app.kubernetes.io/name=demo
```

#### Issue 4: Helm Upgrade Timeout
**Error:** `Error: timed out waiting for the condition`

**Solution:**
```bash
# Check pod status
kubectl get pods -n default -l app.kubernetes.io/name=demo

# Check pod logs
kubectl logs -n default -l app.kubernetes.io/name=demo --tail=50

# Check events
kubectl get events -n default --sort-by='.lastTimestamp'

# Describe pod for details
kubectl describe pod -n default -l app.kubernetes.io/name=demo
```

#### Issue 5: Application Not Starting
**Error:** Pod in `CrashLoopBackOff` state

**Solution:**
```bash
# Check application logs
kubectl logs -n default -l app.kubernetes.io/name=demo --previous

# Common causes:
# 1. Wrong container port (should be 8080)
# 2. Missing dependencies
# 3. Configuration issues

# Update Helm values if needed
helm upgrade my-spring-app ./helm/demo \
  --set service.targetPort=8080 \
  --reuse-values
```

#### Issue 6: Cannot Access Application
**Error:** Cannot reach application URL

**Solution:**
```bash
# Check service
kubectl get svc -n default

# For ClusterIP service, use port-forward
kubectl port-forward -n default svc/my-spring-app-demo 8080:80

# For LoadBalancer, wait for external IP
kubectl get svc -n default -w

# Check ingress (if enabled)
kubectl get ingress -n default
kubectl describe ingress -n default
```

## Rollback Procedure

### Option 1: Helm Rollback (Recommended)
```bash
# View release history
helm history my-spring-app -n default

# Rollback to previous revision
helm rollback my-spring-app -n default

# Rollback to specific revision
helm rollback my-spring-app 3 -n default

# Verify rollback
helm status my-spring-app -n default
kubectl get pods -n default -l app.kubernetes.io/name=demo
```

### Option 2: Deploy Previous Image Tag
```bash
# Redeploy with previous build number
helm upgrade my-spring-app ./helm/demo \
  --set image.tag=<previous-build-number> \
  --reuse-values \
  -n default
```

### Option 3: Jenkins Build Rollback
1. Go to Jenkins job
2. Find the successful previous build
3. Click "Replay" or "Rebuild"
4. This will redeploy the previous version

## Best Practices

### 1. Version Control
- Always use specific image tags (build numbers) instead of `latest`
- Tag images with semantic versioning for production releases

### 2. Environment Management
- Use separate Helm values files for different environments
  - `values-dev.yaml`
  - `values-staging.yaml`
  - `values-prod.yaml`

### 3. Resource Limits
- Always define resource requests and limits:
```yaml
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi
```

### 4. Health Checks
- Configure appropriate liveness and readiness probes
- Use Spring Boot Actuator endpoints for health checks

### 5. Secrets Management
- Never commit secrets to Git
- Use Kubernetes Secrets or external secret management (e.g., AWS Secrets Manager)
- Rotate credentials regularly

### 6. Monitoring
- Set up monitoring with Prometheus and Grafana
- Configure alerting for application and infrastructure metrics
- Use centralized logging (e.g., ELK stack, CloudWatch)

### 7. Backup
- Regularly backup Helm releases: `helm get values my-spring-app -n default > backup.yaml`
- Backup persistent volumes if using stateful services

## Additional Resources

- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Jenkins Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [Spring Boot Kubernetes Guide](https://spring.io/guides/gs/spring-boot-kubernetes/)

## Support

For issues or questions:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review Jenkins console logs
3. Check Kubernetes pod logs: `kubectl logs -n default -l app.kubernetes.io/name=demo`
4. Contact the DevOps team

---

**Last Updated**: 2025-12-20
**Version**: 1.0.0
