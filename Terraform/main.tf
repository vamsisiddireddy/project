terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

# Create a VPC
resource "aws_vpc" "demo-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.VPC_NAME
  }
}

resource "aws_subnet" "demo-public-subnet-1" {
  vpc_id            = aws_vpc.demo-vpc.id
  cidr_block        = var.pubsub1
  availability_zone = var.zone1
  tags = {
    Name = "demo-public-subnet-1"
  }
}

resource "aws_subnet" "demo-public-subnet-2" {
  vpc_id            = aws_vpc.demo-vpc.id
  cidr_block        = var.pubsub2
  availability_zone = var.zone2

  tags = {
    Name = "demo-public-subnet-2"
  }
}

resource "aws_subnet" "demo-private-subnet-1" {
  vpc_id            = aws_vpc.demo-vpc.id
  cidr_block        = var.pvtsub1
  availability_zone = var.zone1

  tags = {
    Name = "demo-private-subnet-1"
  }
}

resource "aws_subnet" "demo-private-subnet-2" {
  vpc_id            = aws_vpc.demo-vpc.id
  cidr_block        = var.pvtsub2
  availability_zone = var.zone2

  tags = {
    Name = "demo-private-subnet-2"
  }
}

resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "demo-igw"
  }
}

resource "aws_route_table" "demo-pub-rt" {
  vpc_id = aws_vpc.demo-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-igw.id
  }
}

resource "aws_route_table_association" "public-association-1" {
  subnet_id      = aws_subnet.demo-public-subnet-1.id
  route_table_id = aws_route_table.demo-pub-rt.id
}

resource "aws_route_table_association" "public-association-2" {
  subnet_id      = aws_subnet.demo-public-subnet-2.id
  route_table_id = aws_route_table.demo-pub-rt.id
}


resource "aws_route_table" "demo-pvt-rt" {
  vpc_id = aws_vpc.demo-vpc.id
}

resource "aws_route_table_association" "private-association-1" {
  subnet_id      = aws_subnet.demo-private-subnet-1.id
  route_table_id = aws_route_table.demo-pvt-rt.id
}

resource "aws_route_table_association" "private-association-2" {
  subnet_id      = aws_subnet.demo-private-subnet-2.id
  route_table_id = aws_route_table.demo-pvt-rt.id
}

resource "aws_security_group" "demo-public-security-group" {
  name        = "demo-public-security-group"
  description = "Allow SSH,HTTP,HTTPS"
  vpc_id      = aws_vpc.demo-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  key_name      = "pipeline"
  ami           = var.AMIS
  instance_type = var.Type
  tags = {
    "Name" = "Visual_path"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("pipeline.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "pwd",
      "cd ~/project/Ansible/",
      "pwd",
      "ansible-playbook ~/project/Ansible/new.yaml",
      "sleep 60",
      "ansible-inventory --list",
      "ansible-playbook main.yaml"
      #"sudo ansible-playbook main.yaml"
      #"ansible-playbook main.yaml --ssh-extra-args '-o StrictHostKeyChecking=no'"
    ]
  }
}
