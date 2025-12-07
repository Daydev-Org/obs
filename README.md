# Obs — Local Observability Stack with Terraform

This project provisions a local observability/dev stack on your machine using Terraform. You can deploy to either:
- Local Docker engine (containers), or
- Local Kubernetes on Docker Desktop (via Helm)

Included services:
- Jaeger (all-in-one)
- Consul (dev + UI)
- LocalStack
- Prometheus
- Grafana
- MongoDB

## Prerequisites
- Terraform 1.5+
- Docker Desktop (with Docker engine; Kubernetes optional if you want K8s mode)
- kubectl (for K8s mode)

## Project layout
```
main.tf              # Providers
variables.tf         # Input variables and common labels
docker_services.tf   # Docker resources (images/containers)
k8s_services.tf      # Helm releases for Kubernetes mode
outputs.tf           # Helpful endpoints and port-forward commands
vault.tf             # Example Vault in Docker (independent of toggles)
```

## Configuration
Variables (with defaults) are defined in `variables.tf`:
- `deploy_to_docker` (bool): default `true`
- `deploy_to_kubernetes` (bool): default `false`
- `k8s_context` (string): default `docker-desktop`
- `k8s_config_path` (string): default `~/.kube/config`
- `k8s_namespace` (string): default `observability`
- `grafana_admin_password` (string, sensitive): default `admin`

## Usage
Initialize providers:
```
terraform init
```

Deploy to Docker (default):
```
terraform apply -auto-approve \
  -var deploy_to_docker=true \
  -var deploy_to_kubernetes=false
```

Deploy to Kubernetes (Docker Desktop):
```
terraform apply -auto-approve \
  -var deploy_to_docker=false \
  -var deploy_to_kubernetes=true \
  -var k8s_context=docker-desktop \
  -var k8s_namespace=observability
```

### Accessing services
Docker mode (direct):
- Jaeger UI: http://localhost:16686
- Consul UI: http://localhost:8500
- LocalStack: http://localhost:4566
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin / your password)
- MongoDB: mongodb://localhost:27017

Kubernetes mode (port-forward examples):
```
kubectl -n observability port-forward svc/jaeger-query 16686:16686
kubectl -n observability port-forward svc/consul-ui 8500:8500
kubectl -n observability port-forward svc/localstack 4566:4566
kubectl -n observability port-forward svc/kube-prometheus-stack-prometheus 9090:9090
kubectl -n observability port-forward svc/kube-prometheus-stack-grafana 3000:80
```

## Troubleshooting
### Docker API version error
Error example:
```
Unable to read Docker image into resource: unable to list Docker images: Error response from daemon: client version 1.41 is too old
```
Fix:
1. Unset `DOCKER_API_VERSION` so the client can negotiate with the daemon:
   - macOS/Linux: `unset DOCKER_API_VERSION`
   - PowerShell: `Remove-Item Env:DOCKER_API_VERSION`
2. Upgrade provider plugins:
   - `terraform init -upgrade`
3. If needed, set `DOCKER_API_VERSION` to match your daemon (see `docker version`).

If not working, try setting version as follows:
```
docker = {
    source  = "kreuzwerker/docker"
    version = "~> 3.6.2"
}
```

### Kubernetes context
Ensure `kubectl config current-context` matches `var.k8s_context` (default `docker-desktop`). Adjust via `-var k8s_context=...`.

### Prometheus config (Docker mode)
A minimal `prometheus.yml` is generated and bind-mounted. Add scrape jobs as needed in that file after first apply, then `terraform apply` again.

## Cleanup
Destroy resources created by Terraform:
```
terraform destroy -auto-approve
```

## License
This project is licensed under the GNU General Public License v3.0 (GPLv3). See `LICENSE` for details.
