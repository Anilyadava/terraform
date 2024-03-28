output "aws_account_id" {
  description = "The AWS Account ID"
  value       = local.account_id
}
output "module_random_password_value" {
  value = module.rds.random_password_value
  sensitive = true
}
output "module_lt_name" {
  value = module.ec2.app_lt_id
}

