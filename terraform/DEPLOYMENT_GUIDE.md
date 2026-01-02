# 🌍 Phase 4 Terraform Multi-Region Deployment Guide

**Status**: ✅ Infrastructure as Code Complete  
**Target Go-Live**: August 31, 2026  
**Regions**: 6 (Amsterdam, Ashburn, Sydney, Singapore, San Francisco, Johannesburg)  

---

## 📋 Infrastructure Overview

### Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│ Global Sovereign Network - Phase 4 Multi-Region Infrastructure     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ams (EU)          iad (US-E)      syd (AU)     sin (SG)           │
│  ┌──────────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ EKS Cluster  │  │EKS Primary│ │EKS Cluster│ │EKS Cluster│       │
│  │ 3 AZs        │  │3 AZs      │ │3 AZs      │ │3 AZs      │       │
│  └──────────────┘  └──────────┘  └──────────┘  └──────────┘        │
│  RDS Read Replica  RDS PRIMARY  RDS Read Replica RDS Read Replica  │
│                                                                     │
│  sfo (US-W)        jnb (ZA)                                         │
│  ┌──────────────┐  ┌──────────┐                                    │
│  │ EKS Cluster  │  │EKS Cluster│                                   │
│  │ 2 AZs        │  │3 AZs      │                                   │
│  └──────────────┘  └──────────┘                                    │
│  RDS Read Replica  RDS Read Replica                                │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Regional Configuration

| Region | Code | AWS Region | AZs | Cluster | Database | Network |
|--------|------|-----------|-----|---------|----------|---------|
| 🇳🇱 Amsterdam | ams | eu-west-1 | 3 | EKS | Read Replica | 10.0.0.0/16 |
| 🇺🇸 Ashburn | iad | us-east-1 | 3 | EKS | PRIMARY | 10.1.0.0/16 |
| 🇦🇺 Sydney | syd | ap-southeast-2 | 3 | EKS | Read Replica | 10.2.0.0/16 |
| 🇸🇬 Singapore | sin | ap-southeast-1 | 3 | EKS | Read Replica | 10.3.0.0/16 |
| 🇺🇸 San Francisco | sfo | us-west-1 | 2 | EKS | Read Replica | 10.4.0.0/16 |
| 🇿🇦 Johannesburg | jnb | af-south-1 | 3 | EKS | Read Replica | 10.5.0.0/16 |

---

## 🚀 Deployment Instructions

### Prerequisites

```bash
# Install Terraform 1.5+
terraform version
# Expected: Terraform v1.5.0 or higher

# Install AWS CLI v2
aws --version

# Configure AWS credentials
aws configure
# Or use environment variables:
# export AWS_ACCESS_KEY_ID=xxx
# export AWS_SECRET_ACCESS_KEY=yyy
# export AWS_DEFAULT_REGION=us-east-1

# Install kubectl
kubectl version --client
```

### Step 1: Initialize Terraform State Backend

```bash
# Create S3 bucket for state (one-time)
aws s3api create-bucket \
  --bucket global-sovereign-terraform-state \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket global-sovereign-terraform-state \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket global-sovereign-terraform-state \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### Step 2: Initialize Terraform

```bash
cd /workspaces/Global-Signal_-Charter/terraform

# Initialize Terraform (downloads providers and modules)
terraform init

# Expected output:
# ✓ AWS provider v5.x installed
# ✓ Modules cached in .terraform/modules
# ✓ Backend configured
```

### Step 3: Plan Deployment

```bash
# Plan the deployment (dry-run)
terraform plan -out=tfplan

# This will show:
# - 6 EKS clusters (one per region)
# - 1 primary RDS instance (IAD)
# - 5 RDS read replicas
# - VPCs, subnets, gateways, NAT, IAM roles, security groups
# - Estimated AWS costs
```

### Step 4: Apply Configuration

```bash
# Deploy all infrastructure (takes 30-45 minutes per region)
terraform apply tfplan

# Monitor progress:
# - EKS cluster creation: ~20 minutes per region
# - RDS primary: ~20 minutes
# - RDS replicas: ~15 minutes each
# - Total time: ~90 minutes for all 6 regions

# Expected output:
# ✓ 6 EKS clusters deployed
# ✓ 1 RDS primary + 5 replicas deployed
# ✓ All networking configured
```

### Step 5: Configure kubectl Access

```bash
# Update kubeconfig for each region
for region in ams iad syd sin sfo jnb; do
  aws eks update-kubeconfig \
    --name global-sovereign-covenant-eks-${region} \
    --region $(terraform output -json eks_clusters | jq -r ".${region}" | cut -d: -f1)
done

# Verify cluster access
kubectl get nodes --context=global-sovereign-covenant-eks-iad
# Expected: 3+ nodes in READY state
```

### Step 6: Deploy Applications

```bash
# Apply Kubernetes manifests for each region
# (Next phase: Helm charts for Phoenix backend, SvelteKit frontend)

# Example: Deploy to IAD first
kubectl --context=global-sovereign-covenant-eks-iad apply -f ../k8s/manifests/

# Rollout across regions:
# 1. IAD (primary)
# 2. AMS, SYD, SIN (read replicas)
# 3. SFO, JNB (edge deployments)
```

---

## 📊 Infrastructure Costs

### Estimated Monthly Costs

| Component | ams | iad | syd | sin | sfo | jnb | Total |
|-----------|-----|-----|-----|-----|-----|-----|-------|
| EKS Cluster | $73 | $73 | $73 | $73 | $73 | $73 | $438 |
| EC2 Nodes (8 vCPU) | $240 | $240 | $240 | $240 | $240 | $240 | $1,440 |
| RDS Instance | - | $3,840 | - | - | - | - | $3,840 |
| RDS Replica (xlarge) | $1,920 | - | $1,920 | $1,920 | $1,920 | $960 | $7,680 |
| Data Transfer (egress) | $200 | $200 | $200 | $200 | $200 | $200 | $1,200 |
| **Monthly Total** | **$2,633** | **$4,853** | **$2,633** | **$2,633** | **$2,633** | **$2,173** | **$17,558** |

### Cost Optimization Strategies

1. **Reserved Instances** (40% savings)
   - 1-year RIs for RDS instances
   - 3-year RIs for compute-heavy workloads

2. **Spot Instances** (70% savings)
   - Use for non-critical batch jobs
   - Mixed on-demand + spot for worker nodes

3. **Auto-scaling**
   - Horizontal Pod Autoscaler (HPA)
   - Cluster Autoscaler for node scaling
   - Remove unused nodes during off-hours

---

## 🔄 Maintenance & Operations

### Health Checks

```bash
# Check cluster health
kubectl get nodes -A
kubectl get pods -A --watch

# Check database replication lag
aws rds describe-db-clusters \
  --db-cluster-identifier global-sovereign-covenant-rds

# Monitor cross-region latency
# Tools: CloudWatch, Prometheus, Grafana
```

### Disaster Recovery

```bash
# Test failover (promote replica to primary)
aws rds promote-read-replica \
  --db-instance-identifier global-sovereign-covenant-rds-ams

# Backup strategy:
# - Daily snapshots (automated)
# - 30-day retention
# - Encrypted backups
# - Cross-region backup copies
```

### Scaling Operations

```bash
# Horizontal scaling (add more nodes)
kubectl scale deployment global-sovereign-api --replicas=5

# Vertical scaling (larger instances)
terraform apply -var="db_instance_class=db.r6i.4xlarge"

# Update Kubernetes version
terraform apply -var="kubernetes_version=1.29"
```

---

## ✅ Deployment Checklist

- [ ] AWS accounts configured (6 regions)
- [ ] Terraform state backend created
- [ ] `terraform init` successful
- [ ] `terraform plan` reviewed and approved
- [ ] `terraform apply` completed (all 6 regions)
- [ ] kubectl access verified for all clusters
- [ ] Security groups and network ACLs reviewed
- [ ] RDS replication lag < 1 second
- [ ] EKS worker nodes in READY state
- [ ] Load balancers provisioned and tested
- [ ] DNS geo-routing configured
- [ ] CloudWatch monitoring enabled
- [ ] Backup and recovery tested

---

## 🚨 Troubleshooting

### EKS Cluster Creation Fails
```bash
# Check IAM permissions
aws iam list-roles | grep eks

# Check service quotas
aws service-quotas get-service-quota \
  --service-code eks \
  --quota-code L-1194D53C
```

### RDS Replica Creation Fails
```bash
# Check replication status
aws rds describe-db-instances \
  --db-instance-identifier global-sovereign-covenant-rds

# Check binary logs enabled
aws rds describe-db-parameters \
  --db-instance-identifier global-sovereign-covenant-rds \
  --filters Name=IsModifiable,Values=false
```

### Network Connectivity Issues
```bash
# Test cross-region connectivity
aws ec2 describe-security-groups \
  --region us-east-1

# Verify VPC peering
aws ec2 describe-vpc-peering-connections
```

---

## 📚 Related Documentation

- [Phase 4 Go-Live Checklist](../GO_LIVE_CHECKLIST.md)
- [AWS Best Practices](../docs/ARCHITECTURE.md)
- [Kubernetes Architecture](../docs/ARCHITECTURE.md)
- [Security Policies](../docs/SECURITY.md)

---

**Status**: ✅ Terraform configuration complete  
**Next Step**: Execute `terraform init && terraform plan`  
**Timeline**: 90 minutes for full deployment  
**Owner**: DevOps/Infrastructure Team
