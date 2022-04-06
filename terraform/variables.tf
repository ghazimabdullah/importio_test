variable "region" {
  default     = "eu-west-2"
  description = "AWS region"
}

variable "db_password" {
  description = "RDS root user password"
  default     = "12E456789!"
  sensitive   = true
}

variable "db_user" {
  description = "RDS root user"
  default     = "admin"
  sensitive   = true
}
