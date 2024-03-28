output "app_vpc_id" {
  value = aws_vpc.app.id
}
output "db_vpc_id" {
  value = aws_vpc.db.id
}
output "nat_gateway_ip" {
  value = aws_eip.nat_gw.public_ip
}
output "public_subnet_id_a" {
  value       = aws_subnet.app_subnet_public_a.id
  description = "The ID of the public subnet-a."
}
output "public_subnet_id_b" {
  value       = aws_subnet.app_subnet_public_b.id
  description = "The ID of the public subnet-b."
}
output "private_subnet_id_a" {
  value       = aws_subnet.app_subnet_private_a.id
  description = "The ID of the private subnet-a."
}
output "private_subnet_id_b" {
  value       = aws_subnet.app_subnet_private_b.id
  description = "The ID of the private subnet-b."
}
output "private_subnet_id_db_a" {
  value       = aws_subnet.db_subnet_private_a.id
  description = "The ID of the private subnet-a DB."
}
output "private_subnet_id_db_b" {
  value       = aws_subnet.db_subnet_private_b.id
  description = "The ID of the private subnet-b DB."
}

