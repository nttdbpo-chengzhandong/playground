variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {
  default = "ap-northeast-1"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region}"
}

# VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.1.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "false"
  tags {
    Name = "my-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "my-igw" {
  vpc_id = "${aws_vpc.my-vpc.id}"
}

# Subnet
resource "aws_subnet" "public-a" {
  vpc_id = "${aws_vpc.my-vpc.id}"
  cidr_block = "10.1.1.0/24"
  availability_zone = "ap-northeast-1c"
}

resource "aws_route_table" "my-route" {
  vpc_id = "${aws_vpc.my-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.my-igw.id}"
  }
}

resource "aws_route_table_association" "puclic-a" {
  subnet_id = "${aws_subnet.public-a.id}"
  route_table_id = "${aws_route_table.my-route.id}"
}

resource "aws_security_group" "my-sg" {
  name = "my-sg"
  description = "Allow SSH inbound traffic"
  vpc_id = "${aws_vpc.my-vpc.id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "my-instance" {
  ami = "ami-b80b6db8" # CentOS7
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    "${aws_security_group.my-sg.id}"
  ]
  subnet_id = "${aws_subnet.public-a.id}"
  associate_public_ip_address = "true"
  root_block_device = {
    volume_type = "gp2"
    volume_size = "20"
  }
  ebs_block_device = {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = "100"
  }
  tags {
    Name = "my-instance"
  }
}

output "public ip of cm-test" {
  value = "${aws_instance.my-instance.public_ip}"
}
