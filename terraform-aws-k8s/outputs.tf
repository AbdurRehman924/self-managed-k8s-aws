output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "control_plane_ips" {
  description = "Private IPs of control plane nodes"
  value       = module.control_plane.private_ips
}

output "control_plane_public_ips" {
  description = "Public IPs of control plane nodes"
  value       = module.control_plane.public_ips
}

output "worker_ips" {
  description = "Private IPs of worker nodes"
  value       = module.workers.private_ips
}

output "bastion_public_ip" {
  description = "Public IP of bastion host"
  value       = module.bastion.public_ip
}

output "nlb_dns_name" {
  description = "DNS name of Network Load Balancer for Kubernetes API"
  value       = module.load_balancer.nlb_dns_name
}

output "ssh_to_bastion" {
  description = "Command to SSH to bastion host"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${module.bastion.public_ip}"
}

output "ssh_to_control_plane" {
  description = "Command to SSH to first control plane node via bastion"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem -J ubuntu@${module.bastion.public_ip} ubuntu@${module.control_plane.private_ips[0]}"
}
