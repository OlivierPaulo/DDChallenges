output "host" {
  value = aws_db_instance.default.address
}

output "db_name" {
  value = aws_db_instance.default.name
}

output "database_user" {
  value = aws_db_instance.default.username
}

output "database_password" {
  value = aws_db_instance.default.password
}

