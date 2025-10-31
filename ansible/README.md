# Uso del archivo .env
version 1

Si tu aplicación dockerizada necesita variables de entorno desde un archivo `.env` (por ejemplo para `docker-compose.yml`), crea este archivo dentro de la carpeta `ansible/` antes de ejecutar el playbook o push al workflow de Ansible.

Ejemplo de `.env` compatible:

```
PORT=4000
DB_HOST=container_db_postgres
DB_USER=postgres
DB_PASSWORD=password
DB_NAME=bd_saludos
```

Este archivo será copiado a la instancia remota al mismo directorio que el de la aplicación antes de hacer `docker-compose up -d`. Así puedes personalizar la configuración de entorno de tu aplicación dockerizada sin modificar el código.
