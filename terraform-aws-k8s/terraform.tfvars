# AWS Configuration
aws_region = "us-east-1"

# Cluster Configuration
cluster_name = "k8s-self-managed"

# Network Configuration
vpc_cidr            = "10.0.0.0/16"
availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]

# EC2 Instance Configuration
control_plane_instance_type = "t3a.medium"
worker_instance_type        = "t3a.medium"

# SSH Key
key_name = "main-key-ssh-rsa"
