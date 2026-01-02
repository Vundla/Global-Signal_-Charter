# Phase 4: Multi-Region Infrastructure
# 6 regions: ams, iad, syd, sin, sfo, jnb
# Global Sovereign Network production deployment

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

# Default provider (primary region)
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = var.project_name
      Environment = var.environment
      Phase     = "4"
      ManagedBy = "Terraform"
    }
  }
}

# Regional providers (declared for multi-region)
provider "aws" {
  alias  = "eu_west_1"
  region = "eu-west-1"

  default_tags {
    tags = {
      Project   = var.project_name
      Environment = var.environment
      Phase     = "4"
      ManagedBy = "Terraform"
    }
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = var.project_name
      Environment = var.environment
      Phase     = "4"
      ManagedBy = "Terraform"
    }
  }
}

provider "aws" {
  alias  = "ap_southeast_2"
  region = "ap-southeast-2"

  default_tags {
    tags = {
      Project   = var.project_name
      Environment = var.environment
      Phase     = "4"
      ManagedBy = "Terraform"
    }
  }
}

provider "aws" {
  alias  = "ap_southeast_1"
  region = "ap-southeast-1"

  default_tags {
    tags = {
      Project   = var.project_name
      Environment = var.environment
      Phase     = "4"
      ManagedBy = "Terraform"
    }
  }
}

provider "aws" {
  alias  = "us_west_1"
  region = "us-west-1"

  default_tags {
    tags = {
      Project   = var.project_name
      Environment = var.environment
      Phase     = "4"
      ManagedBy = "Terraform"
    }
  }
}

provider "aws" {
  alias  = "af_south_1"
  region = "af-south-1"

  default_tags {
    tags = {
      Project   = var.project_name
      Environment = var.environment
      Phase     = "4"
      ManagedBy = "Terraform"
    }
  }
}

# Variables
variable "regions" {
  description = "Phase 4 deployment regions with AWS configuration"
  type = map(object({
    aws_region = string
    region_code = string
    availability_zones = list(string)
  }))
  default = {
    ams = {
      aws_region = "eu-west-1"
      region_code = "ams"
      availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
    }
    iad = {
      aws_region = "us-east-1"
      region_code = "iad"
      availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
    }
    syd = {
      aws_region = "ap-southeast-2"
      region_code = "syd"
      availability_zones = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
    }
    sin = {
      aws_region = "ap-southeast-1"
      region_code = "sin"
      availability_zones = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
    }
    sfo = {
      aws_region = "us-west-1"
      region_code = "sfo"
      availability_zones = ["us-west-1a", "us-west-1b"]
    }
    jnb = {
      aws_region = "af-south-1"
      region_code = "jnb"
      availability_zones = ["af-south-1a", "af-south-1b", "af-south-1c"]
    }
  }
}

variable "environment" {
  description = "Environment name (production/staging)"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name for tagging and naming resources"
  type        = string
  default     = "global-sovereign-covenant"
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS clusters"
  type        = string
  default     = "1.28"
}

# EKS Cluster Deployments (one per region)
module "eks_ams" {
  source = "./modules/eks"

  region_code       = "ams"
  project_name      = var.project_name
  environment       = var.environment
  kubernetes_version = var.kubernetes_version
  
  availability_zones = var.regions.ams.availability_zones
  vpc_cidr          = "10.0.0.0/16"
  
  providers = {
    aws = aws.eu_west_1
  }
}

module "eks_iad" {
  source = "./modules/eks"

  region_code       = "iad"
  project_name      = var.project_name
  environment       = var.environment
  kubernetes_version = var.kubernetes_version
  
  availability_zones = var.regions.iad.availability_zones
  vpc_cidr          = "10.1.0.0/16"
  
  providers = {
    aws = aws.us_east_1
  }
}

module "eks_syd" {
  source = "./modules/eks"

  region_code       = "syd"
  project_name      = var.project_name
  environment       = var.environment
  kubernetes_version = var.kubernetes_version
  
  availability_zones = var.regions.syd.availability_zones
  vpc_cidr          = "10.2.0.0/16"
  
  providers = {
    aws = aws.ap_southeast_2
  }
}

module "eks_sin" {
  source = "./modules/eks"

  region_code       = "sin"
  project_name      = var.project_name
  environment       = var.environment
  kubernetes_version = var.kubernetes_version
  
  availability_zones = var.regions.sin.availability_zones
  vpc_cidr          = "10.3.0.0/16"
  
  providers = {
    aws = aws.ap_southeast_1
  }
}

module "eks_sfo" {
  source = "./modules/eks"

  region_code       = "sfo"
  project_name      = var.project_name
  environment       = var.environment
  kubernetes_version = var.kubernetes_version
  
  availability_zones = var.regions.sfo.availability_zones
  vpc_cidr          = "10.4.0.0/16"
  
  providers = {
    aws = aws.us_west_1
  }
}

module "eks_jnb" {
  source = "./modules/eks"

  region_code       = "jnb"
  project_name      = var.project_name
  environment       = var.environment
  kubernetes_version = var.kubernetes_version
  
  availability_zones = var.regions.jnb.availability_zones
  vpc_cidr          = "10.5.0.0/16"
  
  providers = {
    aws = aws.af_south_1
  }
}

# RDS Database Deployments
module "rds_iad_primary" {
  source = "./modules/rds"

  region_code      = "iad"
  project_name     = var.project_name
  environment      = var.environment
  db_instance_class = "db.r6i.2xlarge"
  allocated_storage = 500
  
  multi_az = true
  backup_retention_days = 30
  
  providers = {
    aws = aws.us_east_1
  }
}

# Read replicas in other regions
module "rds_ams_replica" {
  source = "./modules/rds"

  region_code      = "ams"
  project_name     = var.project_name
  environment      = var.environment
  db_instance_class = "db.r6i.xlarge"
  allocated_storage = 500
  
  is_replica        = true
  source_db_identifier = module.rds_iad_primary.db_instance_id
  
  providers = {
    aws = aws.eu_west_1
  }
}

module "rds_syd_replica" {
  source = "./modules/rds"

  region_code      = "syd"
  project_name     = var.project_name
  environment      = var.environment
  db_instance_class = "db.r6i.xlarge"
  allocated_storage = 500
  
  is_replica        = true
  source_db_identifier = module.rds_iad_primary.db_instance_id
  
  providers = {
    aws = aws.ap_southeast_2
  }
}

module "rds_sin_replica" {
  source = "./modules/rds"

  region_code      = "sin"
  project_name     = var.project_name
  environment      = var.environment
  db_instance_class = "db.r6i.xlarge"
  allocated_storage = 500
  
  is_replica        = true
  source_db_identifier = module.rds_iad_primary.db_instance_id
  
  providers = {
    aws = aws.ap_southeast_1
  }
}

module "rds_sfo_replica" {
  source = "./modules/rds"

  region_code      = "sfo"
  project_name     = var.project_name
  environment      = var.environment
  db_instance_class = "db.r6i.xlarge"
  allocated_storage = 500
  
  is_replica        = true
  source_db_identifier = module.rds_iad_primary.db_instance_id
  
  providers = {
    aws = aws.us_west_1
  }
}

module "rds_jnb_replica" {
  source = "./modules/rds"

  region_code      = "jnb"
  project_name     = var.project_name
  environment      = var.environment
  db_instance_class = "db.r6i.large"
  allocated_storage = 500
  
  is_replica        = true
  source_db_identifier = module.rds_iad_primary.db_instance_id
  
  providers = {
    aws = aws.af_south_1
  }
}

# Outputs
output "regions_deployed" {
  description = "List of all deployed regions"
  value       = keys(var.regions)
}

output "eks_clusters" {
  description = "EKS cluster endpoints per region"
  value = {
    ams = module.eks_ams.cluster_endpoint
    iad = module.eks_iad.cluster_endpoint
    syd = module.eks_syd.cluster_endpoint
    sin = module.eks_sin.cluster_endpoint
    sfo = module.eks_sfo.cluster_endpoint
    jnb = module.eks_jnb.cluster_endpoint
  }
}

output "rds_primary_endpoint" {
  description = "Primary RDS endpoint (IAD)"
  value       = module.rds_iad_primary.endpoint
}

output "rds_replica_endpoints" {
  description = "Read replica endpoints"
  value = {
    ams = module.rds_ams_replica.endpoint
    syd = module.rds_syd_replica.endpoint
    sin = module.rds_sin_replica.endpoint
    sfo = module.rds_sfo_replica.endpoint
    jnb = module.rds_jnb_replica.endpoint
  }
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}
