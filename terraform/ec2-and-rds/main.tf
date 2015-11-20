variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {
  default = "ap-northeast-1"
}
variable "aws_public_key" {}
variable "db_username" {}
variable "db_password" {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region}"
}

# VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.1.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = "false"
  enable_dns_hostnames = "false"
  tags {
    Name = "my-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "my-igw" {
  vpc_id = "${aws_vpc.my-vpc.id}"
  tags {
    Name = "my-igw"
  }
}

# Subnet
## public
resource "aws_subnet" "public-c" {
  vpc_id = "${aws_vpc.my-vpc.id}"
  cidr_block = "10.1.1.0/24"
  availability_zone = "ap-northeast-1c"
  tags {
    Name = "my-subnet-public-c"
  }
}
## private for RDS
resource "aws_subnet" "private-rds-a" {
  vpc_id = "${aws_vpc.my-vpc.id}"
  cidr_block = "10.1.2.0/24"
  availability_zone = "ap-northeast-1a"
  tags {
    Name = "my-subnet-private-rds-a"
  }
}
resource "aws_subnet" "private-rds-c" {
  vpc_id = "${aws_vpc.my-vpc.id}"
  cidr_block = "10.1.3.0/24"
  availability_zone = "ap-northeast-1c"
  tags {
    Name = "my-subnet-private-rds-c"
  }
}
resource "aws_db_subnet_group" "my-rds-subnet-group" {
  name = "my-rds-subnet-group"
  description = "DB Subnet Group"
  subnet_ids = ["${aws_subnet.private-rds-a.id}", "${aws_subnet.private-rds-c.id}"]
}

# Route Table
resource "aws_route_table" "my-route" {
  vpc_id = "${aws_vpc.my-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.my-igw.id}"
  }
  tags {
    Name = "my-route-table"
  }
}

resource "aws_route_table_association" "my-assoc" {
  subnet_id = "${aws_subnet.public-c.id}"
  route_table_id = "${aws_route_table.my-route.id}"
}
resource "aws_route_table_association" "my-rds-a-assoc" {
  subnet_id = "${aws_subnet.private-rds-a.id}"
  route_table_id = "${aws_route_table.my-route.id}"
}
resource "aws_route_table_association" "my-rds-c-assoc" {
  subnet_id = "${aws_subnet.private-rds-c.id}"
  route_table_id = "${aws_route_table.my-route.id}"
}


# Security Group
### Web
resource "aws_security_group" "my-web-sg" {
  name = "my-web-sg"
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
  tags {
    Name = "my-web-sg"
  }
}
### DB
resource "aws_security_group" "my-db-sg" {
  name = "my-db-sg"
  description = "DB Security Group"
  vpc_id = "${aws_vpc.my-vpc.id}"
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = ["${aws_security_group.my-web-sg.id}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "my-db-sg"
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
    "${aws_security_group.my-web-sg.id}"
  ]
  subnet_id = "${aws_subnet.public-c.id}"
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
  key_name = "${aws_key_pair.my-key.key_name}"
}

# EIP
resource "aws_eip" "my-eip" {
  instance = "${aws_instance.my-instance.id}"
  vpc = true
}

# RDS DB Parameter Group
resource "aws_db_parameter_group" "my-rds-pg" {
  name = "my-rds-pg"
  family = "mysql5.6"
  description = "RDS parameter group"

  parameter {
    name = "character_set_server"
    value = "utf8"
  }

  parameter {
    name = "character_set_client"
    value = "utf8"
  }
}

# RDS
resource "aws_db_instance" "my-rds" {
  identifier = "my-rds"
  allocated_storage = 5
  engine = "mysql"
  engine_version = "5.6.22"
  instance_class = "db.t2.micro"
  parameter_group_name = "${aws_db_parameter_group.my-rds-pg.name}"
  # general purpose SSD
  storage_type = "gp2"
  username = "${var.db_username}"
  password = "${var.db_password}"
  backup_retention_period = 0
  vpc_security_group_ids = ["${aws_security_group.my-db-sg.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.my-rds-subnet-group.name}"
}

# Output
output "my-instance public ip" {
  value = "${aws_instance.my-instance.public_ip}"
}
output "my-rds-endpoint" {
  value = "${aws_db_instance.my-rds.address}"
}
