# Grafana Dockerizado con Traefik

Proyecto de Grafana completamente dockerizado con integración Traefik para producción, preparado para futura autenticación mediante API Django.

## 🚀 Características

- ✅ **Dos entornos**: Desarrollo y Producción
- ✅ **Traefik integrado**: Reverse proxy con SSL/TLS automático (Let's Encrypt)
- ✅ **Seguridad**: Headers de seguridad, rate limiting, cookies seguras
- ✅ **Persistencia**: Volúmenes Docker para datos permanentes
- ✅ **Provisionamiento**: Datasources y dashboards automáticos
- ✅ **Preparado para API Django**: Arquitectura lista para integración futura

## 📋 Requisitos Previos

- Docker y Docker Compose instalados
- Traefik configurado con:
  - Network externa `traefik-public`
  - Let's Encrypt configurado
  - Entrypoints `web` (HTTP) y `websecure` (HTTPS)

## 🛠️ Instalación

### 1. Configurar Variables de Entorno

```bash
# Copiar el template de variables de entorno
cp .env.example .env

# Editar .env con tus credenciales
nano .env
```

**Variables importantes a configurar:**
- `GRAFANA_ADMIN_PASSWORD`: Contraseña del administrador (mínimo 12 caracteres)
- `GRAFANA_SECRET_KEY`: Generar con `openssl rand -base64 32`
- Configuración SMTP (opcional, para notificaciones)

### 2. Generar Secret Key

```bash
# Generar una secret key segura
openssl rand -base64 32
```

Copiar el resultado en `.env` como valor de `GRAFANA_SECRET_KEY`.

## 🎯 Uso

### Modo Desarrollo

```bash
# Iniciar Grafana en modo desarrollo
docker-compose up grafana-dev -d

# Ver logs
docker-compose logs -f grafana-dev

# Detener
docker-compose down grafana-dev
```

**Acceder a:** `http://localhost:3948`

### Modo Producción

```bash
# Iniciar Grafana en modo producción
docker-compose up grafana-prod -d

# Ver logs
docker-compose logs -f grafana-prod

# Detener
docker-compose down grafana-prod
```

**Acceder a:** `https://grafana.lucasvsj.com`

## 🔐 Autenticación

### Configuración Actual

- **Autenticación básica** de Grafana habilitada
- **Registro de usuarios deshabilitado** (solo admin puede crear usuarios)
- Usuario admin inicial configurado via variables de entorno

### Integración Futura con API Django

La arquitectura está preparada para integración con una API Django de administración:

**Flujo planificado:**
1. Usuario solicita acceso mediante API Django
2. Administrador aprueba/rechaza desde panel de admin Django
3. Si se aprueba, se crea usuario en Grafana mediante [Grafana HTTP API](https://grafana.com/docs/grafana/latest/developers/http_api/user/)

**Configuración necesaria:**
- Grafana API está habilitada
- Variables de entorno preparadas para API keys
- Autenticación básica activa para integración programática

## 📊 Datasources y Dashboards

### Añadir Datasources

Edita `grafana/provisioning/datasources/datasources.yml`:

```yaml
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
```

### Añadir Dashboards

**Opción 1: Manualmente**
1. Crear dashboard en interfaz de Grafana
2. Exportar como JSON (Share > Export > Save to file)
3. Copiar JSON a `grafana/dashboards/`
4. Reiniciar contenedor o esperar recarga automática

**Opción 2: Importar desde Grafana.com**
1. Buscar dashboard en [grafana.com/grafana/dashboards](https://grafana.com/grafana/dashboards/)
2. Importar via UI usando el Dashboard ID
3. Exportar y guardar en `grafana/dashboards/` para persistencia

## 🔧 Comandos Útiles

```bash
# Ver estado de servicios
docker-compose ps

# Ejecutar comando dentro del contenedor
docker-compose exec grafana-dev sh

# Ver logs en tiempo real
docker-compose logs -f grafana-prod

# Reiniciar servicio
docker-compose restart grafana-prod

# Backup de datos (producción)
docker-compose exec grafana-prod tar -czf /tmp/grafana-backup.tar.gz /var/lib/grafana
docker cp $(docker-compose ps -q grafana-prod):/tmp/grafana-backup.tar.gz ./backup-$(date +%Y%m%d).tar.gz

# Restaurar backup
docker cp ./backup-20231202.tar.gz $(docker-compose ps -q grafana-prod):/tmp/
docker-compose exec grafana-prod tar -xzf /tmp/backup-20231202.tar.gz -C /

# Validar configuración docker-compose
docker-compose config

# Ver uso de recursos
docker stats grafana-prod
```

## 🏗️ Estructura del Proyecto

```
grafana/
├── docker-compose.yml              # Orquestación de servicios
├── .env                           # Variables de entorno (no commitear)
├── .env.example                   # Template de variables
├── .gitignore                     # Archivos ignorados por git
├── README.md                      # Esta documentación
└── grafana/
    ├── provisioning/
    │   ├── datasources/
    │   │   └── datasources.yml    # Configuración de datasources
    │   └── dashboards/
    │       └── dashboards.yml     # Configuración de dashboards
    └── dashboards/                # Dashboards personalizados (JSON)
        └── .gitkeep
```

## 🔒 Seguridad

### Headers de Seguridad Implementados

- **HSTS**: Strict-Transport-Security con 2 años de duración
- **CSP**: Content-Security-Policy para prevenir XSS
- **X-Frame-Options**: SAMEORIGIN para prevenir clickjacking
- **X-Content-Type-Options**: nosniff
- **X-XSS-Protection**: Activado

### Rate Limiting

- **Average**: 100 requests/segundo
- **Burst**: 50 requests adicionales
- Protección contra ataques de fuerza bruta

### Cookies Seguras (Producción)

- `Secure`: Solo HTTPS
- `SameSite`: Lax (protección CSRF)
- `HttpOnly`: No accesibles via JavaScript

## 🌐 Configuración de Traefik

El servicio de producción usa las siguientes labels de Traefik:

- **Dominio**: `grafana.lucasvsj.com`
- **Certificado SSL**: Let's Encrypt (automático)
- **Redirects**: HTTP → HTTPS automático
- **Middlewares**: Security headers, rate limiting, compression

## 📝 Notas Importantes

> [!WARNING]
> - El archivo `.env` contiene credenciales sensibles y NO debe commitearse
> - Cambiar las contraseñas por defecto antes de usar en producción
> - El `GRAFANA_SECRET_KEY` debe ser único y aleatorio
> - Mantener Docker y Grafana actualizados para parches de seguridad

> [!NOTE]
> **Diferencias Dev vs Prod:**
> - **Dev**: Puerto expuesto (3948), cookies no seguras, logs debug
> - **Prod**: Solo Traefik, cookies seguras, HSTS activado, logs info

## 🔗 Enlaces Útiles

- [Documentación oficial de Grafana](https://grafana.com/docs/grafana/latest/)
- [Grafana HTTP API](https://grafana.com/docs/grafana/latest/developers/http_api/)
- [Provisionamiento](https://grafana.com/docs/grafana/latest/administration/provisioning/)
- [Grafana Dashboards](https://grafana.com/grafana/dashboards/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)

## 🐛 Troubleshooting

### No puedo acceder a Grafana en producción

1. Verificar que Traefik está corriendo: `docker ps | grep traefik`
2. Verificar network existe: `docker network ls | grep traefik-public`
3. Verificar logs de Traefik: `docker logs traefik`
4. Verificar DNS apunta a servidor: `nslookup grafana.lucasvsj.com`

### Olvidé la contraseña de admin

```bash
# Resetear password usando CLI
docker-compose exec grafana-prod grafana-cli admin reset-admin-password newpassword
```

### Los dashboards no se cargan

1. Verificar que los archivos JSON están en `grafana/dashboards/`
2. Verificar permisos de archivos
3. Ver logs para errores: `docker-compose logs grafana-prod`
4. Reiniciar contenedor: `docker-compose restart grafana-prod`

### Error de certificado SSL

1. Verificar que Let's Encrypt está configurado en Traefik
2. Verificar logs de Traefik para errores de certificados
3. Verificar que el dominio apunta correctamente al servidor

## 📄 Licencia

Este proyecto es de código abierto. Grafana está licenciado bajo AGPL v3.

## 👤 Autor

Lucas VSJ - [lucasvsj.com](https://lucasvsj.com)
