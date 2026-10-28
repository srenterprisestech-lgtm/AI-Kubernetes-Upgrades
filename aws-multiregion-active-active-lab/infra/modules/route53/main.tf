resource "aws_route53_health_check" "mumbai" {
  fqdn              = var.mumbai_alb_dns
  port              = 80
  type              = "HTTP"
  resource_path     = "/healthz"
  request_interval  = 30
  failure_threshold = 3

  tags = {
    Name = "active-active-mumbai"
  }
}

resource "aws_route53_health_check" "singapore" {
  fqdn              = var.singapore_alb_dns
  port              = 80
  type              = "HTTP"
  resource_path     = "/healthz"
  request_interval  = 30
  failure_threshold = 3

  tags = {
    Name = "active-active-singapore"
  }
}

resource "aws_route53_record" "mumbai" {
  zone_id        = var.zone_id
  name           = var.app_domain
  type           = "A"
  set_identifier = "mumbai"

  latency_routing_policy {
    region = var.mumbai_region
  }

  alias {
    name                   = var.mumbai_alb_dns
    zone_id                = var.mumbai_alb_zone
    evaluate_target_health = true
  }

  health_check_id = aws_route53_health_check.mumbai.id
}

resource "aws_route53_record" "singapore" {
  zone_id        = var.zone_id
  name           = var.app_domain
  type           = "A"
  set_identifier = "singapore"

  latency_routing_policy {
    region = var.singapore_region
  }

  alias {
    name                   = var.singapore_alb_dns
    zone_id                = var.singapore_alb_zone
    evaluate_target_health = true
  }

  health_check_id = aws_route53_health_check.singapore.id
}
