terraform {
  required_version = ">= 1.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
  }
}

provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kube_context
}

provider "helm" {
  kubernetes {
    config_path    = var.kubeconfig_path
    config_context = var.kube_context
  }
}

resource "helm_release" "my_spring_app" {
  name             = var.release_name
  chart            = var.chart_path
  namespace        = var.namespace
  create_namespace = var.create_namespace

  values = [
    templatefile("${path.module}/${var.values_file}", {
      image_repository = var.image_repository
      image_tag        = var.image_tag
      replica_count    = var.replica_count
      service_type     = var.service_type
      service_port     = var.service_port
      cpu_limit        = var.cpu_limit
      memory_limit     = var.memory_limit
      cpu_request      = var.cpu_request
      memory_request   = var.memory_request
    })
  ]

  set {
    name  = "image.repository"
    value = var.image_repository
  }

  set {
    name  = "image.tag"
    value = var.image_tag
  }

  set {
    name  = "replicaCount"
    value = var.replica_count
  }

  set {
    name  = "service.type"
    value = var.service_type
  }

  set {
    name  = "service.port"
    value = var.service_port
  }

  # Resource limits
  set {
    name  = "resources.limits.cpu"
    value = var.cpu_limit
  }

  set {
    name  = "resources.limits.memory"
    value = var.memory_limit
  }

  set {
    name  = "resources.requests.cpu"
    value = var.cpu_request
  }

  set {
    name  = "resources.requests.memory"
    value = var.memory_request
  }

  # Optional ingress configuration
  dynamic "set" {
    for_each = var.enable_ingress ? [1] : []
    content {
      name  = "ingress.enabled"
      value = "true"
    }
  }

  dynamic "set" {
    for_each = var.enable_ingress ? [1] : []
    content {
      name  = "ingress.hosts[0].host"
      value = var.ingress_host
    }
  }

  # Optional autoscaling configuration
  dynamic "set" {
    for_each = var.enable_autoscaling ? [1] : []
    content {
      name  = "autoscaling.enabled"
      value = "true"
    }
  }

  dynamic "set" {
    for_each = var.enable_autoscaling ? [1] : []
    content {
      name  = "autoscaling.minReplicas"
      value = var.autoscaling_min_replicas
    }
  }

  dynamic "set" {
    for_each = var.enable_autoscaling ? [1] : []
    content {
      name  = "autoscaling.maxReplicas"
      value = var.autoscaling_max_replicas
    }
  }

  timeout = 600
  wait    = true

  depends_on = []
}
