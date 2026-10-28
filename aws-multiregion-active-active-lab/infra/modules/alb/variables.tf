terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "name" {
  description = "Name prefix for ALB resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC in which to create the ALB."
  type        = string
}

variable "public_subnet_ids" {
  description = "At least two public subnet IDs in distinct availability zones."
  type        = list(string)
}
