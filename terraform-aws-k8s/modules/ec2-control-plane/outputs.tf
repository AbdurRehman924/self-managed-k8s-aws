output "instance_ids" {
  description = "List of control plane instance IDs"
  value       = aws_instance.control_plane[*].id
}

output "private_ips" {
  description = "List of control plane private IPs"
  value       = aws_instance.control_plane[*].private_ip
}

output "public_ips" {
  description = "List of control plane public IPs"
  value       = aws_instance.control_plane[*].public_ip
}
