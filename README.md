# 目录 🌥️

Welcome to the centralized documentation hub for cloud platforms, containerization, Kubernetes operations, security testing, and service APIs.  
This repository serves as a structured knowledge base for infrastructure setup, deployment workflows, and operational practices.


## Cloud Computing Platforms

### Amazon Web Services
Path: `cloud_platforms/aws`

Documentation related to AWS integration and usage.

### DigitalOcean
Path: `cloud_platforms/digitalocean`

- Droplets  
  Setup and operational guides for DigitalOcean Droplets.

### INET (Thailand)
Path: `cloud_platforms/inet`

- Docker Build and Run  
  `docker_build_run.md`

- Web Application Deployment  
  `webapp_deploy.md`

- Infrastructure
  - `infra/minio_deployment.md`
  - `infra/monitoring_prometheus.md`


## Docker

Path: `docker`

### Next.js
Path: `docker/next`

- `comparison.md`  
  Comparison of different Docker approaches for Next.js applications.

- `dockerfile.example`  
  Minimal Dockerfile example.

- `dockerfile.prod`  
  Production-ready Dockerfile.

- `dockerfile.tutorial`  
  Step-by-step Dockerfile tutorial.

- `readme.md`  
  Usage overview and conventions.

#### Troubleshooting
Path: `docker/next/troubleshooting`

- `platform_mismatch.md`
- `pnpm_next_ci.md`
- `slow_docker_builds.md`


## Kubernetes

Path: `k8s`

### Operations and Security

- `k9s_guide.md`  
  Terminal-based Kubernetes UI for daily cluster operations.  
  Covers installation, configuration, and practical usage with kubectl contexts.

- `kube_hunter_guide.md`  
  Kubernetes security scanning guide using kube-hunter.  
  Includes remote scanning, active scanning, and practical execution examples.

- `trivy_guide.md`  
  Comprehensive vulnerability and misconfiguration scanning guide using Trivy.  
  Covers installation, image scanning, filesystem scanning, and Kubernetes security assessment.

## Kubernetes Security Testing

Path: `k8s_security_test`

- `k8s101/k8s02/assessment_report.md`  
  Consolidated Kubernetes security assessment report.

- `k8s101/k8s02/kube_hunter_report.json`  
  Raw kube-hunter scan output in JSON format.


## Service APIs

Path: `service_apis`

### Google Maps
Path: `service_apis/googlemap`

Dynamic and static map integration notes.

### Stripe
Path: `service_apis/stripe`

Payment integration guidelines and references.

### Wasabi
Path: `service_apis/wasabi`

Object storage integration, presigned URLs, and upload workflows.


## Prompts and Conventions

Path: `prompts`

- `git_commit.md`  
  Git commit message format using Conventional Commits.  
  Includes structured examples covering why, what, and breaking changes.
