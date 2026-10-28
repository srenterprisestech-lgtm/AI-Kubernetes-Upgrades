variable "project_name" {
  description = "Prefix used to name regional resources."
  type        = string
}

variable "primary_region" {
  description = "AWS region for Mumbai."
  type        = string
}

variable "secondary_region" {
  description = "AWS region for Singapore."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type used in both regions."
  type        = string
}

variable "mumbai_vpc_cidr" {
  description = "Mumbai VPC CIDR."
  type        = string
}

variable "singapore_vpc_cidr" {
  description = "Singapore VPC CIDR."
  type        = string
}

variable "mumbai_public_subnet_cidrs" {
  description = "Mumbai public subnet CIDRs."
  type        = list(string)
}

variable "singapore_public_subnet_cidrs" {
  description = "Singapore public subnet CIDRs."
  type        = list(string)
}

variable "table_name" {
  description = "DynamoDB global table name."
  type        = string
}

variable "table_arn" {
  description = "DynamoDB global table ARN."
  type        = string
}

variable "app_source" {
  description = "Application source installed on each EC2 instance."
  type        = string
}

variable "index_source" {
  description = "HTML page installed on each EC2 instance."
  type        = string
}
