resource "docker_network" "red_frontend" {
  name = "red-frontend-${terraform.workspace}"
}

resource "docker_network" "red_backend" {
  name = "red-backend-${terraform.workspace}"
}

output "red_frontend_name" {
  value       = docker_network.red_frontend.name
  description = "Nombre de la red frontend activa"
}

output "red_backend_name" {
  value       = docker_network.red_backend.name
  description = "Nombre de la red backend activa"
}
