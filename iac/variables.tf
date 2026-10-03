variable "db_port" {
  type        = map(number)
  description = "Puerto externo de la base de datos PostgreSQL por ambiente"
}

variable "db_password" {
  type        = map(string)
  sensitive   = true
  description = "Contrasena del usuario postgres por ambiente"
}

variable "backend_port" {
  type        = map(number)
  description = "Puerto externo de la API Node por ambiente"
}

variable "backend_replicas" {
  type        = map(number)
  description = "Numero de replicas del backend por ambiente"
}

variable "frontend_port" {
  type        = map(number)
  description = "Puerto externo del frontend Nginx por ambiente"
}

variable "frontend_replicas" {
  type        = map(number)
  description = "Numero de replicas del frontend por ambiente"
}
