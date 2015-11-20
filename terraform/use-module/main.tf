provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region}"
}

module "vpc" {
  source = "github.com/terraform-community-modules/tf_aws_vpc"

  name = "my-vpc"

  cidr = "10.0.0.0/16"
  private_subnets = "10.0.1.0/24,10.0.2.0/24"
  public_subnets  = "10.0.101.0/24,10.0.102.0/24"

  azs      = "ap-northeast-1a,ap-northeast-1c"
}

resource "aws_db_subnet_group" "my-rds-subnet-group" {
  name = "my-rds-subnet-group"
  description = "DB Subnet Group"
  subnet_ids = ["${element(split(",", module.vpc.private_subnets), 0)}", "${element(split(",", module.vpc.private_subnets), 1)}"]
}

# Security Group
### Web
resource "aws_security_group" "my-web-sg" {
  name = "my-web-sg"
  description = "Allow SSH inbound traffic"
  vpc_id = "${module.vpc.vpc_id}"
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
  vpc_id = "${module.vpc.vpc_id}"
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
  subnet_id = "${element(split(",", module.vpc.public_subnets), 0)}"
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
