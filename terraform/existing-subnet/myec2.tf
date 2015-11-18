variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {
  default = "ap-northeast-1"
}
variable "aws_public_key" {}
variable "existing_vpc_id" {}
variable "existing_subnet_id" {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region}"
}

# Security Group
resource "aws_security_group" "my-sg" {
  name = "my-sg"
  description = "Allow SSH inbound traffic"
  vpc_id = "${var.existing_vpc_id}"
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

# Key Pair
resource "aws_key_pair" "my-key" {
  key_name = "my-key"
  public_key = "${var.aws_public_key}"
}

# EC2 Instance
resource "aws_instance" "my-instance" {
  ami = "ami-b80b6db8" # CentOS7
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    "${aws_security_group.my-sg.id}"
  ]
  subnet_id = "${var.existing_subnet_id}"
  associate_public_ip_address = false
  root_block_device = {
    volume_type = "gp2"
    volume_size = "20"
  }
  ebs_block_device = {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = "100"
    # delete_on_termination = false # <<<< !!!IMPORTANT!!!
  }
  tags {
    Name = "my-instance"
  }
  key_name = "my-key"
}

# EIP
resource "aws_eip" "my-eip" {
  instance = "${aws_instance.my-instance.id}"
  vpc = true
}

# Output
output "my-instance public ip" {
  value = "${aws_instance.my-instance.public_ip}"
}

