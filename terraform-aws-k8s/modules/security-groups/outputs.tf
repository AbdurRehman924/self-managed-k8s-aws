output "control_plane_sg_id" {
  description = "Control plane security group ID"
  value       = aws_security_group.control_plane.id
}

output "worker_sg_id" {
  description = "Worker node security group ID"
  value       = aws_security_group.worker.id
}

output "bastion_sg_id" {
  description = "Bastion security group ID"
  value       = aws_security_group.bastion.id
}

output "nlb_sg_id" {
  description = "NLB security group ID"
  value       = aws_security_group.nlb.id
}
