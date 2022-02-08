# AWS ----------------------------------------
variable "aws_profile" {}
variable "aws_region" {}
variable "aws_vpc_cidr" {}
variable "aws_vpc_subnet_cidrs" {}

# SSH ----------------------------------------
variable "ssh_public_key_path" {}

variable "ssh_key_name" {
  default = "ssh-key"
}

# Instances ----------------------------------------
variable "instance_ami" {
  description = "ami of instances"
  default     = "ami-0454bb2fefc7de534"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "owner" {
  default = "Kubernetes"
}