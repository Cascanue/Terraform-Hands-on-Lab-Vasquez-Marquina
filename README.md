# Laboratorio de aprovisionamiento

Laboratorio enfocado en utilizar Terraform con buenas practicas para aprovisionar, con Docker, un frontend (nginx), un backend (node) y una base de datos (PostgreSQL) en los ambientes dev y qa. Todo gestionado mediante workspaces de Terraform.

---

## Arquitectura

### Contenedores y puertos por ambiente

| Contenedor      | Imagen           | dev (externo:interno) | qa (externo:interno)        |
|-----------------|------------------|-----------------------|-----------------------------|
| web-dev-1       | nginx:alpine     | 4001:80               | —                           |
| web-qa-1        | nginx:alpine     | —                     | 5001:80                     |
| web-qa-2        | nginx:alpine     | —                     | 5011:80                     |
| api-dev-1       | node:20-alpine   | 4002:3000             | —                           |
| api-qa-1        | node:20-alpine   | —                     | 5002:3000                   |
| api-qa-2        | node:20-alpine   | —                     | 5012:3000                   |
| bd-dev          | postgres:16-alpine | 4003:5432           | —                           |
| bd-qa           | postgres:16-alpine | —                   | 5003:5432                   |

### Redes y aislamiento

| Contenedor | red-frontend-<ws> | red-backend-<ws> |
|------------|:-----------------:|:----------------:|
| Frontend   | SI                | NO               |
| Backend    | SI                | SI               |
| BD         | NO                | SI               |

El frontend nunca se comunica de forma directa con la base de datos. El backend actua como unico intermediario entre ambos, conectado a las dos redes a la vez.

---

## Replicas por ambiente

| Componente       | dev | qa | Justificacion                                                                                                                                                        |
|------------------|-----|----|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Frontend (nginx) | 1   | 2  | dev: una instancia es suficiente para desarrollar y probar con bajo consumo de recursos. qa: dos replicas permiten validar balanceo y aproximarse a produccion.      |
| Backend (node)   | 1   | 2  | dev: una instancia basta. qa: dos replicas comprueban que la API es stateless y responde igual desde cualquier instancia antes de pasar a produccion.                 |
| BD (postgres)    | 1   | 1  | Componente con estado; replicar PostgreSQL requiere configuracion avanzada (master-slave) fuera del alcance de este laboratorio. Una instancia por ambiente basta.    |

---

## Estructura del proyecto

```
/
├── README.md
├── .gitignore
├── app/
│   ├── frontend/
│   │   └── index.html
│   └── backend/
│       └── index.js
└── iac/
    ├── providers.tf
    ├── variables.tf
    ├── terraform.tfvars
    ├── network.tf
    ├── database.tf
    ├── backend.tf
    └── frontend.tf
```

Buenas practicas aplicadas:
- Un archivo `.tf` por recurso logico para facilitar el mantenimiento.
- Variables tipo mapa por ambiente (`map(number)`, `map(string)`) en `variables.tf` con valores en `terraform.tfvars`.
- Ambientes gestionados exclusivamente con workspaces de Terraform (`dev` y `qa`).
- Patrones iterativos con `count` referenciando el diccionario del workspace activo.

---

## Instrucciones de despliegue

> IMPORTANTE: Todos los comandos de Terraform deben ejecutarse dentro de la carpeta `iac/`.

1. Clonar el repositorio y entrar a la carpeta de infraestructura:

```bash
git clone <url-del-repositorio>
cd "Terraform Hands-on Lab/iac"
```

2. Inicializar Terraform (descarga el provider de Docker):

```bash
terraform init
```

3. Crear y desplegar el ambiente DEV:

```bash
terraform workspace new dev
terraform apply
```
> Confirmar con `yes` cuando se solicite.

4. Crear y desplegar el ambiente QA:

```bash
terraform workspace new qa
terraform apply
```
> Confirmar con `yes` cuando se solicite.

---

## Como moverse entre entornos

Una vez creados los workspaces, puedes alternar entre ellos usando el comando `select`:

```bash
# Cambiar al entorno de desarrollo
terraform workspace select dev

# Cambiar al entorno de QA
terraform workspace select qa

# Ver en que entorno estas actualmente
terraform workspace show
```

---

## Comandos de verificacion para el Coordinador

Puedes validar que los contenedores y el aislamiento de redes funcionan con los siguientes comandos:

```bash
# 1. Ver los 8 contenedores corriendo y sus puertos mapeados
docker ps --format "table {{.Names}}\t{{.Ports}}"

# 2. Ver las 4 redes creadas
docker network ls --filter name=red-

# 3. Prueba de Frontend a Backend (misma red): debe responder JSON
docker exec web-dev-1 wget -qO- http://api-dev-1:3000/

# 4. Prueba de Backend a BD (misma red): debe decir "conectado"
docker exec api-dev-1 wget -qO- http://localhost:3000/db

# 5. Prueba de aislamiento de Frontend a BD (redes distintas): DEBE FALLAR ("bad address")
docker exec web-dev-1 wget -qO- -T 3 http://bd-dev:5432
```

Si pruebas desde tu navegador web:
- DEV: [http://localhost:4001](http://localhost:4001)
- QA 1: [http://localhost:5001](http://localhost:5001)
- QA 2: [http://localhost:5011](http://localhost:5011)

---

## Nota sobre tfvars

El archivo `terraform.tfvars` se incluye intencionalmente en este repositorio para fines estrictos del laboratorio, asegurando que el proyecto sea 100% reproducible al clonarlo. En un entorno productivo real, las variables sensibles (como `db_password`) se inyectarian desde el pipeline de CI/CD o desde un gestor de secretos, y `.tfvars` estaria ignorado en Git.

---

## Convencion de commits

Este proyecto se desarrollo utilizando Conventional Commits para mantener una cronologia limpia y descriptiva:

- `feat:` nueva funcionalidad (app o infraestructura)
- `docs:` cambios en documentacion
- `chore:` configuracion de herramientas (gitignore, etc.)
