# Terraform Basics


As a reminder, the Exercice 1 objective is to deploy the following Infrastructure :

An AWS `VPC` where : 
> Only Ports **80**, **443** and **22** are open to **Internet**.
  Create an `EC2 machine` (smallest one possible) which has access to an `RDS machine` (db engine : `postgres`, smallest one possible). The RDS machine is not publicly available.

## The VPC Module

The VPC module source is fully declared inside `/modules/vpc` folder.
Inside `modules/vpc/main.tf`, I declared the following __elements__ :

### VPC

```terraform 
resource "aws_vpc" "global" {
  cidr_block           = "10.0.0.0/22"
  enable_dns_hostnames = true
  enable_dns_support   = true
}
```

Here I declare the CIDR block for my VPC with a `/22` mask :
- to have 1024 IPs addresses on my private network. 
- to create after 1 `/23` mask subnet for my EC2 future machine(s).
- to create after 2 `/24` mask subnets for my RDS future machine(s). The RDS machines will need 2 subnets and 2 availability zones.

I have enabled DNS hostnames and support. 

### Internet Gateway

Declaration of an Internet Gateway to allow my machines access to have Outbound Internet connections.

### Route table

```
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.global.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}
```
Declaration of the route table to link my Internet Gateway with the world `0.0.0.0/0`

### Route table association

Declaration of the route table association where I associate my EC2 subnet to the route table.

### Availability zones for subnets

Declaration of the availabilty zones for the subnets (for EC2 and RDS subnets)

### "Public" EC2 subnet

```
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.global.id
  cidr_block              = "10.0.0.0/23"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  depends_on              = [aws_internet_gateway.gw]
}
```
Declaration of the `/23` subnet for my EC2 machines `10.0.0.0 -> 10.0.1.255` with :
- one availabity zone for this subnet.
- automatic map of public IP on launch (related to Elastic IP).
- dependancy on the Internet Gateway.

### "Private" RDS subnets

Here I have declared two `/24` subnets for RDS machine(s) `10.0.2.0 -> 10.0.2.255` and `10.0.3.0 -> 10.0.3.255`. Each subnet has its own availability zone :

```
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.global.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
}

# Declare second private subnet for RDS machine(s)"
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.global.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
}
```

### DB Subnet Group

```
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
}
```

Declaration of the DB subnet group with the 2 "private" subnets created for RDS machine(s).

### Security Groups

- Security Group for EC2 subnet

Declaration of the security group to allow inbound connections on EC2 subnet on only TCP ports 443 (HTTPS), 80 (HTTP), 22 (SSH). Regarding Outbound connections, all ports, all protocols and all Internet IPs are allowed. 

```
...
  ingress {
    description = "Allow TLS (HTTPS) Connections"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTP Connections"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow SSH Connections"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Any ports, any IPs are allowed in outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
...
```

- Security Group for RDS subnets

```
...
  # Only ports 5432 & 5433 are allowed from EC2 subnet to RDS subnets
  ingress {
    description = "Allow only Postgre ports Inbound connections from EC2 subnet"
    from_port   = 5432
    to_port     = 5433
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public.cidr_block]
  }

  # Any ports, any IPs are allowed in outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
...
```
Here in inbound connections is allowed only TCP ports 5432 and 5433 (default port for postgres and a backup postgres port) from the "Public" subnet (subnet for EC2 machines)

The VPC module will create some values as **Outputs** (Subnets IDs, Security Groups IDs, Internet Gateway, DB Subnet group Name) that will be needed then to create AWS EC2 Instance(s) and RDS machine(s). Thanks to the `modules/vpc/outputs.tf` file where will retrieve those values and stored them inside modules outputs variables. 

The VPC module including all these resources is then called and declared in the main terraform `main.tf` file with the following lines :
```
module "vpc" {
  source = "./modules/vpc"
}
```

This main terraform `main.tf` file also included the rest of the main configuration :

## The EC2 Instance

```
resource "aws_instance" "public-ec2" {
  ami                    = "ami-0fc272c9b2d204826" ## AMI-ID for Ubuntu 20.04 LTS
  instance_type          = var.instance_type
  subnet_id              = module.vpc.subnet_public_id
  vpc_security_group_ids = [module.vpc.ec2_sg_id]
}
```

Declaration of the AWS EC2 Instance with an AMI ID corresponding to Ubuntu 20.04. 
The instance type is declared as a variable inside `variables.tf`. Value here is a **t2.nano**.
Subnet ID and Security Group ID are retrieved from our VPC module outputs variables `modules/vpc/outputs.tf`

## Elastic IP for EC2

```
resource "aws_eip" "elastic_ip" {
  instance                  = aws_instance.public-ec2.id
  vpc                       = true
  associate_with_private_ip = aws_instance.public-ec2.private_ip
  depends_on                = [module.vpc.internet_gateway]
}
```

Declaration and allocation of the Elastic IP (public Internet IP) to our EC2 instance created above.

## The RDS machine

```
resource "aws_db_parameter_group" "db_parameter_group" {
  name   = "parametergroup"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
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

}
```

Creation of the RDS machine inside the postgres13 family with :
- version 13.1
- db.t3.micro instance class
- 5 GB of allocated storage
- username and password
- Subnet Group name, Security Group ID (coming from modules outputs)
- paramater group defined above

## S3 Bucket

```
resource "aws_s3_bucket" "terraform_state_s3" {
  bucket        = "dd-op-challenges"
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
```

Creation of the S3 bucket with server side encryption using AES256 algorithm.

## AWS Provider

This specify here that we will create our Infrastructure in AWS in region name selected. I have selected to create all the resource in `us-west-2`.

## S3 Backend

States of Terraform are stored remotely and encrypted in a S3 bucket.