resource "aws_security_group" "ec2" {
  name   = "importio_ec2"
  vpc_id = module.vpc_rds.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["107.22.40.20/32", "18.215.226.36/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["107.22.40.20/32", "18.215.226.36/32"]
  }


  tags = {
    Name = "importio_ec2"
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "importio_ec2"

  ami                    = "ami-ebd02392"
  instance_type          = "t2.micro"
  key_name               = "importio"
  monitoring             = true
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.ec2.id]
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}