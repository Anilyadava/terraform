resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.environment}-private-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name  = "${var.environment}-private-db-subnet-group"
    Layer = "db"
  }
}
##SG RDS
resource "aws_security_group" "rds-sg" {
  vpc_id      = var.db_vpc_id
  name        = "${var.environment}-RDS-sg"
  description = "security group for MySQL"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.app_vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "${var.environment}-RDS-sg"
    Layer = "app"
  }
}

###Random Password generator for RDS
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@*"
  lifecycle {
    ignore_changes = [
      length,
      special,
      override_special,
    ]
  }
}

resource "aws_rds_cluster" "mysql_aurora_cluster" {

  cluster_identifier                  = "${var.environment}-cluster"
  database_name                       = var.project
  engine                              = "aurora-mysql"
  engine_version                      = "8.0.mysql_aurora.3.04.1"
  master_username                     = "test"
  master_password                     = random_password.password.result
  backup_retention_period             = 7
  preferred_backup_window             = "02:00-03:00"
  preferred_maintenance_window        = "wed:03:00-wed:04:00"
  db_subnet_group_name                = aws_db_subnet_group.db_subnet_group.name
  storage_encrypted                   = true
  iam_database_authentication_enabled = true
  final_snapshot_identifier           = "${var.environment}-aurora-cluster"
  vpc_security_group_ids              = [aws_security_group.rds-sg.id]

  lifecycle {
    create_before_destroy = true
  }

}
resource "aws_rds_cluster_instance" "aurora_cluster_instance" {

  count                = 1
  identifier           = "${var.environment}-${count.index + 1}"
  cluster_identifier   = aws_rds_cluster.mysql_aurora_cluster.id
  instance_class       = var.rds_instance_type
  engine_version       = "8.0.mysql_aurora.3.04.1"
  ca_cert_identifier   = "rds-ca-rsa4096-g1"
  apply_immediately    = true
  engine               = "aurora-mysql"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  lifecycle {
    create_before_destroy = true
  }
}

