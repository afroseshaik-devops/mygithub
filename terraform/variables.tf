# Kubernetes Configuration
variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Kubernetes context to use"
  type        = string
  default     = ""
}

# Helm Release Configuration
variable "release_name" {
  description = "Name of the Helm release"
  type        = string
  default     = "my-spring-app"
}

variable "namespace" {
  description = "Kubernetes namespace for the deployment"
  type        = string
  default     = "default"
}

variable "create_namespace" {
  description = "Create namespace if it doesn't exist"
  type        = bool
  default     = true
}

variable "chart_path" {
  description = "Path to the Helm chart"
  type        = string
  default     = "../helm/my-spring-app"
}

# Application Image Configuration
variable "image_repository" {
  description = "Docker image repository"
  type        = string
  default     = "339713053602.dkr.ecr.ap-south-1.amazonaws.com/my-spring-app"
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

# Deployment Configuration
variable "replica_count" {
  description = "Number of replicas"
  type        = number
  default     = 2
}

# Service Configuration
variable "service_type" {
  description = "Kubernetes service type (ClusterIP, NodePort, LoadBalancer)"
  type        = string
  default     = "LoadBalancer"
}

variable "service_port" {
  description = "Service port"
  type        = number
  default     = 80
}

# Resource Configuration
variable "cpu_limit" {
  description = "CPU limit for container"
  type        = string
  default     = "500m"
}

variable "memory_limit" {
  description = "Memory limit for container"
  type        = string
  default     = "512Mi"
}

variable "cpu_request" {
  description = "CPU request for container"
  type        = string
  default     = "250m"
}

variable "memory_request" {
  description = "Memory request for container"
  type        = string
  default     = "256Mi"
}

# Ingress Configuration
variable "enable_ingress" {
  description = "Enable ingress for the application"
  type        = bool
  default     = false
}

variable "ingress_host" {
  description = "Ingress host"
  type        = string
  default     = "my-spring-app.local"
}

# Autoscaling Configuration
variable "enable_autoscaling" {
  description = "Enable horizontal pod autoscaling"
  type        = bool
  default     = false
}

variable "autoscaling_min_replicas" {
  description = "Minimum number of replicas for autoscaling"
  type        = number
  default     = 2
}

variable "autoscaling_max_replicas" {
  description = "Maximum number of replicas for autoscaling"
  type        = number
  default     = 10
}
