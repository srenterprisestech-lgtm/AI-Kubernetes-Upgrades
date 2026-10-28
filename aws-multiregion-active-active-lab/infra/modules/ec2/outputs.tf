output "asg_name" {
  description = "Auto Scaling group name for the regional application."
  value       = aws_autoscaling_group.app.name
}

output "app_security_group_id" {
  description = "Security group ID attached to application instances."
  value       = aws_security_group.app.id
}
