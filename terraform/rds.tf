
data "aws_availability_zones" "available" {}

module "vpc_rds" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = "importio"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "importio" {
  name       = "importio"
  subnet_ids = module.vpc_rds.public_subnets

  tags = {
    Name = "importio"
  }
}

resource "aws_security_group" "rds" {
  name   = "importio_rds"
  vpc_id = module.vpc_rds.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [module.ec2_instance.public_ip]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [module.ec2_instance.public_ip]
  }

  tags = {
    Name = "importio_rds"
  }
}

resource "aws_db_parameter_group" "importio" {
  name   = "importio-sq-grp"
  family = "mysql8.0"

  parameter {
    name  = "slow_query_log"
    value = "1"
  }
}

resource "aws_db_instance" "importio" {
  identifier             = "importio"
  instance_class         = "t2.micro"
  allocated_storage      = 50
  max_allocated_storage = 100
  engine                 = "mysql"
  engine_version         = "8.0"
  username               = var.db_user
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.importio.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.importio.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}
