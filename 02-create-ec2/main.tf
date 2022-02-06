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
  access_key = "AKIAXMMS6CFGISGR5Q43"
  secret_key = "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"
  region     = "ap-northeast-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0454bb2fefc7de534"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}
