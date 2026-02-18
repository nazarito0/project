# End-to-End DevOps Project: Self-Hosted GitOps Infrastructure

**1. Резюме проєкту**

**One-liner:** Комплексна GitOps-платформа на базі **ArgoCD** у кластері **Kubernetes**, побудована з використанням **Ansible**, автоматизованого СІ-пайплайну **Jenkins** та моніторингу через **VictoriaMetrics**.

**Мета:** Реалізувати повний життєвий цикл доставки ПЗ у локальному середовищі, використовуючи **Ansible** для підготовки інфраструктури, **Jenkins** для збірки та перевірки коду, **Kubernetes** для запуску сервісів, **ArgoCD** для автоматизації деплою та **VictoriaMetrics** для глибокої видимості стану системи.

**2. Технологічний стек**

| Сфера | Інструменти |
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

**3. Опис реалізації**

Інфраструктура розгортається у VirtualBox.

Infrastructure & Networking

 - Vagrant cтворює три віртуальні машини у приватній мережі і надає їм IP адреси (Jenkins, Ansible, Slave).

 - Ansible автоматизує конфігурацію: встановлення Docker, Minikube тощо.

 - Налаштовано дворівневу схему балансування. Зовнішній трафік приймається HAProxy на рівні віртуальних машин і перенаправляється на Ingress Controller всередині Kubernetes кластера. Це дозволяє гнучко керувати маршрутизацією та забезпечувати доступ до сервісів за доменними іменами (argocd.local, grafana.local, тощо).

CI Pipeline (Jenkins & SonarQube)

 - Пайплайн реалізований через Jenkins із використанням SCM Polling для реагування на зміни в коді, без ручного втручання.

 - Кожен білд проходить аналіз у SonarQube.

 - Налаштовано Quality Gates: якщо код не відповідає стандартам безпеки або якості, пайплайн зупиняється, блокуючи пуш Docker-образу. Це гарантує стабільність релізів.

Delivery & GitOps (ArgoCD & Helm)

 - Деплой реалізовано за концепцією GitOps.

 - ArgoCD відстежує стан Helm-чартів у Git-репозиторії.

 - У разі відхилення конфігурації в кластері від описаної в Git, ArgoCD автоматично виконує Self-healing.

 - Використання Helm дозволяє параметризувати деплой та легко керувати версіями застосунку.

Monitoring & Efficiency (VictoriaMetrics)

 - Замість класичного Prometheus-стека обрано VictoriaMetrics, що є критично важливим для локального середовища з обмеженими ресурсами.

 - vmagent збирає метрики з Kubernetes та віртуальної машини.

 - VictoriaLogs інтегровано для централізованого збору логів.

 - Дані візуалізуються у Grafana. Такий вибір дозволив знизити споживання RAM в порівнянні зі стандартними рішеннями.

**4. Screenshots**

 - ArgoCD: Dashboard showing application health

 ![alt text](foto/aimage.png)

 - Grafana: Cluster metrics visualization

 ![alt text](foto/gimage.png)

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

 - Cloud Migration: Перенесення проєкту на AWS за допомогою Terraform.

 - Secret Management: Впровадження HashiCorp Vault (замість базових K8s Secrets) для динамічного керування паролями.