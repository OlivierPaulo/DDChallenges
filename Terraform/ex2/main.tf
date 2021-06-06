terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"

  
  # Initial apply locally to create the AWS S3 bucket
    # backend "local" {
    # }



  # Store the tf state remotely on AWS S3 (Creaton of bucket below)
  backend "s3" {

    bucket  = "dd-op-challenges"
    key     = "DD-Challenges/tfstate/"
    region  = "us-west-2"
    encrypt = true
  }

}

# Declare provider : AWS
provider "aws" {
  profile = "default"
  region  = var.region_name
}


# Creating S3 Bucket (to store tf remote states)
resource "aws_s3_bucket" "terraform_state_s3" {

  bucket        = "dd-op-challenges"
  versioning {
    enabled = true
  }
  tags = {
    Name = "AWS-S3-Terraform-Bucket"
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# Calling the VPC module
module "vpc" {
  source = "./modules/vpc"

}


# Creating EC2 instance 
resource "aws_instance" "public-ec2" {
  ami                    = "ami-0fc272c9b2d204826" ## AMI-ID for Ubuntu 20.04 LTS
  instance_type          = var.instance_type
  subnet_id              = module.vpc.subnet_public_id
  vpc_security_group_ids = [module.vpc.ec2_sg_id]

  tags = {
    Name = "EC2-Server"
  }
}

# Creating Elastic IP for EC2 machine (Public IP)
resource "aws_eip" "elastic_ip" {

  instance                  = aws_instance.public-ec2.id
  vpc                       = true
  associate_with_private_ip = aws_instance.public-ec2.private_ip
  depends_on                = [module.vpc.internet_gateway]

  tags = {
    Name = "EC2-Elastic-IP"
  }
}

# Creating RDS (Postgre DB)
## Declare paramater group
resource "aws_db_parameter_group" "db_parameter_group" {
  name   = "parametergroup"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  tags = {
    Name = "parametergroup"
  }
}

## Declare AWS DB instance
resource "aws_db_instance" "rds_postgre_db" {
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "13.1"
  username               = "do_not_use_sa"
  password               = var.db_password
  db_subnet_group_name   = module.vpc.rds_subnet_group_name
  vpc_security_group_ids = [module.vpc.rds_security_group_id]
  parameter_group_name   = aws_db_parameter_group.db_parameter_group.name

  tags = {
    Name = "AWS-POSTGRE-DB"
  }
}

