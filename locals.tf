# local variables
locals {
  environment = terraform.workspace
  account_id  = data.aws_caller_identity.current.account_id
  aws_profile = var.aws_profile[local.environment]
  aws_region  = var.aws_region[local.environment]
  #  name_prefix = "${var.project}-${local.environment}"
}

