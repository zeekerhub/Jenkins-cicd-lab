# CI/CD Pipeline with Jenkins, Docker, Kubernetes, and Terraform

A complete end-to-end CI/CD pipeline that automatically builds, tests, and deploys a containerized Python Flask application to a Kubernetes cluster.

---

## Architecture

```
Developer pushes code to GitHub
        |
GitHub webhook triggers Jenkins
        |
Jenkins Pipeline:
  1. Checkout - Pull code from GitHub
  2. Build and Push - Multi-platform Docker image
  3. Test - Health check
  4. Deploy - kubectl apply to Kubernetes
  5. Cleanup - Remove test containers
        |
Kubernetes runs 3 replicas with self-healing
        |
Prometheus scrapes metrics every 15 seconds
        |
Grafana displays real-time dashboards
```

---

## Tools and Technologies

| Tool | Purpose |
|------|--------|
| Jenkins | CI/CD pipeline automation |
| Docker | Containerization and multi-platform builds |
| Kubernetes | Container orchestration with 3 replicas |
| Terraform | Infrastructure as Code |
| AWS S3 | Terraform remote state storage |
| AWS EC2 | Cloud deployment target |
| Prometheus | Metrics collection and monitoring |
| Grafana | Real-time dashboards |
| GitHub | Source code and webhook triggers |
| DockerHub | Container image registry |

---

## Key Features

### Automated CI/CD Pipeline
- Git push triggers full pipeline via webhook
- Multi-platform Docker builds (ARM64 + AMD64)
- Automated health checks before deployment
- Zero-downtime rolling updates

### Infrastructure as Code
- Terraform provisions EC2 and security groups
- Remote state in S3 prevents duplicates
- Version-controlled infrastructure

### Container Orchestration
- 3 replica pods for high availability
- Self-healing crashed pods
- Rolling updates with zero downtime

### Monitoring
- Custom Prometheus metrics
- Grafana dashboards
- Pod annotations for auto-discovery

---

## Author

**Saheed Bolaji** - DevOps Engineer
