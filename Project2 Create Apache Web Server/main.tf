terraform {
required_providers {
    aws = {
    source  = "hashicorp/aws"
    version = "~> 3.0"
    }
}
}

# Configure the AWS Provider
provider "aws" {
    region = "us-east-1"
    access_key = "[Access Key Here]"
    secret_key = "[Secret Access Key Here]"
}

#1 Create VPC
resource "aws_vpc" "ProdVPC" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "ProdVPC"
    }
}

#2 Create Internet Gateway
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.ProdVPC.id
    }

#3 Create Custom Route Table
resource "aws_route_table" "prod-route-table" {
vpc_id = aws_vpc.ProdVPC.id

route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
}

route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
}

tags = {
    Name = "example"
}
}

#4 Create Subnet
resource "aws_subnet" "subnet-1" {
    vpc_id     = aws_vpc.ProdVPC.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "prod-subnet"
    }
}

#5 Associate Subnet with Route Table

resource "aws_route_table_association" "a" {
    subnet_id      = aws_subnet.subnet-1.id
    route_table_id = aws_route_table.prod-route-table.id
    }

#6 Create Security Group
resource "aws_security_group" "allow-web" {
  name        = "allow_web_traffic"
  description = "Allow Web Traffic"
  vpc_id      = aws_vpc.ProdVPC.id

    ingress {
        description      = "HTTPS"
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    ingress {
        description      = "HTTP"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    ingress {
        description      = "SSH"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
  }

    tags = {
        Name = "allow_web"
    }
}

#7 Create a network interface

resource "aws_network_interface" "prod-nic" {
    subnet_id       = aws_subnet.subnet-1.id
    private_ips     = ["10.0.1.86"]
    security_groups = [aws_security_group.allow-web.id]

}

#8 Create and assign Elastic-ip

resource "aws_eip" "one" {
    vpc                       = true
    network_interface         = aws_network_interface.prod-nic.id
    associate_with_private_ip = "10.0.1.86"
    depends_on                = [aws_internet_gateway.gw]
}

#9 Create Key Pair (Not Secure)
variable "key_name" {
   description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "tempkey"
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
    key_name   = var.key_name
    public_key = tls_private_key.example.public_key_openssh

    provisioner "local-exec" {    # Generate "terraform-key-pair.pem" in current directory
        command = <<-EOF
        echo '${tls_private_key.example.private_key_pem}' > ./${var.key_name}.pem
        chmod 400 ./${var.key_name}.pem
        EOF
    }

}

#9 Create Ubuntu Server with Apache
resource "aws_instance" "app_server" {
    ami               = "ami-04505e74c0741db8d"
    instance_type     = "t2.micro"
    availability_zone = "us-east-1a"
    key_name          = aws_key_pair.generated_key.key_name
    network_interface {
      device_index         = 0
      network_interface_id = aws_network_interface.prod-nic.id
    }

    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo Cheema webserver from Terraform! > /var/www/html/index.html'
                EOF
                
    tags              = {
        Name = "CheemaUbuntu"
    }
}


