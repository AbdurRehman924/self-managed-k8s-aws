output "control_plane_instance_profile" {
  description = "Control plane instance profile name"
  value       = aws_iam_instance_profile.control_plane.name
}

output "worker_instance_profile" {
  description = "Worker instance profile name"
  value       = aws_iam_instance_profile.worker.name
}

output "control_plane_role_arn" {
  description = "Control plane IAM role ARN"
  value       = aws_iam_role.control_plane.arn
}

output "worker_role_arn" {
  description = "Worker IAM role ARN"
  value       = aws_iam_role.worker.arn
}
