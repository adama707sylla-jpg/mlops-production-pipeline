# 🚀 MLOps Production Pipeline

<div align="center">

![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)

**EN** | [FR](#french-version)

*A production-grade MLOps pipeline for sentiment analysis using AWS, Kubernetes, and modern DevOps practices.*

*Un pipeline MLOps de niveau production pour l'analyse de sentiment avec AWS, Kubernetes et les meilleures pratiques DevOps.*

</div>

---

## 📋 Table of Contents / Table des Matières

- [English Version](#english-version)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Prerequisites](#prerequisites)
  - [Infrastructure](#infrastructure)
  - [CI/CD Pipeline](#cicd-pipeline)
  - [API Usage](#api-usage)
  - [Monitoring](#monitoring)
  - [Key Resources](#key-resources)
- [Version Française](#french-version)
  - [Vue d'ensemble](#vue-densemble)
  - [Architecture](#architecture-1)
  - [Prérequis](#prérequis)
  - [Infrastructure](#infrastructure-1)
  - [Pipeline CI/CD](#pipeline-cicd)
  - [Utilisation de l'API](#utilisation-de-lapi)
  - [Monitoring](#monitoring-1)
  - [Ressources Clés](#ressources-clés)

---

<a name="english-version"></a>
# 🇬🇧 English Version

## Overview

This project implements a **production-grade MLOps pipeline** for a sentiment analysis model (`smartreview`). It covers the full lifecycle: model training, Docker packaging, automated deployment on Kubernetes (EKS), and real-time monitoring with CloudWatch and Grafana.

### ✅ What's Built

| Component | Technology | Status |
|-----------|-----------|--------|
| Infrastructure as Code | Terraform | ✅ |
| Container Registry | AWS ECR | ✅ |
| ML Model Serving | AWS SageMaker | ✅ |
| Container Orchestration | AWS EKS (Kubernetes) | ✅ |
| CI/CD Pipeline | GitHub Actions + OIDC | ✅ |
| Monitoring | CloudWatch + Grafana | ✅ |
| Alerting | AWS SNS + Email | ✅ |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     GitHub Repository                        │
│                                                             │
│  develop branch          main branch                        │
│      │                       │                             │
│      ▼                       ▼                             │
│  ┌─────────────────────────────────┐                       │
│  │      GitHub Actions CI/CD       │                       │
│  │  ┌──────┐ ┌──────┐ ┌────────┐  │                       │
│  │  │Tests │→│Terra.│→│Build & │  │                       │
│  │  │  API │ │Valid.│ │ Push   │  │                       │
│  │  └──────┘ └──────┘ └────┬───┘  │                       │
│  │                          │      │                       │
│  │              ┌───────────┴────┐ │                       │
│  │              ▼                ▼ │                       │
│  │         Deploy dev      Deploy  │                       │
│  │         (develop)       prod    │                       │
│  │                         (main)  │                       │
│  └─────────────────────────────────┘                       │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                      AWS Cloud (eu-west-3)                   │
│                                                             │
│  ┌──────────┐    ┌──────────┐    ┌──────────────────────┐  │
│  │   ECR    │    │    S3    │    │    EKS Cluster       │  │
│  │  Docker  │    │  Model   │    │     mlops-dev        │  │
│  │  Images  │    │ Storage  │    │                      │  │
│  └──────────┘    └──────────┘    │  ┌────────────────┐  │  │
│                                  │  │ smartreview-api│  │  │
│  ┌──────────┐    ┌──────────┐    │  │   (2 pods)     │  │  │
│  │SageMaker │    │CloudWatch│    │  │   + HPA        │  │  │
│  │ Endpoint │    │  Metrics │    │  └────────────────┘  │  │
│  └──────────┘    └──────────┘    └──────────────────────┘  │
│                       │                    │                │
│                       ▼                    ▼                │
│                  ┌─────────┐         ┌──────────┐          │
│                  │ Grafana │         │   Load   │          │
│                  │Dashboard│         │ Balancer │          │
│                  └─────────┘         └──────────┘          │
└─────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.7.0
- kubectl
- Helm >= 3.14.0
- Docker
- Python 3.11+

---

## Infrastructure

### Terraform Modules

```
terraform/
├── modules/
│   ├── sagemaker/        # SageMaker Model Registry + Endpoint
│   ├── eks/              # EKS Cluster + Node Groups
│   ├── monitoring/       # CloudWatch + Grafana
│   └── github_oidc/      # OIDC for GitHub Actions
└── environments/
    ├── dev/              # Development environment
    └── prod/             # Production environment
```

### Deploy Infrastructure

```bash
# Initialize and deploy dev environment
cd environments/dev
terraform init
terraform plan
terraform apply
```

### Remote State

State is stored remotely to enable team collaboration:

```hcl
terraform {
  backend "s3" {
    bucket         = "mlops-expert-artifacts-dev"
    key            = "terraform/state"
    region         = "eu-west-3"
    dynamodb_table = "terraform-lock"
  }
}
```

---

## CI/CD Pipeline

### Pipeline Overview

```
Push to develop/main
        │
        ▼
┌───────────────┐     ┌───────────────────┐
│   Tests API   │────▶│ Terraform Validate │
│   (pytest)    │     │   (fmt + validate) │
└───────────────┘     └───────────────────┘
        │                       │
        └───────────┬───────────┘
                    ▼
          ┌──────────────────┐
          │  Build & Push    │
          │  Docker → ECR    │
          │  Model ← S3      │
          └──────────────────┘
                    │
          ┌─────────┴──────────┐
          ▼                    ▼
   ┌─────────────┐    ┌──────────────┐
   │ Deploy dev  │    │ Deploy prod  │
   │  (develop)  │    │   (main)     │
   └─────────────┘    └──────────────┘
```

### GitHub Actions Secrets Required

| Secret | Description |
|--------|-------------|
| `AWS_REGION` | `eu-west-3` |
| `ECR_REPOSITORY` | `mlops-expert-api` |
| `EKS_CLUSTER` | `mlops-dev` |
| `ACCOUNT_ID` | AWS Account ID |
| `ROLE_ARN` | OIDC Role ARN |

---

## API Usage

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| POST | `/predict` | Sentiment prediction |

### Examples

```bash
# Health check
curl http://13.37.232.77:30376/health
# Response: {"status":"healthy","model_loaded":true}

# Positive review
curl -X POST http://13.37.232.77:30376/predict \
  -H "Content-Type: application/json" \
  -d '{"review": "This product is amazing!"}'
# Response: {"prediction":"positive","confidence":0.9888}

# Negative review
curl -X POST http://13.37.232.77:30376/predict \
  -H "Content-Type: application/json" \
  -d '{"review": "Terrible experience, very bad!"}'
# Response: {"prediction":"negative","confidence":0.9996}
```

---

## Monitoring

### CloudWatch

CloudWatch Container Insights is enabled on the EKS cluster and collects:

- `pod_cpu_utilization` — Pod CPU usage
- `pod_memory_working_set` — Pod memory usage
- `pod_network_rx_bytes` — Inbound network traffic
- `pod_network_tx_bytes` — Outbound network traffic
- `node_cpu_utilization` — Node CPU usage
- `node_memory_utilization` — Node memory usage

### Grafana Dashboard

Access Grafana at:
```
http://a94e88450ff4c477187f250982ea1929-1078875961.eu-west-3.elb.amazonaws.com
```

Credentials: `admin / MLOps2024!`

### CloudWatch Alarms

| Alarm | Metric | Threshold |
|-------|--------|-----------|
| `smartreview-api-cpu-high` | pod_cpu_utilization | > 80% |
| `smartreview-api-memory-high` | pod_memory_working_set | > 500MB |

Alerts are sent via **AWS SNS** to `adama101sylla@gmail.com`.

---

## Key Resources

| Resource | Value |
|----------|-------|
| API Endpoint | `http://13.37.232.77:30376` |
| ELB URL | `a4126442327eb4f34bf2be3a52a0b8a6-cea6942badcf43c1.elb.eu-west-3.amazonaws.com` |
| S3 Model | `s3://mlops-expert-artifacts-dev/models/smartreview/model.tar.gz` |
| ECR Repository | `718100329950.dkr.ecr.eu-west-3.amazonaws.com/mlops-expert-api` |
| OIDC Role | `arn:aws:iam::718100329950:role/github-actions-role-dev` |
| SageMaker Role | `arn:aws:iam::718100329950:role/mlops-expert-sagemaker-exec-dev` |
| EKS Cluster | `mlops-dev` (eu-west-3) |
| Grafana | `http://a94e88450ff4c477187f250982ea1929-1078875961.eu-west-3.elb.amazonaws.com` |

---

<a name="french-version"></a>
# 🇫🇷 Version Française

## Vue d'ensemble

Ce projet implémente un **pipeline MLOps de niveau production** pour un modèle d'analyse de sentiment (`smartreview`). Il couvre le cycle de vie complet : entraînement du modèle, packaging Docker, déploiement automatisé sur Kubernetes (EKS), et monitoring en temps réel avec CloudWatch et Grafana.

### ✅ Ce qui est construit

| Composant | Technologie | Statut |
|-----------|------------|--------|
| Infrastructure as Code | Terraform | ✅ |
| Registre de conteneurs | AWS ECR | ✅ |
| Serving du modèle ML | AWS SageMaker | ✅ |
| Orchestration de conteneurs | AWS EKS (Kubernetes) | ✅ |
| Pipeline CI/CD | GitHub Actions + OIDC | ✅ |
| Monitoring | CloudWatch + Grafana | ✅ |
| Alerting | AWS SNS + Email | ✅ |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Dépôt GitHub                              │
│                                                             │
│  branche develop         branche main                       │
│      │                       │                             │
│      ▼                       ▼                             │
│  ┌─────────────────────────────────┐                       │
│  │      GitHub Actions CI/CD       │                       │
│  │  ┌──────┐ ┌──────┐ ┌────────┐  │                       │
│  │  │Tests │→│Terra.│→│Build & │  │                       │
│  │  │  API │ │Valid.│ │ Push   │  │                       │
│  │  └──────┘ └──────┘ └────┬───┘  │                       │
│  │                          │      │                       │
│  │              ┌───────────┴────┐ │                       │
│  │              ▼                ▼ │                       │
│  │         Deploy dev      Deploy  │                       │
│  │         (develop)       prod    │                       │
│  │                         (main)  │                       │
│  └─────────────────────────────────┘                       │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   AWS Cloud (eu-west-3)                      │
│                                                             │
│  ┌──────────┐    ┌──────────┐    ┌──────────────────────┐  │
│  │   ECR    │    │    S3    │    │   Cluster EKS        │  │
│  │  Images  │    │  Modèle  │    │     mlops-dev        │  │
│  │  Docker  │    │ stockage │    │                      │  │
│  └──────────┘    └──────────┘    │  ┌────────────────┐  │  │
│                                  │  │ smartreview-api│  │  │
│  ┌──────────┐    ┌──────────┐    │  │   (2 pods)     │  │  │
│  │SageMaker │    │CloudWatch│    │  │   + HPA        │  │  │
│  │ Endpoint │    │ Métriques│    │  └────────────────┘  │  │
│  └──────────┘    └──────────┘    └──────────────────────┘  │
│                       │                    │                │
│                       ▼                    ▼                │
│                  ┌─────────┐         ┌──────────┐          │
│                  │ Grafana │         │   Load   │          │
│                  │Dashboard│         │ Balancer │          │
│                  └─────────┘         └──────────┘          │
└─────────────────────────────────────────────────────────────┘
```

---

## Prérequis

- AWS CLI configuré avec les permissions appropriées
- Terraform >= 1.7.0
- kubectl
- Helm >= 3.14.0
- Docker
- Python 3.11+

---

## Infrastructure

### Modules Terraform

```
terraform/
├── modules/
│   ├── sagemaker/        # Model Registry + Endpoint SageMaker
│   ├── eks/              # Cluster EKS + Node Groups
│   ├── monitoring/       # CloudWatch + Grafana
│   └── github_oidc/      # OIDC pour GitHub Actions
└── environments/
    ├── dev/              # Environnement de développement
    └── prod/             # Environnement de production
```

### Déployer l'Infrastructure

```bash
# Initialiser et déployer l'environnement dev
cd environments/dev
terraform init
terraform plan
terraform apply
```

### State Distant

Le state est stocké à distance pour permettre la collaboration en équipe :

```hcl
terraform {
  backend "s3" {
    bucket         = "mlops-expert-artifacts-dev"
    key            = "terraform/state"
    region         = "eu-west-3"
    dynamodb_table = "terraform-lock"
  }
}
```

---

## Pipeline CI/CD

### Vue d'ensemble du pipeline

```
Push sur develop/main
        │
        ▼
┌───────────────┐     ┌───────────────────┐
│   Tests API   │────▶│ Terraform Validate │
│   (pytest)    │     │   (fmt + validate) │
└───────────────┘     └───────────────────┘
        │                       │
        └───────────┬───────────┘
                    ▼
          ┌──────────────────┐
          │  Build & Push    │
          │  Docker → ECR    │
          │  Modèle ← S3     │
          └──────────────────┘
                    │
          ┌─────────┴──────────┐
          ▼                    ▼
   ┌─────────────┐    ┌──────────────┐
   │ Deploy dev  │    │ Deploy prod  │
   │  (develop)  │    │   (main)     │
   └─────────────┘    └──────────────┘
```

### Secrets GitHub Actions Requis

| Secret | Description |
|--------|-------------|
| `AWS_REGION` | `eu-west-3` |
| `ECR_REPOSITORY` | `mlops-expert-api` |
| `EKS_CLUSTER` | `mlops-dev` |
| `ACCOUNT_ID` | ID du compte AWS |
| `ROLE_ARN` | ARN du rôle OIDC |

---

## Utilisation de l'API

### Endpoints

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/health` | Vérification de santé |
| POST | `/predict` | Prédiction de sentiment |

### Exemples

```bash
# Vérification de santé
curl http://13.37.232.77:30376/health
# Réponse : {"status":"healthy","model_loaded":true}

# Avis positif
curl -X POST http://13.37.232.77:30376/predict \
  -H "Content-Type: application/json" \
  -d '{"review": "Ce produit est incroyable !"}'
# Réponse : {"prediction":"positive","confidence":0.9888}

# Avis négatif
curl -X POST http://13.37.232.77:30376/predict \
  -H "Content-Type: application/json" \
  -d '{"review": "Expérience terrible, très mauvais !"}'
# Réponse : {"prediction":"negative","confidence":0.9996}
```

---

## Monitoring

### CloudWatch

CloudWatch Container Insights est activé sur le cluster EKS et collecte :

- `pod_cpu_utilization` — Utilisation CPU du pod
- `pod_memory_working_set` — Utilisation mémoire du pod
- `pod_network_rx_bytes` — Trafic réseau entrant
- `pod_network_tx_bytes` — Trafic réseau sortant
- `node_cpu_utilization` — Utilisation CPU du nœud
- `node_memory_utilization` — Utilisation mémoire du nœud

### Dashboard Grafana

Accès à Grafana :
```
http://a94e88450ff4c477187f250982ea1929-1078875961.eu-west-3.elb.amazonaws.com
```

Identifiants : `admin / MLOps2024!`

### Alarmes CloudWatch

| Alarme | Métrique | Seuil |
|--------|---------|-------|
| `smartreview-api-cpu-high` | pod_cpu_utilization | > 80% |
| `smartreview-api-memory-high` | pod_memory_working_set | > 500MB |

Les alertes sont envoyées via **AWS SNS** à `adama101sylla@gmail.com`.

---

## Ressources Clés

| Ressource | Valeur |
|-----------|--------|
| API Endpoint | `http://13.37.232.77:30376` |
| ELB URL | `a4126442327eb4f34bf2be3a52a0b8a6-cea6942badcf43c1.elb.eu-west-3.amazonaws.com` |
| S3 Modèle | `s3://mlops-expert-artifacts-dev/models/smartreview/model.tar.gz` |
| ECR Repository | `718100329950.dkr.ecr.eu-west-3.amazonaws.com/mlops-expert-api` |
| Rôle OIDC | `arn:aws:iam::718100329950:role/github-actions-role-dev` |
| Rôle SageMaker | `arn:aws:iam::718100329950:role/mlops-expert-sagemaker-exec-dev` |
| Cluster EKS | `mlops-dev` (eu-west-3) |
| Grafana | `http://a94e88450ff4c477187f250982ea1929-1078875961.eu-west-3.elb.amazonaws.com` |

---

<div align="center">

Made with ❤️ by **adama707sylla-jpg**

![AWS](https://img.shields.io/badge/Account-718100329950-232F3E?style=flat&logo=amazon-aws)
![Region](https://img.shields.io/badge/Region-eu--west--3-FF9900?style=flat&logo=amazon-aws)

</div>
