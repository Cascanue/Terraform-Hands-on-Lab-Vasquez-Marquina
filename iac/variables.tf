variable "db_port" {
  type        = map(number)
  description = "Puerto externo de la base de datos PostgreSQL por ambiente"
}

variable "db_password" {
  type        = map(string)
  sensitive   = true
  description = "Contrasena del usuario postgres por ambiente"
}
