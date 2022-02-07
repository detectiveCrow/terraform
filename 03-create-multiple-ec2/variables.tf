# AWS ----------------------------------------
variable "aws_access_key" {
  default = "AKIAXMMS6CFGIU357JEO"
}

variable "aws_secret_key" {
  default = "IG5dpLLZoq89Oaxf2PTrx01KVzyCyel5uWri/MWj"
}

variable "aws_region" {
  default = "ap-northeast-2"
}

# SSH ----------------------------------------
variable "ssh_public_key_path" {
  default = "/root/.ssh/aws/aws_key.pub"
}

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

variable "ansibleFilter" {
  description = "`ansibleFilter` tag value added to all instances, to enable instance filtering in Ansible dynamic inventory"
  default     = "Kubernetes01" # IF YOU CHANGE THIS YOU HAVE TO CHANGE instance_filters = tag:ansibleFilter=Kubernetes01 in ./ansible/hosts/ec2.ini
}