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

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.28"
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.large", "t3.xlarge"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 10
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "spot_node_desired_size" {
  description = "Desired number of spot worker nodes"
  type        = number
  default     = 2
}

variable "spot_node_max_size" {
  description = "Maximum number of spot worker nodes"
  type        = number
  default     = 8
}

variable "spot_node_min_size" {
  description = "Minimum number of spot worker nodes"
  type        = number
  default     = 0
}
