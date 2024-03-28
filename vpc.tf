module "vpc" {
  source     = "./vpc"
  aws_region = local.aws_region
  #  common_tags              = local.common_tags
  #  aws_account_id           = local.aws_account_id
  environment = local.environment
  #  project                  = var.project
  app_vpc_cidr              = var.app_vpc_cidr[local.environment]
  db_vpc_cidr               = var.db_vpc_cidr[local.environment]
  app_subnet_public_a_cidr  = var.app_subnet_public_a_cidr[local.environment]
  app_subnet_public_b_cidr  = var.app_subnet_public_b_cidr[local.environment]
  app_subnet_private_a_cidr = var.app_subnet_private_a_cidr[local.environment]
  app_subnet_private_b_cidr = var.app_subnet_private_b_cidr[local.environment]
  db_subnet_private_a_cidr  = var.db_subnet_private_a_cidr[local.environment]
  db_subnet_private_b_cidr  = var.db_subnet_private_b_cidr[local.environment]
}
