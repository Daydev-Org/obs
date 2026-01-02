############################
# Local Docker deployments #
############################

locals {
  docker_labels = merge(local.common_labels, {
    runtime = "docker"
  })
}

################
# Jaeger (AIO) #
################
resource "docker_image" "jaeger" {
  count = var.deploy_to_docker ? 1 : 0
  name  = "jaegertracing/all-in-one:1.57"
}

resource "docker_container" "jaeger" {
  count = var.deploy_to_docker ? 1 : 0
  name  = "obs-jaeger"
  image = docker_image.jaeger[0].name

  labels {
    label = "managed-by"
    value = "terraform"
  }

  # UI
  ports {
    internal = 16686
    external = 16686
  }

  # OTLP gRPC and HTTP
  ports {
    internal = 4317
    external = 4317
  }

  ports {
    internal = 4318
    external = 4318
  }
}

############
# Consul   #
############
resource "docker_image" "consul" {
  count = var.deploy_to_docker ? 1 : 0
  name  = "hashicorp/consul:1.20"
}

resource "docker_container" "consul" {
  count = var.deploy_to_docker ? 1 : 0
  name  = "obs-consul"
  image = docker_image.consul[0].name
  command = [
    "agent",
    "-dev",
    "-client=0.0.0.0",
    "-ui"
  ]

  ports {
    internal = 8500
    external = 8500
  } # Web UI / HTTP API

  ports {
    internal = 8600
    external = 8600
    protocol = "udp"
  } # DNS
}

################
# LocalStack   #
################
resource "docker_image" "localstack" {
  count = var.deploy_to_docker ? 1 : 0
  name  = "localstack/localstack:latest"
}

resource "docker_container" "localstack" {
  count = var.deploy_to_docker ? 1 : 0
  name  = "obs-localstack"
  image = docker_image.localstack[0].name

  env = [
    "DEBUG=0",
    "DOCKER_HOST=unix:///var/run/docker.sock"
  ]

  mounts {
    target = "/var/run/docker.sock"
    source = "/var/run/docker.sock"
    type   = "bind"
  }

  ports {
    internal = 4566
    external = 4566
  }
}

################
# Prometheus   #
################
resource "local_file" "prometheus_config" {
  count    = var.deploy_to_docker ? 1 : 0
  content  = <<-YAML
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    scrape_configs:
      - job_name: "prometheus"
        static_configs:
          - targets: ["host.docker.internal:9091", "host.docker.internal:9092"]
    alerting:
      alertmanagers:
        - static_configs:
            - targets:
            # -alertmanager:9093
      # Load rules once and periodically evaluate them according to the global evaluation intervals
      #rule_files:
      # - "first_rules.yml"
      # - "second_rules.yml"
  YAML
  filename = path.module == null ? "${path.module}/prometheus.yml" : "${path.cwd}/prometheus.yml"
}

resource "docker_image" "prometheus" {
  count = var.deploy_to_docker ? 1 : 0
  name  = "prom/prometheus:v2.55.1"
}

resource "docker_container" "prometheus" {
  count = var.deploy_to_docker ? 1 : 0
  name  = "obs-prometheus"
  image = docker_image.prometheus[0].name

  mounts {
    target = "/etc/prometheus/prometheus.yml"
    source = local_file.prometheus_config[0].filename
    type   = "bind"
    read_only = true
  }

  ports {
    internal = 9090
    external = 9090
  }
}

############
# Grafana   #
############
resource "docker_image" "grafana" {
  count = var.deploy_to_docker ? 1 : 0
  name  = "grafana/grafana-oss:11.2.0"
}

resource "docker_container" "grafana" {
  count = var.deploy_to_docker ? 1 : 0
  name  = "obs-grafana"
  image = docker_image.grafana[0].name

  env = [
    "GF_SECURITY_ADMIN_USER=admin",
    "GF_SECURITY_ADMIN_PASSWORD=${var.grafana_admin_password}"
  ]

  ports {
    internal = 3000
    external = 3000
  }
}

############
# MongoDB  #
############
# resource "docker_image" "mongo" {
#   count = var.deploy_to_docker ? 1 : 0
#   name = "mongo:latest"
# }
#
# resource "docker_container" "mongo" {
#   count = var.deploy_to_docker ? 1 : 0
#   name = "ds-mongodb"
#   image = docker_image.mongo[0].name
#
#   ports {
#     internal = 27017
#     external = 27017
#   }
# }

#############
# ScyllaDB  #
#############
resource "docker_image" "scylla" {
  count = var.deploy_to_docker ? 1 : 0
  name  = "scylladb/scylla:6.2.1"
}

resource "docker_container" "scylla" {
  count = var.deploy_to_docker ? 1 : 0
  name  = "ds-scylladb"
  image = docker_image.scylla[0].name

  ports {
    internal = 9042
    external = 9042
  }
}