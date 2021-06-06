variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}

variable "instance_type" {
  description = "Value of the type of instance"
  type        = string
  default     = "t2.nano"
}

variable "region_name" {
  description = "Value of the region where resources will be installed"
  type        = string
  default     = "us-west-2"
}

variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
}