terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"  # Change this to your preferred region
}

resource "aws_vpc" "foo_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "foo-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.foo_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  
  tags = {
    Name = "foo-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.foo_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  
  tags = {
    Name = "foo-public-subnet-2"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.foo_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2c"
  
  tags = {
    Name = "foo-private-subnet"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "foo-app-sg"
  description = "Security group for Foo app instances"
  vpc_id      = aws_vpc.foo_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_sg" {
  name        = "foo-db-sg"
  description = "Security group for Foo database instance"
  vpc_id      = aws_vpc.foo_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_instance_1" {
  ami           = "ami-0c55b159cbfafe1f0"  # Ubuntu 22.04 LTS
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  
  tags = {
    Name = "foo-app-instance-1"
  }
}

resource "aws_instance" "app_instance_2" {
  ami           = "ami-0c55b159cbfafe1f0"  # Ubuntu 22.04 LTS
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_2.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  
  tags = {
    Name = "foo-app-instance-2"
  }
}

resource "aws_instance" "db_instance" {
  ami           = "ami-0c55b159cbfafe1f0"  # Ubuntu 22.04 LTS
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  
  tags = {
    Name = "foo-db-instance"
  }
}

resource "aws_lb" "foo_lb" {
  name               = "foo-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

resource "aws_lb_target_group" "foo_tg" {
  name     = "foo-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.foo_vpc.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.foo_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.foo_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "tg_attachment_1" {
  target_group_arn = aws_lb_target_group.foo_tg.arn
  target_id        = aws_instance.app_instance_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tg_attachment_2" {
  target_group_arn = aws_lb_target_group.foo_tg.arn
  target_id        = aws_instance.app_instance_2.id
  port             = 80
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.foo_lb.dns_name
}
