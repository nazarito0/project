# End-to-End DevOps Project: Self-Hosted GitOps Infrastructure

**1. Project summary**

**One-liner:** A comprehensive GitOps platform based on **ArgoCD** in a **Kubernetes** cluster, built using **Ansible**, an automated CI pipeline **Jenkins**, and monitoring via **VictoriaMetrics**.

**Мета:** Implement the full software delivery lifecycle in an on-premises environment using **Ansible** for infrastructure preparation, **Jenkins** for code build and verification, **Kubernetes** for service launch, **ArgoCD** for deployment automation, and **VictoriaMetrics** for deep visibility into system health.

**2. Technological stack**

| Sphere | Tools |
| --- | --- |
| Infrastructure (IaC) | Vagrant, Ansible |
| Orchestration | Kubernetes (Minikube) |
| Containerization | Docker |
| CI/CD / GitOps | Jenkins, ArgoCD, Helm |
| Observability | VictoriaMetrics, VictoriaLogs, Grafana |
| Security/Quality | SonarQube |
| Networking | HAProxy, Ingress Controller |
| Database | PostgreSQL (with PVC) |

**Architecture Overview**

The platform consists of five logical layers:

- Infrastructure Layer (Vagrant + Ansible)
- CI Layer (Jenkins + SonarQube)
- GitOps Layer (ArgoCD + Helm)
- Runtime Layer (Kubernetes + PostgreSQL)
- Observability Layer (VictoriaMetrics + Grafana)

**3. Implementation description**

The infrastructure is deployed in VirtualBox.

Infrastructure & Networking

 - Vagrant creates three virtual machines in a private network and assigns them IP addresses (Jenkins, Ansible, Slave).

 - Ansible automates configuration: installing Docker, Minikube, etc.

 - A two-tier load balancing scheme is configured. External traffic is accepted by HAProxy at the virtual machine level and redirected to the Ingress Controller inside the Kubernetes cluster. This allows for flexible routing management and access to services by domain names (argocd.local, grafana.local, etc.).

CI Pipeline (Jenkins & SonarQube)

 - The pipeline is implemented through Jenkins using SCM Polling to respond to code changes, without manual intervention.

 - Each build is analyzed in SonarQube.

 - Quality Gates are configured: if the code does not meet security or quality standards, the pipeline stops, blocking the Docker image push. This ensures stable releases.

Delivery & GitOps (ArgoCD & Helm)

 - The deployment is implemented using the GitOps concept.

 - ArgoCD tracks the status of Helm charts in a Git repository.

 - If the configuration in the cluster deviates from that described in Git, ArgoCD automatically performs Self-healing.

 - Using Helm allows you to parameterize deployment and easily manage application versions.

Monitoring & Efficiency (VictoriaMetrics)

 - Instead of the classic Prometheus stack, VictoriaMetrics was chosen, which is critically important for a local environment with limited resources.

 - vmagent collects metrics from Kubernetes and the virtual machine.

 - VictoriaLogs is integrated for centralized log collection.

 - Data is visualized in Grafana. This choice allowed us to reduce RAM consumption compared to standard solutions.

**4. Screenshots**

 - ArgoCD: Dashboard showing application health

 ![alt text](foto/aimage.png)

 - Grafana: Cluster metrics visualization

 ![alt text](foto/g1image-1.png)

 - SonarQube: Code quality report

 ![alt text](foto/simage.png)

**5. Getting started**

 Prerequisites

 - VirtualBox
 - Vagrant
 - Git

 **Provision infrastructure**

 `git clone <repo-url>`

 `cd vagrant`

 `vagrant up`

 This will:

 - Create 3 VMs (Jenkins, Ansible, Slave)

 - Configure private networking

 - Prepare base OS environment

 **Configure infrastructure via ansible**

 From the Ansible node:

 `ansible-playbook -i hosts docker.yaml`

 This playbook:

 - Installs Docker

 Run the remaining playbooks in this directory to fully provision the environment.

 **Start kubernetes cluster**

 On the slave node:

 `minikube start --nodes 3 -p prod`
 `minikube addons enable ingress`

 **Deploy GitOps stack**

 Install Argo CD:

 `kubectl create namespace argocd`

 `kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml`

 Apply ingress configuration:

 `kubectl apply -f ingress.yaml`

 **Access services**

 Add VM IP mappings to:

 `C:\Windows\System32\drivers\etc\hosts`

 Example:

 `192.168.50.34 frontend.com`

 `192.168.50.34 backend.com`

 `192.168.50.34 argocd.local`

 `192.168.50.34 grafana.local`

 **Jenkins pipeline**

 - Multistage pipeline defined as code (Jenkinsfile)

 - SCM polling enabled

 - Quality Gates enforced via SonarQube

 - Docker images pushed to registry

 - GitOps repository updated automatically

**6. Key engineering decisions**

 - GitOps approach ensures declarative deployments and automatic drift correction.

 - VictoriaMetrics instead of Prometheus was chosen due to lower RAM consumption in a resource-constrained local environment.

 - Two-layer traffic routing (HAProxy + Ingress) separates VM-level networking from cluster-level service routing.

 - Quality Gates in Jenkins prevent deployment of low-quality or insecure code.

**7. Future improvements**

 - Cloud Migration: Migrating the project to AWS using Terraform.

 - Secret Management: Implementing HashiCorp Vault (instead of the basic K8s Secrets) for dynamic password management.