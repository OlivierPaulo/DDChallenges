resource "aws_db_subnet_group" "default" {
  name       = "${var.app_name}-${var.stage}-db-group"
  subnet_ids = [var.subnet_id_a, var.subnet_id_b] # at least 2 are required

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = var.instance_type
  name                    = "${var.app_name}${var.stage}appdb"
  identifier              = "${var.app_name}${var.stage}appdb"
  username                = var.database_user
  password                = var.database_password
  port                    = var.database_port
  backup_retention_period = 7
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [var.security_group]
  tags = {
    Service     = var.app_name
    Environment = var.stage
  }
  skip_final_snapshot = true
}

