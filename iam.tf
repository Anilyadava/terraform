module "iam" {
  source     = "./iam"
  aws_region = local.aws_region
  #  common_tags              = local.common_tags
  #  aws_account_id           = local.aws_account_id
  environment = local.environment
  #  project                  = var.project
  log_bucket_arn = module.ec2.log_bucket_arn
}

