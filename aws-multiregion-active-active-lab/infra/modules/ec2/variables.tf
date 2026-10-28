terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "name" {
  description = "Name prefix for application resources."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the instance security group."
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for the Auto Scaling group."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID allowed to reach the application instances."
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group to attach to the Auto Scaling group."
  type        = string
}

variable "table_name" {
  description = "DynamoDB global table name used by the application."
  type        = string
}

variable "table_arn" {
  description = "DynamoDB global table ARN for least-privilege permissions."
  type        = string
}

variable "user_data" {
  description = "Rendered user-data script for bootstrapping the application."
  type        = string
}
