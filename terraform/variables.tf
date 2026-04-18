variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  default = "ami-053b0d53c279acc90"
}

variable "key_name" {
  default = "terraform-key"
}

variable "dockerhub_username" {
  default = "zeeker1"
}

variable "image_tag" {
  default = "latest"
}

variable "app_port" {
  default = 5001
}

variable "security_group_name" {
  default = "jenkins-app-sg"
}

variable "instance_name" {
  default = "jenkins-app-server"
}