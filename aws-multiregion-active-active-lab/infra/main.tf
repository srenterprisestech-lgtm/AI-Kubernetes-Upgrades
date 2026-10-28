module "dynamodb_global" {
  source = "./modules/dynamodb-global"

  table_name     = var.dynamodb_table_name
  replica_region = var.secondary_region
}

module "regions" {
  source = "./regions"

  project_name                  = var.project_name
  primary_region                = var.primary_region
  secondary_region              = var.secondary_region
  instance_type                 = var.instance_type
  mumbai_vpc_cidr               = var.mumbai_vpc_cidr
  singapore_vpc_cidr            = var.singapore_vpc_cidr
  mumbai_public_subnet_cidrs    = var.mumbai_public_subnet_cidrs
  singapore_public_subnet_cidrs = var.singapore_public_subnet_cidrs
  table_name                    = module.dynamodb_global.table_name
  table_arn                     = module.dynamodb_global.table_arn
  app_source                    = file("${path.root}/../app/server.py")
  index_source                  = file("${path.root}/../app/index.html")

  providers = {
    aws           = aws
    aws.singapore = aws.singapore
  }
}

module "route53" {
  count  = var.enable_route53 ? 1 : 0
  source = "./modules/route53"

  zone_id            = var.route53_zone_id
  app_domain         = var.app_domain
  mumbai_region      = var.primary_region
  singapore_region   = var.secondary_region
  mumbai_alb_dns     = module.regions.mumbai_alb_dns_name
  mumbai_alb_zone    = module.regions.mumbai_alb_zone_id
  singapore_alb_dns  = module.regions.singapore_alb_dns_name
  singapore_alb_zone = module.regions.singapore_alb_zone_id

  depends_on = [module.regions]
}
