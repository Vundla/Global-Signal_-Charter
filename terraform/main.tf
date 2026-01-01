# Phase 4: Multi-Region Infrastructure
# 6 regions: ams, iad, syd, sin, sfo, jnb

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "global-sovereign-terraform-state"
    key            = "phase4/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

# Variables
variable "regions" {
  description = "Phase 4 deployment regions"
  type = map(object({
    region = string
    availability_zones = list(string)
  }))
  default = {
    ams = {
      region = "eu-west-1"
      availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
    }
    iad = {
      region = "us-east-1"
      availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
    }
    syd = {
      region = "ap-southeast-2"
      availability_zones = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
    }
    sin = {
      region = "ap-southeast-1"
      availability_zones = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
    }
    sfo = {
      region = "us-west-1"
      availability_zones = ["us-west-1a", "us-west-1b"]
    }
    jnb = {
      region = "af-south-1"
      availability_zones = ["af-south-1a", "af-south-1b", "af-south-1c"]
    }
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "global-sovereign-covenant"
}

# Outputs
output "regions_deployed" {
  description = "List of deployed regions"
  value       = keys(var.regions)
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}
