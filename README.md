# infra-docker-project

Automatiza infraestructura en AWS con Terraform y configura EC2 con Ansible para desplegar una aplicación dockerizada. Los workflows independientes (Terraform y Ansible) ejecutan el flujo con solo hacer push.

## Estructura

```
infra-docker-project/
├─ terraform/
│  ├─ modules/{vpc,security,ec2,keypair}
│  ├─ main.tf, variables.tf, outputs.tf, providers.tf, versions.tf
├─ ansible/
│  ├─ playbook.yml, ansible.cfg, app_repo_url.txt
│  └─ roles/common/tasks/main.yml
└─ .github/workflows/
   ├─ terraform.yml
   └─ ansible.yml
```

## Requisitos
- Cuenta AWS y credenciales con permisos para EC2, VPC, IAM KeyPairs y Secrets Manager.
- GitHub Secrets configurados en el repo:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `ALLOWED_SSH_CIDR` (tu IP pública en formato `/32`, ej: `1.2.3.4/32`)
- GitHub Repository Variable opcional: `AWS_REGION` (por defecto `us-east-1`).

## Uso

### 1) Desplegar infraestructura (Terraform)
1. Ajusta `terraform/variables.tf` si deseas cambiar `project_name` o región.
2. Asegúrate de tener `ALLOWED_SSH_CIDR` en GitHub Secrets.
3. Haz push de cambios bajo `terraform/`.
4. El workflow `Terraform` ejecutará: `terraform init`, `plan`, `apply`.
5. Se crearán: VPC, 2 subnets, IGW, route table, SG, par de EC2 t3.micro y un Secret en Secrets Manager con la clave privada.

### 2) Configurar instancias (Ansible)
1. Edita `ansible/app_repo_url.txt` con la URL del repo público dockerizado que quieras desplegar.
2. (Opcional pero recomendable) Si tu aplicación dockerizada requiere variables de entorno (.env), crea un archivo `.env` en la carpeta `ansible/` antes del despliegue. Ejemplo al final del README.
3. Haz push de cambios bajo `ansible/`.
4. El workflow `Ansible`:
   - Descarga la clave privada desde Secrets Manager (`<project>-ec2-ssh-private-key`).
   - Descubre las IPs públicas por Tag `Project=infra-docker-project`.
   - Genera `ansible/inventory/inventory.ini` dinámicamente.
   - Copia el archivo `.env` (si existe) al servidor antes de levantar los contenedores.
   - Ejecuta `ansible-playbook` vía SSH como `ec2-user`.

## Resultado esperado
- Las 2 instancias EC2 quedan accesibles por HTTP (puerto 80 abierto para todos, SSH limitado a tu IP).
- La app dockerizada queda corriendo en ambas instancias (`docker-compose up -d`), usando el `.env` proporcionado si aplica.

## Cambiar la URL del proyecto dockerizado
- Edita `ansible/app_repo_url.txt` y haz push a `ansible/`.

## Actualizar infraestructura
- Cambia archivos en `terraform/` y haz push; el workflow aplicará los cambios automáticamente.

## Notas
- Las instancias traen instalados al iniciar: Python3, Docker, docker-compose y git (user-data y playbook lo refuerzan).
- Los workflows son independientes: Ansible no depende del estado de Terraform; descubre instancias por Tag AWS y obtiene la clave de Secrets Manager.

---

## Ejemplo de archivo .env para aplicaciones dockerizadas
Si tu aplicación dockerizada (por ejemplo en docker-compose.yml) requiere variables de entorno, crea el archivo `ansible/.env` antes de hacer push. Ejemplo:

```
PORT=4000
DB_HOST=container_db_postgres
DB_USER=postgres
DB_PASSWORD=password
DB_NAME=bd_saludos
```

Este archivo será copiado automáticamente a las instancias, al directorio de la aplicación, para que docker-compose lo lea.
