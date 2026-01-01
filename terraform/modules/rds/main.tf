# RDS PostgreSQL with Cross-Region Replication
# Primary in iad, read replicas in all other regions

locals {
  db_name = "${var.project_name}-postgres-${var.region_code}"
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
    Region      = var.region_code
    ManagedBy   = "Terraform"
    Phase       = "4"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "postgres" {
  name       = "${local.db_name}-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(local.tags, {
    Name = "${local.db_name}-subnet-group"
  })
}

# Security Group for RDS
resource "aws_security_group" "postgres" {
  name        = "${local.db_name}-sg"
  description = "Security group for PostgreSQL RDS"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from EKS"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.db_name}-sg"
  })
}

# RDS Primary Instance (or Read Replica)
resource "aws_db_instance" "postgres" {
  identifier     = local.db_name
  engine         = "postgres"
  engine_version = var.postgres_version
  instance_class = var.db_instance_class

  # Storage
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn

  # Database configuration
  db_name  = "global_sovereign"
  username = var.db_username
  password = var.db_password
  port     = 5432

  # Network
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.postgres.id]
  publicly_accessible    = false

  # High Availability
  multi_az               = var.is_primary
  availability_zone      = var.is_primary ? null : var.availability_zone

  # Backups
  backup_retention_period = var.backup_retention_days
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"
  copy_tags_to_snapshot   = true
  skip_final_snapshot     = var.environment != "production"
  final_snapshot_identifier = var.environment == "production" ? "${local.db_name}-final-snapshot" : null

  # Monitoring
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  monitoring_interval             = 60
  monitoring_role_arn             = aws_iam_role.rds_monitoring.arn
  performance_insights_enabled    = true
  performance_insights_retention_period = 7

  # Replication (for read replicas)
  replicate_source_db = var.is_primary ? null : var.source_db_arn

  # Parameters
  parameter_group_name = aws_db_parameter_group.postgres.name

  tags = local.tags

  lifecycle {
    ignore_changes = [password]
  }
}

# Parameter Group (optimized for Phase 4 workload)
resource "aws_db_parameter_group" "postgres" {
  name   = "${local.db_name}-params"
  family = "postgres15"

  # Connection pooling optimization
  parameter {
    name  = "max_connections"
    value = "500"
  }

  # Query performance
  parameter {
    name  = "shared_buffers"
    value = "{DBInstanceClassMemory/4096}"
  }

  parameter {
    name  = "effective_cache_size"
    value = "{DBInstanceClassMemory*3/4096}"
  }

  parameter {
    name  = "work_mem"
    value = "16384" # 16MB
  }

  parameter {
    name  = "maintenance_work_mem"
    value = "2097152" # 2GB
  }

  # Write-ahead log (WAL) settings
  parameter {
    name  = "wal_buffers"
    value = "16384" # 16MB
  }

  parameter {
    name  = "checkpoint_completion_target"
    value = "0.9"
  }

  # Query planner
  parameter {
    name  = "random_page_cost"
    value = "1.1" # SSD optimization
  }

  parameter {
    name  = "effective_io_concurrency"
    value = "200"
  }

  # Logging (for observability)
  parameter {
    name  = "log_min_duration_statement"
    value = "1000" # Log queries > 1 second
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  tags = local.tags
}

# IAM Role for Enhanced Monitoring
resource "aws_iam_role" "rds_monitoring" {
  name = "${local.db_name}-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Outputs
output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.postgres.id
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.postgres.arn
}

output "db_instance_address" {
  description = "RDS instance address"
  value       = aws_db_instance.postgres.address
}

output "db_security_group_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.postgres.id
}
