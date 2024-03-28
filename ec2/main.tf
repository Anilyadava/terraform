##SG bastion
resource "aws_security_group" "bastion-sg" {
  vpc_id      = var.app_vpc_id
  name        = "${var.environment}-bastion-sg"
  description = "security group for bastion that allows RDP and all egress traffic"
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["35.177.238.18/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "${var.environment}-bastion-sg"
    Layer = "app"
  }
}

###Bastion Server to access DB and App Server 
resource "aws_instance" "bastion" {
  ami                         = var.bastion_image_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_a
  vpc_security_group_ids      = [aws_security_group.bastion-sg.id]
  key_name                    = aws_key_pair.key_pair_app.key_name
  associate_public_ip_address = false
  disable_api_termination     = true
  root_block_device {
    volume_size           = 50
    delete_on_termination = true
    volume_type           = "gp2"
    tags = {
      Name  = "${var.environment}-bastion-ebs"
      Layer = "app"
    }
  }
  tags = {
    Name  = "${var.environment}-bastion-server"
    Layer = "app"
  }
  lifecycle {
    ignore_changes = [
      associate_public_ip_address,
    ]
  }
}
## EC2 Bastion Host Elastic IP
resource "aws_eip" "ec2-bastion-host-eip" {
  domain = "vpc"
  tags = {
    Name  = "${var.environment}-eip-bastion"
    Layer = "app"
  }
}
## EC2 Bastion Host Elastic IP Association
resource "aws_eip_association" "ec2-bastion-host-eip-association" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.ec2-bastion-host-eip.id
}
###S3 Log Files Bucket 
resource "aws_s3_bucket" "log_bucket" {
  bucket        = "terraform-${var.project}-log-${var.environment}"
  force_destroy = false
  tags = {
    Name  = "terraform-romiworld-log-${var.environment}"
    Layer = "storage"
  }
}
resource "aws_s3_bucket_policy" "elb_logging" {
  bucket = aws_s3_bucket.log_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "ELBPlicy"
    Statement = [
      {
        Sid    = "S3PutPolicy"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.log_bucket.arn}/*"
      },
    ]
  })
}
### Key Pair
resource "aws_key_pair" "key_pair_app" {
  key_name   = "${var.project}-${var.environment}"
  public_key = file("/home/ubuntu/.ssh/romiworld.pub")
}
## SG app
resource "aws_security_group" "app_sg" {
  name        = "${var.environment}-app-sg"
  description = "SG for app"
  vpc_id      = var.app_vpc_id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    description = "mysql"
    cidr_blocks = [var.db_vpc_cidr]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = [var.app_vpc_cidr]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "${var.environment}-app-sg"
    Layer = "app"
  }
}
## SG for ALB
resource "aws_security_group" "alb_sg" {
  name        = "${var.environment}-app-sg-alb"
  description = "SG for alb"
  vpc_id      = var.app_vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name  = "${var.environment}-app-sg-alb"
    Layer = "app"

  }
}
## APP ALB
resource "aws_lb" "public_alb" {
  name                       = "${var.environment}-public-app-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = false

  #  access_logs {
  #    bucket  = aws_s3_bucket.log_bucket.id
  #    prefix  = "access-logs"
  #    enabled = true
  #  }

  tags = {
    Name  = "${var.environment}-public-app-alb"
    Layer = "app"
  }
}

##Target Group
resource "aws_lb_target_group" "target_group_app" {
  name     = "${var.environment}-public-app-alb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.app_vpc_id
  health_check {
    interval            = 30
    path                = "/index.html"
    port                = 80
    healthy_threshold   = 4
    unhealthy_threshold = 3
    timeout             = 10
    protocol            = "HTTP"
    matcher             = "200"
  }
}
###Target Group Attachment 
#resource "aws_lb_target_group_attachment" "alb_tg_attach" {
#  target_group_arn = aws_lb_target_group.target_group_app.arn
#  target_id        = aws_lb.public_alb.arn
#  port       	   = 80
#}
##Listener 1 
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = "80"
  protocol          = "HTTP"
#  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_app.arn
  }
}
##Launch Template
resource "aws_launch_template" "app_lt" {
  name = "${var.environment}-app-lt"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 50
    }
  }
  # disable_api_stop        = true
  # disable_api_termination = true

  ebs_optimized = true

  iam_instance_profile {
    name = var.iam_profile
  }
  image_id                             = var.image_id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = var.instance_type
  key_name                             = aws_key_pair.key_pair_app.key_name
  update_default_version               = true
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  monitoring {
    enabled = true
  }
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  #  tag_specifications {
  #    resource_type = "launch-template"
  #
  #    tags = {
  #      Name  = "${var.environment}-app-lt"
  #      Layer = "app"
  #    }
  #  }
  user_data = base64encode(<<EOT
#!/bin/bash
mkdir /home/ubuntu/userdata
cd /home/ubuntu/userdata
sudo apt update -y
sudo apt install awscli -y
aws s3 cp s3://${var.log_bucket_name}/romi_userdata.sh .
sudo chmod +x romi_userdata.sh
./romi_userdata.sh
EOT
  )
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                 = "${var.environment}-app-asg"
  desired_capacity     = 1
  max_size             = 2
  min_size             = 1
  force_delete         = true
  depends_on           = [aws_lb.public_alb]
  target_group_arns    = ["${aws_lb_target_group.target_group_app.arn}"]
  health_check_type    = "EC2"
  vpc_zone_identifier  = var.private_subnet_ids
  termination_policies = ["NewestInstance", "OldestLaunchTemplate"]
  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
  tag {
    key                 = "Layer"
    value               = "${var.environment}-app-asg"
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = "${var.environment}-app"
    propagate_at_launch = true
  }
  tag {
    key                 = "Owner"
    value               = var.owner
    propagate_at_launch = true
  }
  tag {
    key                 = "ManagedBy"
    value               = var.ManagedBy
    propagate_at_launch = true
  }
  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = true
  }
}

