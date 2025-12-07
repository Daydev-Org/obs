terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.6.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

provider "docker" {
}

# Kubernetes (Docker Desktop) provider
provider "kubernetes" {
  config_path = var.k8s_config_path
  config_context = var.k8s_context
}

# Helm provider for installing charts into local Kubernetes
provider "helm" {
  kubernetes {
    config_path    = var.k8s_config_path
    config_context = var.k8s_context
  }
}