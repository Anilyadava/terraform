output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.public_alb.dns_name
}
output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = aws_lb.public_alb.arn
}
output "log_bucket_arn" {
  value = aws_s3_bucket.log_bucket.arn
}
output "log_bucket_name" {
  value = aws_s3_bucket.log_bucket.bucket
}
output "bastion_eip_public_ip" {
  value = aws_eip.ec2-bastion-host-eip.public_ip
}
output "app_lt_id" {
  value = aws_launch_template.app_lt.id
}

