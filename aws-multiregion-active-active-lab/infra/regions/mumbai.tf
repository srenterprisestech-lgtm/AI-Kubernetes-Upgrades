module "mumbai_vpc" {
  source = "../modules/vpc"

  name                = "${var.project_name}-mumbai"
  vpc_cidr            = var.mumbai_vpc_cidr
  public_subnet_cidrs = var.mumbai_public_subnet_cidrs
}

module "mumbai_alb" {
  source = "../modules/alb"

  name              = "${var.project_name}-mumbai"
  vpc_id            = module.mumbai_vpc.vpc_id
  public_subnet_ids = module.mumbai_vpc.public_subnet_ids
}

module "mumbai_ec2" {
  source = "../modules/ec2"

  name                  = "${var.project_name}-mumbai"
  instance_type         = var.instance_type
  vpc_id                = module.mumbai_vpc.vpc_id
  subnet_ids            = module.mumbai_vpc.public_subnet_ids
  alb_security_group_id = module.mumbai_alb.security_group_id
  target_group_arn      = module.mumbai_alb.target_group_arn
  table_name            = var.table_name
  table_arn             = var.table_arn
  user_data = templatefile("${path.module}/../../app/userdata.sh", {
    region       = var.primary_region
    table_name   = var.table_name
    app_source   = var.app_source
    index_source = var.index_source
  })
}
