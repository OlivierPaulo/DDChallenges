variable "app_name" {
  description = "The name of the App that will be launch. MUST BE ONLY ALPHA NUMERIC CHARACTERS BECAUSE OF DB IDENTIFIER"
  sensitive   = true
}

variable "stage" {
  description = "Environment to launch"
  sensitive   = true
}

variable "instance_type" {
  description = "Instance type"
  sensitive   = true
}

variable "http_server_elastic_ip_allocation_id" {
  description = "Server elastic ip"
  sensitive   = true
}

variable "ssh_key_name" {
  description = "ssh key name"
  sensitive   = true
}

variable "rds_instance_type" {
  description = "rds instance type"
  sensitive   = true
}

variable "database_user" {
  description = "Database user"
  sensitive   = true
}

variable "database_password" {
  description = "Database password"
  sensitive   = true
}

variable "database_port" {
  type        = number
  description = "Port that the database uses"
  sensitive   = true
}
