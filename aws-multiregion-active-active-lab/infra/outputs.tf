output "mumbai_url" {
  description = "HTTP URL for the Mumbai regional ALB."
  value       = "http://${module.regions.mumbai_alb_dns_name}"
}

output "singapore_url" {
  description = "HTTP URL for the Singapore regional ALB."
  value       = "http://${module.regions.singapore_alb_dns_name}"
}

output "application_url" {
  description = "Route 53 application URL when DNS routing is enabled."
  value       = var.enable_route53 ? "http://${var.app_domain}" : null
}

output "route53_enabled" {
  description = "Whether the Route 53 latency records and health checks are enabled."
  value       = var.enable_route53
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB global table."
  value       = module.dynamodb_global.table_name
}

output "mumbai_asg_name" {
  description = "Mumbai Auto Scaling group name, used by the failover exercise."
  value       = module.regions.mumbai_asg_name
}

output "singapore_asg_name" {
  description = "Singapore Auto Scaling group name, used by the failover exercise."
  value       = module.regions.singapore_asg_name
}

output "mumbai_health_check_id" {
  description = "Mumbai Route 53 health-check ID, if DNS routing is enabled."
  value       = var.enable_route53 ? module.route53[0].mumbai_health_check_id : null
}

output "singapore_health_check_id" {
  description = "Singapore Route 53 health-check ID, if DNS routing is enabled."
  value       = var.enable_route53 ? module.route53[0].singapore_health_check_id : null
}
