module "singapore_vpc" {
  source = "../modules/vpc"

  name                = "${var.project_name}-singapore"
  vpc_cidr            = var.singapore_vpc_cidr
  public_subnet_cidrs = var.singapore_public_subnet_cidrs

  providers = {
    aws = aws.singapore
  }
}

module "singapore_alb" {
  source = "../modules/alb"

  name              = "${var.project_name}-singapore"
  vpc_id            = module.singapore_vpc.vpc_id
  public_subnet_ids = module.singapore_vpc.public_subnet_ids

  providers = {
    aws = aws.singapore
  }
}

module "singapore_ec2" {
  source = "../modules/ec2"

  name                  = "${var.project_name}-singapore"
  instance_type         = var.instance_type
  vpc_id                = module.singapore_vpc.vpc_id
  subnet_ids            = module.singapore_vpc.public_subnet_ids
  alb_security_group_id = module.singapore_alb.security_group_id
  target_group_arn      = module.singapore_alb.target_group_arn
  table_name            = var.table_name
  table_arn             = var.table_arn
  user_data = templatefile("${path.module}/../../app/userdata.sh", {
    region       = var.secondary_region
    table_name   = var.table_name
    app_source   = var.app_source
    index_source = var.index_source
  })

  providers = {
    aws = aws.singapore
  }
}
