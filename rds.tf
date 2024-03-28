module "rds" {
  source     = "./rds"
  aws_region = local.aws_region
  #  common_tags              = local.common_tags
  account_id         = local.account_id
  environment        = local.environment
  project            = var.project
  owner              = var.owner
  ManagedBy          = var.ManagedBy
  private_subnet_ids = [module.vpc.private_subnet_id_db_a, module.vpc.private_subnet_id_db_b]
  db_vpc_id          = module.vpc.db_vpc_id
  bastion_public_ip  = module.ec2.bastion_eip_public_ip
  rds_instance_type  = var.rds_instance_type[local.environment]
  app_vpc_cidr       = var.app_vpc_cidr[local.environment]
}


