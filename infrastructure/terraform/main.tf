# Zero World Trillion-Scale Infrastructure
# Main Terraform configuration

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
  
  backend "s3" {
    bucket         = "zero-world-terraform-state"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "zero-world-terraform-locks"
    
    # State file versioning
    versioning = true
  }
}

# ============================================================================
# Provider Configuration
# ============================================================================

provider "aws" {
  region = var.aws_primary_region
  
  default_tags {
    tags = {
      Project     = "ZeroWorld"
      ManagedBy   = "Terraform"
      Environment = var.environment
      CostCenter  = "Platform"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_primary_region
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

# ============================================================================
# Variables
# ============================================================================

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"
}

variable "aws_primary_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_primary_region" {
  description = "Primary GCP region"
  type        = string
  default     = "us-central1"
}

variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "cluster_count_per_region" {
  description = "Number of Kubernetes clusters per region"
  type        = number
  default     = 50
}

variable "nodes_per_cluster" {
  description = "Number of nodes per Kubernetes cluster"
  type        = number
  default     = 1000
}

# ============================================================================
# Multi-Region Deployment
# ============================================================================

locals {
  # AWS Regions (25 regions)
  aws_regions = [
    "us-east-1", "us-east-2", "us-west-1", "us-west-2",
    "ca-central-1", "eu-west-1", "eu-west-2", "eu-west-3",
    "eu-central-1", "eu-north-1", "ap-southeast-1", "ap-southeast-2",
    "ap-northeast-1", "ap-northeast-2", "ap-south-1", "sa-east-1",
    "ap-east-1", "me-south-1", "af-south-1", "eu-south-1",
    "ap-northeast-3", "me-central-1", "ap-south-2", "ap-southeast-3",
    "il-central-1"
  ]
  
  # GCP Regions (20 regions)
  gcp_regions = [
    "us-central1", "us-east1", "us-west1", "us-west2",
    "europe-west1", "europe-west2", "europe-west3", "europe-west4",
    "asia-southeast1", "asia-east1", "asia-northeast1", "australia-southeast1",
    "southamerica-east1", "northamerica-northeast1", "europe-north1",
    "asia-south1", "europe-central2", "us-east4", "us-west3", "us-west4"
  ]
  
  # Azure Regions (15 regions)
  azure_regions = [
    "eastus", "eastus2", "westus", "westus2", "centralus",
    "northeurope", "westeurope", "uksouth", "ukwest",
    "southeastasia", "eastasia", "japaneast", "japanwest",
    "australiaeast", "australiasoutheast"
  ]
  
  # Total: 60 regions across all providers
  total_regions = length(local.aws_regions) + length(local.gcp_regions) + length(local.azure_regions)
  
  # Total clusters: 60 regions × 50 clusters = 3000 clusters
  total_clusters = local.total_regions * var.cluster_count_per_region
  
  # Total nodes: 3000 clusters × 1000 nodes = 3,000,000 nodes
  total_nodes = local.total_clusters * var.nodes_per_cluster
}

# ============================================================================
# Outputs
# ============================================================================

output "infrastructure_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    environment           = var.environment
    total_regions        = local.total_regions
    aws_regions_count    = length(local.aws_regions)
    gcp_regions_count    = length(local.gcp_regions)
    azure_regions_count  = length(local.azure_regions)
    clusters_per_region  = var.cluster_count_per_region
    total_clusters       = local.total_clusters
    nodes_per_cluster    = var.nodes_per_cluster
    total_nodes          = local.total_nodes
    estimated_capacity   = "${local.total_nodes * 100} concurrent users per node"
  }
}

# ============================================================================
# Module Declarations (examples - to be expanded)
# ============================================================================

# VPC Module Example
module "vpc_us_east_1" {
  source = "./modules/vpc"
  
  environment = var.environment
  region      = "us-east-1"
  vpc_cidr    = "10.0.0.0/16"
  
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  database_subnets = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
  
  enable_nat_gateway = true
  enable_vpn_gateway = false
  
  tags = {
    Region = "us-east-1"
  }
}

# EKS Cluster Module Example
module "eks_us_east_1_cluster_01" {
  source = "./modules/eks"
  
  cluster_name = "zero-world-us-east-1-prod-01"
  cluster_version = "1.28"
  
  vpc_id     = module.vpc_us_east_1.vpc_id
  subnet_ids = module.vpc_us_east_1.private_subnets
  
  node_groups = {
    critical = {
      instance_types = ["r6i.32xlarge"]  # 128 vCPU, 1024 GB RAM
      min_size       = 100
      max_size       = 1000
      desired_size   = 500
      disk_size      = 500
      labels = {
        workload-type = "critical"
      }
      taints = [{
        key    = "workload-type"
        value  = "critical"
        effect = "NoSchedule"
      }]
    }
    
    standard = {
      instance_types = ["m6i.16xlarge"]  # 64 vCPU, 256 GB RAM
      min_size       = 500
      max_size       = 5000
      desired_size   = 2000
      disk_size      = 200
      labels = {
        workload-type = "standard"
      }
    }
    
    spot = {
      instance_types = ["m6i.8xlarge", "m5.8xlarge", "m5a.8xlarge"]
      capacity_type  = "SPOT"
      min_size       = 100
      max_size       = 10000
      desired_size   = 1000
      disk_size      = 100
      labels = {
        workload-type = "batch"
      }
    }
  }
  
  tags = {
    Environment = var.environment
    Region      = "us-east-1"
    Cluster     = "01"
  }
}

# RDS PostgreSQL Cluster Example
module "rds_primary" {
  source = "./modules/rds"
  
  identifier     = "zero-world-postgres-primary"
  engine         = "aurora-postgresql"
  engine_version = "15.4"
  
  instance_class = "db.r6g.16xlarge"  # 64 vCPU, 512 GB RAM
  
  replicas = 10  # 1 primary + 10 read replicas
  
  database_name = "zeroworld"
  master_username = "dbadmin"
  
  vpc_id     = module.vpc_us_east_1.vpc_id
  subnet_ids = module.vpc_us_east_1.database_subnets
  
  backup_retention_period = 35
  preferred_backup_window = "03:00-04:00"
  
  performance_insights_enabled = true
  monitoring_interval = 1
  
  tags = {
    Environment = var.environment
    DatabaseType = "primary"
  }
}

# ElastiCache Redis Cluster Example
module "redis_cache" {
  source = "./modules/elasticache"
  
  cluster_id = "zero-world-redis-cache"
  engine     = "redis"
  engine_version = "7.0"
  
  node_type = "cache.r7g.16xlarge"  # 64 vCPU, 420 GB RAM
  num_cache_nodes = 20
  
  parameter_group_name = "default.redis7.cluster.on"
  
  vpc_id     = module.vpc_us_east_1.vpc_id
  subnet_ids = module.vpc_us_east_1.private_subnets
  
  automatic_failover_enabled = true
  multi_az_enabled = true
  
  tags = {
    Environment = var.environment
    CacheType = "distributed"
  }
}

# MSK Kafka Cluster Example
module "kafka_messaging" {
  source = "./modules/msk"
  
  cluster_name = "zero-world-kafka-main"
  kafka_version = "3.5.1"
  
  number_of_broker_nodes = 1000
  
  broker_node_group_info = {
    instance_type   = "kafka.m5.24xlarge"  # 96 vCPU, 384 GB RAM
    client_subnets  = module.vpc_us_east_1.private_subnets
    security_groups = [module.vpc_us_east_1.kafka_security_group_id]
    
    storage_info = {
      ebs_storage_info = {
        volume_size = 10000  # 10 TB per broker
      }
    }
  }
  
  encryption_in_transit = {
    client_broker = "TLS"
    in_cluster    = true
  }
  
  tags = {
    Environment = var.environment
    MessageBroker = "kafka"
  }
}
