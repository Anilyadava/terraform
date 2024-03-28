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
variable "public_subnet_ids" {
  type = list(string)
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "app_vpc_id" {
  type = string
}
variable "iam_profile" {
}
variable "image_id" {
}
variable "instance_type" {
}
variable "bastion_image_id" {
}
variable "public_subnet_a" {
}
variable "app_vpc_cidr"{
}
variable "db_vpc_cidr" {
}
variable "log_bucket_name" {
}
