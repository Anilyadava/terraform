module "ec2" {
  source     = "./ec2"
  aws_region = local.aws_region
  #  common_tags              = local.common_tags
  account_id         = local.account_id
  environment        = local.environment
  project            = var.project
  owner              = var.owner
  ManagedBy          = var.ManagedBy
  public_subnet_ids  = [module.vpc.public_subnet_id_a, module.vpc.public_subnet_id_b]
  private_subnet_ids = [module.vpc.private_subnet_id_a, module.vpc.private_subnet_id_b]
  app_vpc_id         = module.vpc.app_vpc_id
  iam_profile        = module.iam.app_instance_profile_name
  image_id           = var.image_id[local.environment]
  instance_type      = var.instance_type[local.environment]
  bastion_image_id   = var.bastion_image_id[local.environment]
  public_subnet_a    = module.vpc.public_subnet_id_a
  app_vpc_cidr       = var.app_vpc_cidr[local.environment]
  db_vpc_cidr        = var.db_vpc_cidr[local.environment]
  log_bucket_name    = module.ec2.log_bucket_name
}

