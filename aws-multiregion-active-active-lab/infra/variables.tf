variable "project_name" {
  description = "Prefix used to name lab resources."
  type        = string
  default     = "active-active-lab"
}

variable "primary_region" {
  description = "AWS region for the Mumbai environment."
  type        = string
  default     = "ap-south-1"
}

variable "secondary_region" {
  description = "AWS region for the Singapore environment."
  type        = string
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "EC2 instance type used by both regional Auto Scaling groups."
  type        = string
  default     = "t3.micro"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB global table used by the demo application."
  type        = string
  default     = "active-active-lab-events"
}

variable "enable_route53" {
  description = "Whether to create latency-based Route 53 records and health checks."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_route53 || (var.route53_zone_id != "" && var.app_domain != "")
    error_message = "Set route53_zone_id and app_domain when enable_route53 is true."
  }
}

variable "route53_zone_id" {
  description = "ID of an existing public Route 53 hosted zone."
  type        = string
  default     = ""
}

variable "app_domain" {
  description = "Fully qualified DNS name for the application, such as app.example.com."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to resources that support tagging."
  type        = map(string)
  default = {
    Project   = "aws-multiregion-active-active-lab"
    ManagedBy = "Terraform"
  }
}

variable "mumbai_vpc_cidr" {
  description = "IPv4 CIDR block for the Mumbai VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "singapore_vpc_cidr" {
  description = "IPv4 CIDR block for the Singapore VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "mumbai_public_subnet_cidrs" {
  description = "Public subnet CIDRs in the Mumbai VPC; provide exactly two."
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24"]

  validation {
    condition     = length(var.mumbai_public_subnet_cidrs) == 2
    error_message = "Provide exactly two Mumbai public subnet CIDRs for the ALB."
  }
}

variable "singapore_public_subnet_cidrs" {
  description = "Public subnet CIDRs in the Singapore VPC; provide exactly two."
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]

  validation {
    condition     = length(var.singapore_public_subnet_cidrs) == 2
    error_message = "Provide exactly two Singapore public subnet CIDRs for the ALB."
  }
}
