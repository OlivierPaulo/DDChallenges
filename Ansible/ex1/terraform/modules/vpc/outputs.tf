output "vpc_arn" {
  value = aws_vpc.main.arn
}

output "vpc_security_group_ids" {
  value = [aws_security_group.tls_ssh.id]
}

output "database_security_group_id" {
  value = aws_security_group.database.id
}

output "subnet_server_id_a" {
  value = aws_subnet.main_a.id
}

output "subnet_server_id_b" {
  value = aws_subnet.main_b.id
}

output "gateway" {
  value = aws_internet_gateway.gw
}
