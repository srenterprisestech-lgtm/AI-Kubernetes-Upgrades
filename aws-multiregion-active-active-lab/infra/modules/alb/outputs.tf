output "security_group_id" {
  description = "ALB security group ID for restricting application ingress."
  value       = aws_security_group.this.id
}

output "target_group_arn" {
  description = "Application target group ARN."
  value       = aws_lb_target_group.this.arn
}

output "alb_dns_name" {
  description = "Public DNS name of the regional ALB."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Canonical hosted-zone ID of the regional ALB."
  value       = aws_lb.this.zone_id
}
