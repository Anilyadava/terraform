##APP VPC
resource "aws_vpc" "app" {
  cidr_block           = var.app_vpc_cidr
  enable_dns_hostnames = "true"
  tags = {
    Name  = "${var.environment}-app-vpc"
    Layer = "app"
  }
}
##IGW
resource "aws_internet_gateway" "app-igw" {
  vpc_id = aws_vpc.app.id
  tags = {
    Name  = "${var.environment}-igw"
    Layer = "app"
  }
}
##NAT GW
resource "aws_eip" "nat_gw" {
  domain = "vpc"
    tags = {
      Name = "${var.environment}-eip-nat-gw"
      Layer = "app"
  }
}
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gw.id
  subnet_id     = aws_subnet.app_subnet_public_a.id
  tags = {
    Name  = "${var.environment}-nat-gw"
    Layer = "app"
  }
}
##APP PUBLIC SUBNET A
resource "aws_subnet" "app_subnet_public_a" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = var.app_subnet_public_a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name  = "${var.environment}-app-public-subnet-a"
    Layer = "app"
  }
}
##APP PUBLIC SUBNET B
resource "aws_subnet" "app_subnet_public_b" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = var.app_subnet_public_b_cidr
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name  = "${var.environment}-app-public-subnet-b"
    Layer = "app"
  }
}
##APP PRIVATE SUBNET A
resource "aws_subnet" "app_subnet_private_a" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = var.app_subnet_private_a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name  = "${var.environment}-app-private-subnet-a"
    Layer = "app"
  }
}
##APP PRIVATE SUBNET B
resource "aws_subnet" "app_subnet_private_b" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = var.app_subnet_private_b_cidr
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name  = "${var.environment}-app-private-subnet-b"
    Layer = "app"
  }
}


##PUBLIC RT for app public subnet
resource "aws_route_table" "public_app_rt" {
  vpc_id = aws_vpc.app.id
  ###route for igw
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app-igw.id
  }
  ###route for app to db peering 
  route {
    cidr_block                = var.db_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering_app_to_db.id
  }
  tags = {
    Name  = "${var.environment}-app-public-rt"
    Layer = "app"
  }
}
resource "aws_route_table_association" "public_association_app_a" {
  subnet_id      = aws_subnet.app_subnet_public_a.id
  route_table_id = aws_route_table.public_app_rt.id
}
resource "aws_route_table_association" "public_association_app_b" {
  subnet_id      = aws_subnet.app_subnet_public_b.id
  route_table_id = aws_route_table.public_app_rt.id
}


##PRIVATE RT for app private subnets 
resource "aws_route_table" "private_app_rt" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  ###route for app to db peering
  route {
    cidr_block                = var.db_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering_app_to_db.id
  }
  tags = {
    Name  = "${var.environment}-app-private-rt"
    Layer = "app"
  }
}
resource "aws_route_table_association" "private_association_app_a" {
  subnet_id      = aws_subnet.app_subnet_private_a.id
  route_table_id = aws_route_table.private_app_rt.id
}
resource "aws_route_table_association" "private_association_app_b" {
  subnet_id      = aws_subnet.app_subnet_private_b.id
  route_table_id = aws_route_table.private_app_rt.id
}

##DB VPC
resource "aws_vpc" "db" {
  cidr_block           = var.db_vpc_cidr
  enable_dns_hostnames = "true"
  tags = {
    Name  = "${var.environment}-db-vpc"
    Layer = "db"

  }
}
##DB PRIVATE SUBNET A
resource "aws_subnet" "db_subnet_private_a" {
  vpc_id            = aws_vpc.db.id
  cidr_block        = var.db_subnet_private_a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name  = "${var.environment}-db-private-subnet-a"
    Layer = "db"
  }
}
##DB PRIVATE SUBNET B
resource "aws_subnet" "db_subnet_private_b" {
  vpc_id            = aws_vpc.db.id
  cidr_block        = var.db_subnet_private_b_cidr
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name  = "${var.environment}-db-private-subnet-b"
    Layer = "db"
  }
}
##PRIVATE RT for db private subnets 
resource "aws_route_table" "private_db_rt" {
  vpc_id = aws_vpc.db.id
  ###route for db to app peering
  route {
    cidr_block                = var.app_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering_app_to_db.id
  }
  tags = {
    Name  = "${var.environment}-db-private-rt"
    Layer = "db"
  }
}
resource "aws_route_table_association" "private_association_db_a" {
  subnet_id      = aws_subnet.db_subnet_private_a.id
  route_table_id = aws_route_table.private_db_rt.id
}
resource "aws_route_table_association" "private_association_db_b" {
  subnet_id      = aws_subnet.db_subnet_private_b.id
  route_table_id = aws_route_table.private_db_rt.id
}

###Peering APP & DB
resource "aws_vpc_peering_connection" "vpc_peering_app_to_db" {
  # peer_region = var.aws_region
  vpc_id      = aws_vpc.app.id
  peer_vpc_id = aws_vpc.db.id
  auto_accept = true

  tags = {
    Name  = "${var.environment}-app-db-peering"
    Layer = "peering"
  }
}
