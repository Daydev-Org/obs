output "docker_endpoints" {
  description = "Service endpoints when deploying to Docker"
  value = var.deploy_to_docker ? {
    jaeger_ui   = "http://localhost:16686"
    otlp_grpc   = "localhost:4317"
    otlp_http   = "http://localhost:4318"
    consul_ui   = "http://localhost:8500"
    localstack  = "http://localhost:4566"
    prometheus  = "http://localhost:9090"
    grafana     = "http://localhost:3000"
    mongo       = "mongodb://localhost:27017"
  } : null
}

output "k8s_services_notes" {
  description = "Notes for accessing services in Kubernetes via port-forward"
  value = var.deploy_to_kubernetes ? {
    namespace           = var.k8s_namespace
    jaeger_port_forward = "kubectl -n ${var.k8s_namespace} port-forward svc/jaeger-query 16686:16686"
    consul_port_forward = "kubectl -n ${var.k8s_namespace} port-forward svc/consul-ui 8500:8500"
    localstack_pf       = "kubectl -n ${var.k8s_namespace} port-forward svc/localstack 4566:4566"
    prometheus_pf       = "kubectl -n ${var.k8s_namespace} port-forward svc/kube-prometheus-stack-prometheus 9090:9090"
    grafana_pf          = "kubectl -n ${var.k8s_namespace} port-forward svc/kube-prometheus-stack-grafana 3000:80"
    grafana_admin       = "admin / ${var.grafana_admin_password}"
  } : null
}
