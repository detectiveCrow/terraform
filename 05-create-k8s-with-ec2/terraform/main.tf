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
  region  = var.aws_region
  shared_credentials_file = var.aws_shared_credentials
}

# ---------- VPC ----------
resource "aws_vpc" "k8s_vpc" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Owner   = "${var.owner}"
    Name    = "k8s_vpc"
    Service = "k8s_example"
  }
}

# ---------- IGW ----------
resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    Owner   = "${var.owner}"
    Name    = "k8s_igw"
    Service = "k8s_example"
  }
}

# ---------- RT ----------
resource "aws_route_table" "k8s_public_rt" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_igw.id
  }

  tags = {
    Owner   = "${var.owner}"
    Name    = "k8s_public_rt"
    Service = "k8s_example"
  }
}

# ---------- Subnets ----------
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "k8s_public_subnet" {
  for_each = var.aws_vpc_public_subnet

  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = each.value["cidr"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Owner   = "${var.owner}"
    Name    = "k8s_public_subnet_${each.key}"
    Service = "k8s_example"
  }
}

resource "aws_route_table_association" "k8s_public_association" {
  for_each = aws_subnet.k8s_public_subnet

  subnet_id      = each.value["id"]
  route_table_id = aws_route_table.k8s_public_rt.id
}

# ---------- Security Group ----------
resource "aws_security_group" "k8s_kubeadm_sg" {
  name        = "k8s_kubeadm_sg"
  description = "Security Group for the Kube Admin"
  vpc_id      = aws_vpc.k8s_vpc.id

  #---- Kubelet API ----
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #---- Kubernetes API server ----
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #---- SSH ----
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #---- HTTP Allow ----
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------- Key Pair ----------
resource "aws_key_pair" "aws_key" {
  key_name   = var.ssh_key_name
  public_key = file(format("%s/%s.pub",var.ssh_key_path,var.ssh_key_name))
}

# ---------- EC2 Spot Instance Requests ----------

# ----- Kube Master -----
resource "aws_instance" "master" {
  count         = var.master_count
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  associate_public_ip_address = true # Instances have public, dynamic IP

  # ----- VPC -----
  vpc_security_group_ids = ["${aws_security_group.k8s_kubeadm_sg.id}"]
  subnet_id              = aws_subnet.k8s_public_subnet[1].id

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "20"
    delete_on_termination = true
  }

  tags = {
    Owner                               = "${var.owner}"
    Name                                = "master-${count.index + 1}"
    Service                             = "k8s-example"
    "kubernetes.io/cluster/k8s-cluster" = "k8s-cluster"
  }
}

# ----- Kube Workers -----
resource "aws_instance" "worker" {
  count         = var.worker_count
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  associate_public_ip_address = true # Instances have public, dynamic IP

  # ----- VPC -----
  vpc_security_group_ids = ["${aws_security_group.k8s_kubeadm_sg.id}"]
  subnet_id              = aws_subnet.k8s_public_subnet[count.index%2 + 1].id

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "10"
    delete_on_termination = true
  }

  tags = {
    Owner                               = "${var.owner}"
    Name                                = "worker-${count.index + 1}"
    Service                             = "k8s_example"
    "kubernetes.io/cluster/k8s-cluster" = "k8s-cluster"
  }
}

# ---------- Outputs ----------
output "kubernetes_master_public_ip" {
  value = join(",", aws_instance.master.*.public_ip)
}
output "kubernetes_workers_public_ip" {
  value = join(",", aws_instance.worker.*.public_ip)
}
output "master_ssh_command" {
  value = format("ssh -i %s/%s ubuntu@%s", var.ssh_key_path, var.ssh_key_name, aws_instance.master.0.public_ip)
}

# ---------- Provision Ansible Inventory ---------- 

resource "null_resource" "worker_instances" {
  provisioner "local-exec" {
    command = <<EOD
    cat <<EOF > kube_hosts
[kubemasters]
master0 ansible_host="${aws_instance.master.0.public_ip}" ansible_user=ubuntu ansible_ssh_private_key_file=${format("%s/%s",var.ssh_key_path,var.ssh_key_name)}
[kubeworkers]
worker0 ansible_host="${aws_instance.worker.0.public_ip}" ansible_user=ubuntu ansible_ssh_private_key_file=${format("%s/%s",var.ssh_key_path,var.ssh_key_name)}
worker1 ansible_host="${aws_instance.worker.1.public_ip}" ansible_user=ubuntu ansible_ssh_private_key_file=${format("%s/%s",var.ssh_key_path,var.ssh_key_name)}
EOF
EOD
  }
}

# resource "null_resource" "master" {
#   provisioner "local-exec" {
#     command = <<EOD
#     cat <<EOF > kube_hosts
# [kubemasters]
# EOF
# EOD
#   }
# }
# resource "null_resource" "master_instances" {
#   count = var.master_count
#   provisioner "local-exec" {
#     command = <<EOD
#     cat <<EOF >> kube_hosts
# master${count.index} ansible_host="${aws_instance.master[count.index].public_ip}" ansible_user=ubuntu ansible_ssh_private_key_file=${format("%s/%s",var.ssh_key_path,var.ssh_key_name)}
# EOF
# EOD
#   }
# }

# resource "null_resource" "worker" {
#   provisioner "local-exec" {
#     command = <<EOD
#     cat <<EOF >> kube_hosts
# [kubeworkers]
# EOF
# EOD
#   }
# }
# resource "null_resource" "worker_instances" {
#   count = var.worker_count
#   provisioner "local-exec" {
#     command = <<EOD
#     cat <<EOF >> kube_hosts
# worker${count.index} ansible_host="${aws_instance.worker[count.index].public_ip}" ansible_user=ubuntu ansible_ssh_private_key_file=${format("%s/%s",var.ssh_key_path,var.ssh_key_name)}
# EOF
# EOD
#   }
# }
