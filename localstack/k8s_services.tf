###############################
# Kubernetes (Docker Desktop) #
###############################

################
# Helm Releases #
################

# Jaeger (all-in-one)
resource "helm_release" "jaeger" {
  count      = var.deploy_to_kubernetes ? 1 : 0
  name       = "jaeger"
  repository = "https://jaegertracing.github.io/helm-charts"
  chart      = "jaeger"
  namespace  = var.k8s_namespace
  create_namespace = true

  values = [
    yamlencode({
      allInOne = {
        enabled = true
      }
      provisionDataStore = {
        cassandra = false
        elasticsearch = false
      }
    })
  ]
}

# Consul (dev)
resource "helm_release" "consul" {
  count      = var.deploy_to_kubernetes ? 1 : 0
  name       = "consul"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  namespace  = var.k8s_namespace
  create_namespace = true

  values = [
    yamlencode({
      global = {
        name = "consul"
      }
      server = {
        replicas = 1
      }
      ui = {
        enabled = true
      }
      connectInject = {
        enabled = false
      }
    })
  ]
}

# LocalStack
resource "helm_release" "localstack" {
  count      = var.deploy_to_kubernetes ? 1 : 0
  name       = "localstack"
  repository = "https://charts.localstack.cloud"
  chart      = "localstack"
  namespace  = var.k8s_namespace
  create_namespace = true

  values = [
    yamlencode({
      service = {
        type = "ClusterIP"
        ports = [{
          name       = "edge"
          port       = 4566
          targetPort = 4566
          protocol   = "TCP"
        }]
      }
      startServices = ["s3", "sqs", "sns"]
      persistence = {
        enabled = false
      }
    })
  ]
}

# Prometheus + Grafana (kube-prometheus-stack)
resource "helm_release" "kube_prometheus_stack" {
  count      = var.deploy_to_kubernetes ? 1 : 0
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = var.k8s_namespace
  create_namespace = true

  values = [
    yamlencode({
      grafana = {
        adminPassword = var.grafana_admin_password
      }
    })
  ]
}

# MongoDB
# resource "kubernetes_namespace" "mongo" {
#   metadata {
#     name = "ds-mongodb"
#   }
# }
#
# resource "helm_release" "mongo" {
#   name       = "mongo"
#   namespace  = kubernetes_namespace.mongo.metadata[0].name
#   chart      = "mongo"
#   repository = "https://charts.bitnami.com/bitnami"
#   version    = "15.6.5"
#
#   values = [
#     yamlencode({
#       architecture = "replicaset"
#
#       # Default username / password
#       auth = {
#         rootPassword = "Dummy!"
#         username     = "appuser"
#         password     = "AppUserPassword123!"
#         database     = "app"
#       }
#
#       persistence = {
#         enabled = true
#         size    = "8Gi"
#       }
#
#       resources = {
#         limits = {
#           cpu    = "500m"
#           memory = "1Gi"
#         }
#         requests = {
#           cpu    = "250m"
#           memory = "512Mi"
#         }
#       }
#
#       service = {
#         type = "ClusterIP"
#         port = 27017
#       }
#     })
#   ]
# }


