terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

resource "aws_key_pair" "aws_key" {
  key_name   = var.ssh_key_name
  public_key = file("${var.ssh_public_key_path}")
}

resource "aws_instance" "master" {
  count         = 1
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  associate_public_ip_address = true # Instances have public, dynamic IP

  tags = {
    Owner           = "${var.owner}"
    Name            = "master-${count.index}"
    ansibleFilter   = "${var.ansibleFilter}"
    ansibleNodeType = "master"
    ansibleNodeName = "master-${count.index}"
  }
}

resource "aws_instance" "worker" {
  count         = 1
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  associate_public_ip_address = true # Instances have public, dynamic IP

  tags = {
    Owner           = "${var.owner}"
    Name            = "worker-${count.index}"
    ansibleFilter   = "${var.ansibleFilter}"
    ansibleNodeType = "worker"
    ansibleNodeName = "worker-${count.index}"
  }
}

output "kubernetes_master_public_ip" {
  value = join(",", aws_instance.master.*.public_ip)
}
output "kubernetes_workers_public_ip" {
  value = join(",", aws_instance.worker.*.public_ip)
}