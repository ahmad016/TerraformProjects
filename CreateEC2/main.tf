terraform {
    cloud {
        organization = "TrainingCheema"
        workspaces {
            name = "Training_AWS"
        }
    }
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 3.27"
        }
    }

    required_version = ">= 0.14.9"
}

provider "aws" {
    profile = "default"
    region  = "us-east-1"
}

#Creates a t2.micro Amazon Linux 2 ec2 instance
resource "aws_instance" "app_server" {
    ami           = "ami-01b20f5ea962e3fe7"
    instance_type = "t2.micro"

    tags = {
    Name = var.instance_name
    }
}

#Creates VPC with a /16 CIDR Block
resource "aws_vpc" "mainVPCTest" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "CheemaTest"
  }
}

#Creates an Security Group with SSH ingress traffic
resource "aws_security_group" "defaultTestC" {

    name = "AllowSSH"

    vpc_id = aws_vpc.mainVPCTest.id

    ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  #Default VPC Rules
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
    }

#Creates an elastic ip for EC2 instance
resource "aws_eip" "ip-test-env" {
  instance = "${aws_instance.app_server.id}"
  vpc      = true
}