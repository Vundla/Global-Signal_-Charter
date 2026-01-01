variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (production, staging, etc.)"
  type        = string
}

variable "region_code" {
  description = "Region code (ams, iad, syd, sin, sfo, jnb)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where RDS will be deployed"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR for security group rules"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for DB subnet group"
  type        = list(string)
}

variable "availability_zone" {
  description = "Specific AZ for single-AZ deployments (read replicas)"
  type        = string
  default     = null
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15.4"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.r6g.xlarge" # 4 vCPU, 32 GB RAM
}

variable "allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 500
}

variable "max_allocated_storage" {
  description = "Maximum storage for autoscaling in GB"
  type        = number
  default     = 5000
}

variable "db_username" {
  description = "Master username for database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password for database"
  type        = string
  sensitive   = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

variable "is_primary" {
  description = "Whether this is the primary instance (true) or read replica (false)"
  type        = bool
  default     = true
}

variable "source_db_arn" {
  description = "ARN of source DB for read replicas"
  type        = string
  default     = null
}
