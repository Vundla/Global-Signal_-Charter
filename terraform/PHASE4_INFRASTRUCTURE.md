# Phase 4: Multi-Region Terraform Infrastructure
## Global Sovereign Cloud Deployment

This directory contains Infrastructure-as-Code for deploying Global Sovereign across 6 regions.

## Structure

```
terraform/
├── main.tf                    # Provider configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── vpc.tf                     # Network infrastructure
├── rds.tf                     # PostgreSQL multi-region
├── cassandra.tf               # Cassandra multi-DC
├── redis.tf                   # Cache layer
├── kubernetes.tf              # EKS clusters
├── monitoring.tf              # Prometheus/Grafana
└── modules/
    ├── region/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── database/
        ├── postgres.tf
        └── cassandra.tf
```

## Regions

| Region | Provider | Availability | Primary Use |
|--------|----------|--------------|------------|
| ams (Amsterdam) | Fly.io | EU | Primary / Europe |
| iad (Virginia) | AWS | US-East | US / Americas |
| syd (Sydney) | AWS | APAC | Asia-Pacific |
| sin (Singapore) | AWS | APAC | South Asia |
| sfo (San Francisco) | AWS | US-West | Americas / Pacific |
| jnb (Johannesburg) | Fly.io | Africa | Africa / EMEA backup |

## Deployment

```bash
# 1. Initialize Terraform
terraform init

# 2. Plan for all regions
terraform plan -out=phase4.tfplan

# 3. Apply infrastructure
terraform apply phase4.tfplan

# 4. Verify deployment
terraform output -json
```

## Multi-Region Database

### PostgreSQL Replication

**Primary Region**: ams (Amsterdam)
**Replicas**: iad, syd, sin, sfo, jnb (async)

```hcl
# modules/database/postgres.tf

resource "aws_rds_cluster" "primary" {
  cluster_identifier = "global-sovereign-primary"
  engine             = "aurora-postgresql"
  engine_version     = "14.6"
  database_name      = "global_db"
  master_username    = "postgres"
  
  # Replication
  backup_retention_period      = 35
  copy_tags_to_snapshot        = true
  enabled_cloudwatch_logs_exports = ["postgresql"]
}

resource "aws_rds_cluster_instance" "primary_nodes" {
  count              = 3
  cluster_identifier = aws_rds_cluster.primary.id
  instance_class     = "db.r6i.2xlarge"
  engine             = aws_rds_cluster.primary.engine
  engine_version     = aws_rds_cluster.primary.engine_version
}

# Cross-region read replicas
resource "aws_rds_cluster" "replica" {
  for_each = {
    iad = { region = "us-east-1" }
    syd = { region = "ap-southeast-2" }
    sin = { region = "ap-southeast-1" }
    sfo = { region = "us-west-1" }
  }

  cluster_identifier            = "global-sovereign-${each.key}-replica"
  replication_source_identifier = aws_rds_cluster.primary.arn
  skip_final_snapshot           = false
  final_snapshot_identifier     = "global-sovereign-${each.key}-final-snapshot"
  
  provider = aws.${each.value.region}
}
```

### Cassandra Multi-DC

```hcl
# modules/database/cassandra.tf

# Deploy via Cassandra Operator in Kubernetes
# Each region gets 3 Cassandra nodes with RF=3

resource "helm_release" "cassandra" {
  for_each = {
    ams = { kube_config = aws_eks_cluster.ams.kubeconfig }
    iad = { kube_config = aws_eks_cluster.iad.kubeconfig }
    syd = { kube_config = aws_eks_cluster.syd.kubeconfig }
  }

  name            = "cassandra"
  repository      = "https://charts.helm.sh/incubator"
  chart           = "cassandra"
  namespace       = "cassandra"
  create_namespace = true

  values = [
    templatefile("${path.module}/cassandra-values.yaml", {
      region       = each.key
      nodes        = 3
      replication  = { ams = 3, iad = 2, syd = 2 }
      storage_size = "500Gi"
    })
  ]
}
```

## Kubernetes Clusters

### EKS per Region

```hcl
# kubernetes.tf

resource "aws_eks_cluster" "regional" {
  for_each = {
    ams = { region = "eu-west-1", cidr = "10.1.0.0/16" }
    iad = { region = "us-east-1", cidr = "10.2.0.0/16" }
    syd = { region = "ap-southeast-2", cidr = "10.3.0.0/16" }
    sin = { region = "ap-southeast-1", cidr = "10.4.0.0/16" }
    sfo = { region = "us-west-1", cidr = "10.5.0.0/16" }
  }

  name            = "global-sovereign-${each.key}"
  role_arn        = aws_iam_role.eks_role.arn
  vpc_config {
    subnet_ids = aws_subnet.regional[each.key].*.id
  }

  provider = aws.${each.value.region}
}

resource "aws_eks_node_group" "regional" {
  for_each = aws_eks_cluster.regional

  cluster_name    = each.value.name
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = aws_subnet.regional[each.key].*.id
  version         = "1.27"

  scaling_config {
    desired_size = 5
    max_size     = 20
    min_size     = 3
  }

  instance_types = ["m5.2xlarge", "m5.4xlarge"]
  disk_size      = 100

  tags = {
    Name   = "global-sovereign-${each.key}-nodes"
    Region = each.key
  }
}
```

## Monitoring & Observability

### Prometheus + Grafana (Global)

```hcl
# monitoring.tf

resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  namespace        = "monitoring"
  create_namespace = true

  values = [
    file("${path.module}/prometheus-values.yaml")
  ]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"

  values = [
    file("${path.module}/grafana-values.yaml")
  ]

  depends_on = [helm_release.prometheus]
}
```

## Cost Optimization

### Auto-Scaling

```hcl
# autoscaling.tf

resource "aws_autoscaling_group" "api" {
  for_each = aws_eks_node_group.regional

  name = "global-sovereign-${each.key}-asg"
  
  min_size         = 3
  max_size         = 20
  desired_capacity = 5

  # Scale based on CPU and Memory
  target_group_arns = [aws_lb_target_group.api[each.key].arn]

  instance_type = "m5.2xlarge"

  tag {
    key                 = "Name"
    value               = "global-sovereign-api-${each.key}"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_scale_up" {
  for_each = aws_autoscaling_group.api

  name                   = "scale-up-${each.key}"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = each.value.name
  adjustment_magnitude   = 2
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  for_each = aws_autoscaling_group.api

  alarm_name          = "cpu-high-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"

  alarm_actions = [aws_autoscaling_policy.cpu_scale_up[each.key].arn]
}
```

### Spot Instances

```hcl
# spot.tf

resource "aws_autoscaling_group" "batch_jobs" {
  for_each = aws_eks_node_group.regional

  name = "global-sovereign-${each.key}-spot"

  min_size         = 2
  max_size         = 50
  desired_capacity = 5

  instance_type            = "m5.large"
  spot_price               = "0.05" # On-demand rate ~$0.096
  
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "global-sovereign-spot-${each.key}"
    propagate_at_launch = true
  }
}
```

## Variables

```hcl
# variables.tf

variable "regions" {
  type = map(object({
    provider_region = string
    cidr_block     = string
    azs            = list(string)
  }))

  default = {
    ams = {
      provider_region = "eu-west-1"
      cidr_block      = "10.1.0.0/16"
      azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
    }
    iad = {
      provider_region = "us-east-1"
      cidr_block      = "10.2.0.0/16"
      azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
    }
    # ... other regions
  }
}

variable "environment" {
  default = "production"
}

variable "api_instance_type" {
  default = "m5.2xlarge"
}

variable "database_instance_type" {
  default = "db.r6i.2xlarge"
}
```

## Outputs

```hcl
# outputs.tf

output "eks_clusters" {
  value = {
    for name, cluster in aws_eks_cluster.regional :
    name => {
      endpoint              = cluster.endpoint
      certificate_authority = cluster.certificate_authority[0].data
      region               = cluster.region
    }
  }
}

output "rds_endpoints" {
  value = {
    for name, replica in aws_rds_cluster.replica :
    name => replica.endpoint
  }
}

output "cassandra_contact_points" {
  value = {
    for name, release in helm_release.cassandra :
    name => "cassandra.${name}.svc.cluster.local"
  }
}

output "load_balancer_endpoints" {
  value = {
    for region, alb in aws_lb.regional :
    region => alb.dns_name
  }
}
```

## Deployment Checklist

- [ ] AWS accounts created for each region
- [ ] Terraform state backend configured (S3 + DynamoDB)
- [ ] SSH keys generated for cluster access
- [ ] Network peering configured (mesh topology)
- [ ] PostgreSQL replication tested
- [ ] Cassandra cluster healthy (3+ nodes per DC)
- [ ] Load balancers distributing traffic
- [ ] DNS geo-routing configured
- [ ] Monitoring dashboards live
- [ ] Backup and recovery tested
- [ ] Security groups and IAM roles locked down
- [ ] Cost monitoring alerts configured

## Next Steps

1. Provision AWS accounts (6 regions)
2. Deploy Terraform for network infrastructure
3. Deploy databases (PostgreSQL primary + replicas, Cassandra)
4. Deploy Kubernetes clusters
5. Deploy Phoenix API pods
6. Configure multi-region failover
7. Load testing across all regions
