output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.public-ec2.id
}

output "instance_private_ip" {
  description = "ID of the EC2 instance"
  value       = aws_instance.public-ec2.private_ip
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.public-ec2.public_ip
}


output "bucket_name" {
  description = "Check bucket name after creation"
  value       = aws_s3_bucket.terraform_state_s3.bucket
}

output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.rds_postgre_db.address
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.rds_postgre_db.port
  sensitive   = true
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.rds_postgre_db.username
  sensitive   = true
}