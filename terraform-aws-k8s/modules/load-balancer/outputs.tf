output "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer"
  value       = aws_lb.k8s_api.dns_name
}

output "nlb_arn" {
  description = "ARN of the Network Load Balancer"
  value       = aws_lb.k8s_api.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.k8s_api.arn
}
