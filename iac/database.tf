resource "docker_image" "postgres" {
  name         = "postgres:16-alpine"
  keep_locally = true
}

resource "docker_container" "db" {
  name  = "bd-${terraform.workspace}"
  image = docker_image.postgres.image_id

  env = [
    "POSTGRES_USER=postgres",
    "POSTGRES_PASSWORD=${var.db_password[terraform.workspace]}",
    "POSTGRES_DB=app_db"
  ]

  ports {
    internal = 5432
    external = var.db_port[terraform.workspace]
  }

  networks_advanced {
    name = docker_network.red_backend.name
  }
}

output "db_container" {
  value       = docker_container.db.name
  description = "Nombre del contenedor de la base de datos activa"
}
