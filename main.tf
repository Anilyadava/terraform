terraform {
  backend "s3" {
    region  = "us-east-1"
    key     = "terrraform.tfstate"
    encrypt = "true"
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 0.13"
}
provider "aws" {
  region = local.aws_region
  #  profile = local.aws_profile
  default_tags {
    tags = {
      Environment = local.environment
      Project     = var.project
      Owner       = var.owner
      ManagedBy   = "terraform"
    }
  }
}
#resource "aws_s3_bucket" "backend_s3" {
#  bucket = "terraform-romiworld-${local.environment}"
#  force_destroy = true
#  tags = {
#    Name  = "terraform-romiworld-${local.environment}"
#    Layer = "storage"
#  }
#}
#resource "aws_s3_bucket_versioning" "backend_s3_versioning" {
#  bucket = aws_s3_bucket.backend_s3.id
#  versioning_configuration {
#    status = "Enabled"
#  }
#}
