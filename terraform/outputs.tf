output "release_name" {
  description = "Name of the Helm release"
  value       = helm_release.my_spring_app.name
}

output "release_namespace" {
  description = "Namespace of the Helm release"
  value       = helm_release.my_spring_app.namespace
}

output "release_status" {
  description = "Status of the Helm release"
  value       = helm_release.my_spring_app.status
}

output "release_version" {
  description = "Version of the Helm release"
  value       = helm_release.my_spring_app.version
}

output "chart_version" {
  description = "Version of the deployed chart"
  value       = helm_release.my_spring_app.chart
}

output "service_name" {
  description = "Name of the Kubernetes service"
  value       = "${var.release_name}-my-spring-app"
}

output "deployment_name" {
  description = "Name of the Kubernetes deployment"
  value       = "${var.release_name}-my-spring-app"
}

output "app_url" {
  description = "Application URL (if using LoadBalancer or Ingress)"
  value       = var.enable_ingress ? "http://${var.ingress_host}" : "Access via LoadBalancer IP"
}
