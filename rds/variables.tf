variable "owner" {
}
variable "ManagedBy" {
}
variable "project" {
}
variable "environment" {
}
variable "aws_region" {
}
variable "account_id" {
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "db_vpc_id" {
  type = string
}
variable "bastion_public_ip" {
}
variable "rds_instance_type" {
}
variable "app_vpc_cidr" {
}
