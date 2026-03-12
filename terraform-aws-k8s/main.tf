terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "self-managed-k8s"
      Environment = "learning"
      ManagedBy   = "terraform"
    }
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  cluster_name = var.cluster_name
  vpc_cidr     = var.vpc_cidr
  azs          = var.availability_zones
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security-groups"
  
  vpc_id       = module.vpc.vpc_id
  cluster_name = var.cluster_name
}

# IAM Module
module "iam" {
  source = "./modules/iam"
  
  cluster_name = var.cluster_name
}

# Control Plane Nodes
module "control_plane" {
  source = "./modules/ec2-control-plane"
  
  cluster_name          = var.cluster_name
  instance_type         = var.control_plane_instance_type
  instance_count        = 3
  subnet_ids            = module.vpc.public_subnet_ids
  security_group_id     = module.security_groups.control_plane_sg_id
  iam_instance_profile  = module.iam.control_plane_instance_profile
  key_name              = var.key_name
}

# Worker Nodes
module "workers" {
  source = "./modules/ec2-workers"
  
  cluster_name          = var.cluster_name
  instance_type         = var.worker_instance_type
  instance_count        = 3
  subnet_ids            = module.vpc.private_subnet_ids
  security_group_id     = module.security_groups.worker_sg_id
  iam_instance_profile  = module.iam.worker_instance_profile
  key_name              = var.key_name
}

# Bastion Host
module "bastion" {
  source = "./modules/bastion"
  
  cluster_name       = var.cluster_name
  instance_type      = "t3a.micro"
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_id  = module.security_groups.bastion_sg_id
  key_name           = var.key_name
}

# Network Load Balancer for Kubernetes API
module "load_balancer" {
  source = "./modules/load-balancer"
  
  cluster_name       = var.cluster_name
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_id  = module.security_groups.nlb_sg_id
  target_instance_ids = module.control_plane.instance_ids
}
