output "fqdn" {
  description = "Application DNS name."
  value       = var.app_domain
}

output "mumbai_health_check_id" {
  description = "Mumbai Route 53 health-check ID."
  value       = aws_route53_health_check.mumbai.id
}

output "singapore_health_check_id" {
  description = "Singapore Route 53 health-check ID."
  value       = aws_route53_health_check.singapore.id
}
