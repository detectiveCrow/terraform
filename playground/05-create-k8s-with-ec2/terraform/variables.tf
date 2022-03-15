# AWS ----------------------------------------
variable "aws_region" {}
variable "aws_shared_credentials" {
  default = "aws.credentials"
}
variable "aws_vpc_cidr" {}
variable "aws_vpc_public_subnet" {}
variable "aws_vpc_private_subnet" {}

# SSH ----------------------------------------
variable "ssh_key_path" {}
variable "ssh_key_name" {}

# Instances ----------------------------------------
variable "instance_ami" {
  description = "ami of instances"
  default     = "ami-0454bb2fefc7de534"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "master_count" {
  default = 1
}

variable "worker_count" {
  default = 2
}

variable "owner" {
  default = "Kubernetes"
}