output "mumbai_alb_dns_name" {
  description = "Mumbai ALB DNS name."
  value       = module.mumbai_alb.alb_dns_name
}

output "mumbai_alb_zone_id" {
  description = "Mumbai ALB canonical hosted-zone ID."
  value       = module.mumbai_alb.alb_zone_id
}

output "singapore_alb_dns_name" {
  description = "Singapore ALB DNS name."
  value       = module.singapore_alb.alb_dns_name
}

output "singapore_alb_zone_id" {
  description = "Singapore ALB canonical hosted-zone ID."
  value       = module.singapore_alb.alb_zone_id
}

output "mumbai_asg_name" {
  description = "Mumbai Auto Scaling group name."
  value       = module.mumbai_ec2.asg_name
}

output "singapore_asg_name" {
  description = "Singapore Auto Scaling group name."
  value       = module.singapore_ec2.asg_name
}
