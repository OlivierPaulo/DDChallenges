output "subnet_public_id" {
  description = "ID of public subnet"
  value       = aws_subnet.public.id

}

output "ec2_sg_id" {
  description = "ID of EC2 Security Group"
  value       = aws_security_group.ec2_sg.id
}

output "rds_subnet_group_name" {
  description = "Name of RDS Subnet Group"
  value       = aws_db_subnet_group.rds_subnet_group.name
}

output "rds_security_group_id" {
  description = "ID of RDS Security Group"
  value       = aws_security_group.rds_sg.id
}

output "internet_gateway" {
  description = "Internet Gateway for VPC"
  value       = aws_internet_gateway.gw
}
