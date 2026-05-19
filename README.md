CI/CD Pipeline with Jenkins, Docker, Kubernetes, and Terraform
A complete end-to-end CI/CD pipeline that automatically builds, tests, and deploys a containerized Python Flask application to a Kubernetes cluster. Infrastructure is provisioned as code using Terraform with remote state stored in AWS S3.
Architecture
Developer pushes code to GitHub
        |
GitHub webhook triggers Jenkins automatically
        |
Jenkins Pipeline Stages:
  1. Checkout      - Pull latest code from GitHub
  2. Build & Push  - Build multi-platform Docker image (ARM64 + AMD64)
                     Push to DockerHub with build-specific tag
  3. Test          - Pull image, run container, health check /health endpoint
  4. Deploy        - kubectl apply to Kubernetes cluster
                     Rolling update with zero downtime
  5. Cleanup       - Remove local test containers
        |
Kubernetes runs 3 replicas with self-healing
        |
Prometheus scrapes /metrics every 15 seconds
        |
Grafana displays real-time dashboards
Tools and Technologies
ToolPurposeJenkinsCI/CD pipeline automationDockerContainerization and multi-platform buildsKubernetesContainer orchestration with 3 replicasTerraformInfrastructure as Code (AWS EC2, Security Groups)AWS S3Terraform remote state storageAWS EC2Cloud deployment targetPrometheusMetrics collection and monitoringGrafanaReal-time dashboards and visualizationGitHubSource code management and webhook triggersDockerHubContainer image registry
Project Structure
jenkins-cicd-lab/
├── Jenkinsfile            # CI/CD pipeline definition
├── Dockerfile             # Container image build instructions
├── app/
│   ├── app.py             # Flask application with /health and /metrics endpoints
│   └── requirements.txt   # Python dependencies (Flask, prometheus-client)
├── k8s/
│   ├── deployment.yaml    # Kubernetes deployment (3 replicas, Prometheus annotations)
│   └── service.yaml       # Kubernetes service (NodePort on 30001)
└── terraform/
    ├── main.tf            # AWS infrastructure (EC2, Security Group, S3 backend)
    ├── variables.tf       # Configurable variables (region, instance type, AMI)
    └── outputs.tf         # Output values (public IP, app URL, SSH command)
Key Features
Automated CI/CD Pipeline

Every git push triggers a full pipeline run via GitHub webhook
Multi-platform Docker builds for ARM64 and AMD64 architectures
Automated health checks before deployment
Zero-downtime rolling updates on Kubernetes

Infrastructure as Code

Terraform provisions AWS EC2 instances and security groups
Remote state stored in S3 prevents duplicate infrastructure
Infrastructure is version-controlled and reproducible

Container Orchestration

3 replica pods for high availability
Self-healing: crashed pods are automatically replaced
Rolling updates: app is never offline during deployments

Monitoring and Observability

Custom Prometheus metrics (request count, response time)
/metrics endpoint for Prometheus scraping
Grafana dashboards for real-time visibility
Pod annotations for automatic service discovery

How to Run
Prerequisites

Docker Desktop
Jenkins (Homebrew: brew install jenkins-lts)
Kubernetes (Minikube: brew install minikube)
Terraform (brew install hashicorp/tap/terraform)
AWS CLI with configured credentials
Helm (brew install helm)

Quick Start

Clone the repository:

bashgit clone https://github.com/zeekerhub/Jenkins-cicd-lab.git
cd Jenkins-cicd-lab

Build and run locally:

bashdocker build -t jenkins-lab:local .
docker run -d -p 5001:5001 jenkins-lab:local
curl http://localhost:5001/health

Deploy to Kubernetes:

bashminikube start
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
minikube service jenkins-lab-service

Install monitoring:

bashhelm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set grafana.adminPassword=admin
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
Pipeline Stages Explained
StageWhat it doesWhy it mattersCheckoutPulls code from GitHubEnsures latest code is always usedBuild and PushCreates multi-platform Docker imageWorks on ARM (Mac) and AMD (cloud servers)TestRuns container and hits /healthCatches broken builds before deploymentDeploykubectl apply with rolling updateZero downtime: pods replaced one at a timeCleanupRemoves test containersPrevents resource waste on build server
Credentials Management
All secrets are stored in Jenkins credentials store and never in code:

dockerhub-credentials — DockerHub access token
aws-credentials — AWS access keys for Terraform
ec2-ssh-key — SSH private key for EC2 deployment

Author
Saheed Bolaji — Built as part of a hands-on DevOps learning journey covering Jenkins, Docker, AWS, Terraform, Kubernetes, and monitoring.# Jenkins-cicd-lab# My CI/CD Lab
# My CI/CD Lab
