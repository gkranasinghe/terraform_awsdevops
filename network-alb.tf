resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Owner       = "user"
    Environment = "staging"
    Name        = "Main"
    project     = "awsdevops-ps"
  }
}

resource "aws_subnet" "subnet-1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Main"
  }
}

resource "aws_subnet" "subnet-1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "custom-route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  #   route {
  #     ipv6_cidr_block        = "::/0"
  #     egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  #   }

  tags = {
    Name = "Main"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1a.id
  route_table_id = aws_route_table.custom-route-table.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet-1b.id
  route_table_id = aws_route_table.custom-route-table.id
}

resource "aws_security_group" "ecs-sg" {
  name        = "ecs_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    // cidr_blocks      = [aws_vpc.main.cidr_block]
    //ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Owner       = "user"
    Environment = "staging"
    Name        = "allow tls http "
    project     = "awsdevops-ps"
  }
}

resource "aws_lb" "bluegreen-alb" {
  name               = "bluegreen-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs-sg.id]
  subnets            = [aws_subnet.subnet-1a.id,aws_subnet.subnet-1b.id]

  enable_deletion_protection = false

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.bucket
#     prefix  = "test-lb"
#     enabled = true
#   }

  tags = {
    Owner       = "user"
    Environment = "staging"
    Name        = "Main"
    project     = "awsdevops-ps"
  }
}

