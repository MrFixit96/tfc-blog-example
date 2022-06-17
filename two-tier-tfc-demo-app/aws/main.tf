provider "aws" {
  region = var.aws_region
}

data "aws_key_pair" "us-east-1" {
  key_name = var.aws_key_pair
}

data "aws_route_table" "two-tier-tfe-demo-app" {
  vpc_id = aws_vpc.two-tier-tfe-demo-app.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_vpc" "two-tier-tfe-demo-app" {
  cidr_block = "10.0.0.0/16"
  tags                   = var.aws_instance_tags
}

resource "aws_subnet" "two-tier-tfe-demo-app" {
  vpc_id                  = aws_vpc.two-tier-tfe-demo-app.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags                   = var.aws_instance_tags
}

resource "aws_internet_gateway" "two-tier-tfe-demo-app" {
  vpc_id = "${aws_vpc.two-tier-tfe-demo-app.id}"
  tags                   = var.aws_instance_tags
}

resource "aws_route" "two-tier-tfe-demo-app-out" {
  route_table_id            = data.aws_route_table.two-tier-tfe-demo-app.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.two-tier-tfe-demo-app.id
  depends_on                = [data.aws_route_table.two-tier-tfe-demo-app]
}


resource "aws_security_group" "two-tier-tfe-demo-app" {
  name   = "two-tier-tfe-demo-app-sg"
  vpc_id = aws_vpc.two-tier-tfe-demo-app.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16", "140.177.227.38/32"]
  }

  ingress {
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16", "140.177.227.38/32"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "two-tier-tfe-demo-app" {
  name            = "two-tier-tfe-demo-app-elb"
  subnets         = [aws_subnet.two-tier-tfe-demo-app.id]
  security_groups = [aws_security_group.two-tier-tfe-demo-app.id]
  instances       = [aws_instance.two-tier-tfe-demo-app[0].id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_instance" "two-tier-tfe-demo-app" {
  count = var.num_instances

  instance_type          = var.aws_instance_type
  ami                    = data.aws_ami.ubuntu.id
  vpc_security_group_ids = [aws_security_group.two-tier-tfe-demo-app.id]
  subnet_id              = aws_subnet.two-tier-tfe-demo-app.id
  tags                   = var.aws_instance_tags
  key_name		 = data.aws_key_pair.us-east-1.key_name
  user_data = <<EOF
#!/bin/bash
sudo apt install -y nginx
EOF

}

resource "aws_sqs_queue" "example" {
  name                      = "example"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

/*
resource "aws_sqs_queue" "example2" {
  name                      = "example2"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}
*/
