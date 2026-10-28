variable "zone_id" {
  description = "ID of the existing public hosted zone."
  type        = string
}

variable "app_domain" {
  description = "Fully qualified application hostname."
  type        = string
}

variable "mumbai_region" {
  description = "AWS region used for the Mumbai latency record."
  type        = string
}

variable "singapore_region" {
  description = "AWS region used for the Singapore latency record."
  type        = string
}

variable "mumbai_alb_dns" {
  description = "Mumbai ALB DNS name."
  type        = string
}

variable "mumbai_alb_zone" {
  description = "Mumbai ALB canonical hosted-zone ID."
  type        = string
}

variable "singapore_alb_dns" {
  description = "Singapore ALB DNS name."
  type        = string
}

variable "singapore_alb_zone" {
  description = "Singapore ALB canonical hosted-zone ID."
  type        = string
}
