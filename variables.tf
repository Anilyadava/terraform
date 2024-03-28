variable "owner" {
  default = "Mike Mahan"
}
variable "ManagedBy" {
  default = "terraform"
}
variable "project" {
  default = "romiworld"
}

variable "aws_region" {
  default = {
    dev  = "us-east-1"
    prod = "us-east-1"
  }
}
variable "aws_profile" {
  default = {
    dev  = "romi"
    prod = "romi-prod"
  }
}
variable "app_vpc_cidr" {
  default = {
    dev  = "10.60.4.0/23"
    prod = "10.61.4.0/23"
  }
}
variable "app_subnet_public_a_cidr" {
  default = {
    dev  = "10.60.4.0/26"
    prod = "10.61.4.0/26"
  }
}
variable "app_subnet_public_b_cidr" {
  default = {
    dev  = "10.60.4.64/26"
    prod = "10.61.4.64/26"
  }
}
variable "app_subnet_private_a_cidr" {
  default = {
    dev  = "10.60.5.0/26"
    prod = "10.61.5.0/26"
  }
}
variable "app_subnet_private_b_cidr" {
  default = {
    dev  = "10.60.5.64/26"
    prod = "10.61.5.64/26"
  }
}
variable "db_vpc_cidr" {
  default = {
    dev  = "10.60.10.0/23"
    prod = "10.61.10.0/23"
  }
}
variable "db_subnet_private_a_cidr" {
  default = {
    dev  = "10.60.11.0/26"
    prod = "10.61.11.0/26"
  }
}
variable "db_subnet_private_b_cidr" {
  default = {
    dev  = "10.60.11.64/26"
    prod = "10.61.11.64/26"
  }
}
variable "image_id" {
  default = {
    dev  = "ami-0c7217cdde317cfec"
    prod = "ami-0c7217cdde317cfec"
  }
}
variable "instance_type" {
  default = {
    dev  = "t3.micro"
    prod = "t3.medium"
  }
}
variable "bastion_image_id" {
  default = {
    dev  = "ami-00d990e7e5ece7974"
    prod = "ami-00d990e7e5ece7974"
  }
}
variable "rds_instance_type" {
  default = {
    dev  = "db.t3.medium"
    prod = "db.t3.medium"
  }
}
