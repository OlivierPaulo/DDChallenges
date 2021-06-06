# Adding global/Main VPC
resource "aws_vpc" "global" {
  cidr_block           = "10.0.0.0/22"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Declare Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.global.id
}

# Declare route table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.global.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Associate subnet and route table
resource "aws_route_table_association" "table_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.route_table.id
}

# Retrieve AWS Availability zones for subnets
data "aws_availability_zones" "available" {
  state = "available"
}

# Declare "public" subnet for EC2 machine(s)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.global.id
  cidr_block              = "10.0.0.0/23"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  depends_on              = [aws_internet_gateway.gw]
}

# Declare first private subnet for RDS machine(s)
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

# Declare subnet group for RDS machine(s)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
}

# Declare EC2 security group
resource "aws_security_group" "ec2_sg" {
  name        = "allow_http-s_ssh"
  description = "Allow HTTP, HTTPS and SSH inbound trafic for EC2 Security Group"
  vpc_id      = aws_vpc.global.id

  # Only 22, 80, 443 inbound connections are allow from everywhere. 
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

}

# Declare RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "allow_ec2_only"
  description = "Allow only EC2 subnet in inbound"
  vpc_id      = aws_vpc.global.id

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

}
