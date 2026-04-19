terraform {
  backend "s3" {
    bucket = "zeeker1-terraform-state"
    key    = "jenkins-lab/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "app_sg" {
  name        = var.security_group_name
  description = "Allow SSH and app traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Flask app port"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}

resource "aws_instance" "app_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    set -eux

    apt update -y
    apt install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu || true

    docker rm -f myapp || true
    docker pull ${var.dockerhub_username}/jenkins-lab:${var.image_tag}
    docker run -d \
      --name myapp \
      --restart always \
      -p ${var.app_port}:${var.app_port} \
      ${var.dockerhub_username}/jenkins-lab:${var.image_tag}
  EOF

  tags = {
    Name = var.instance_name
  }
}