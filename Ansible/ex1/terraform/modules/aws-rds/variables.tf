variable "app_name" {

}

variable "stage" {

}

variable "instance_type" {
  description = "Instance Type"
}

variable "subnet_id_a" {
  description = "Id of the subnet where the database will be available"
}

variable "subnet_id_b" {
  description = "Id of the subnet where the database will be available"
}

variable "security_group" {

}

variable "database_user" {

}

variable "database_password" {

}

variable "database_port" {
  type        = number
  description = "database port to use"
}
