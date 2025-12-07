variable "deploy_to_docker" {
  description = "Whether to deploy services to local Docker engine"
  type        = bool
  default     = true
}

variable "deploy_to_kubernetes" {
  description = "Whether to deploy services to local Kubernetes (Docker Desktop) via Helm"
  type        = bool
  default     = false
}

variable "k8s_context" {
  description = "kubectl context name for Docker Desktop Kubernetes"
  type        = string
  default     = "docker-desktop"
}

variable "k8s_config_path" {
  description = "Path to kubeconfig"
  type        = string
  default     = "~/.kube/config"
}

variable "k8s_namespace" {
  description = "Namespace to deploy Helm charts"
  type        = string
  default     = "observability"
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana (Docker and Helm). If empty, defaults will be used."
  type        = string
  default     = "admin"
  sensitive   = true
}

locals {
  common_labels = {
    "app.kubernetes.io/managed-by" = "terraform"
    "app.kubernetes.io/part-of"    = "observability"
  }
}
