# Integración Traefik → Prometheus → Grafana

## ✅ Configuración Completada

Se ha integrado exitosamente Traefik con Prometheus y Grafana.

## 📊 Lo que se configuró:

### 1. **Conexión de redes Docker**
- Traefik ahora está en la red `grafana_grafana-dev-network`
- Permite que Prometheus acceda a las métricas de Traefik

### 2. **Scraping de Prometheus**
Se añadió un nuevo job en `prometheus/prometheus.yml`:
```yaml
- job_name: 'traefik'
  static_configs:
    - targets: ['traefik:8080']
```

**Nota:** Las métricas de Traefik están expuestas en el puerto 8080 (mismo del dashboard).

### 3. **Métricas disponibles de Traefik**
Traefik expone automáticamente métricas como:
- `traefik_entrypoint_requests_total` - Total de requests por entrypoint
- `traefik_entrypoint_request_duration_seconds` - Duración de requests
- `traefik_router_requests_total` - Requests por router
- `traefik_service_requests_total` - Requests por servicio
- `traefik_tls_certs_not_after` - Expiración de certificados SSL

## 🎯 Verificar integración:

### 1. **Prometheus Targets**
Accede a: `http://localhost:9393/targets`

Deberías ver tres jobs activos:
- ✅ `prometheus` (localhost:9090)
- ✅ `grafana` (grafana-dev:3000)
- ✅ `traefik` (traefik:8080)

### 2. **Explorar métricas en Prometheus**
URL: `http://localhost:9393/graph`

Prueba estas queries:
```promql
# Requests totales en Traefik
rate(traefik_entrypoint_requests_total[5m])

# Latencia P95
histogram_quantile(0.95, traefik_entrypoint_request_duration_seconds_bucket)

# Certificados SSL (días para expirar)
(traefik_tls_certs_not_after - time()) / 86400
```

## 📈 Crear Dashboard en Grafana:

### Opción 1: Dashboard oficial de Traefik

**Importar dashboard pre-construido:**

1. Accede a Grafana: `http://localhost:3948`
2. Click en **+** → **Import Dashboard**
3. Ingresa el ID del dashboard: **17346** (Traefik Official Dashboard)
4. Click **Load**
5. Selecciona **Prometheus** como datasource
6. Click **Import**

### Opción 2: Dashboards de la comunidad

Aquí tienes algunos dashboards populares de Traefik:

| Dashboard ID | Nombre | Descripción |
|--------------|--------|-------------|
| 17346 | Traefik Official | Dashboard oficial con métricas principales |
| 11462 | Traefik v2 | Detallado, bueno para troubleshooting |
| 12250 | Traefik Dashboard | Simple y limpio |

### Opción 3: Crear tu propio dashboard

**Métricas útiles para paneles:**

```promql
# Requests por segundo
sum(rate(traefik_entrypoint_requests_total[5m])) by (entrypoint)

# Requests por servicio
sum(rate(traefik_service_requests_total[5m])) by (service)

# Errores 4xx
sum(rate(traefik_entrypoint_requests_total{code=~"4.."}[5m]))

# Errores 5xx  
sum(rate(traefik_entrypoint_requests_total{code=~"5.."}[5m]))

# Backend activos
count(traefik_service_server_up) by (service)
```

## 🚀 Siguiente paso:

**Reiniciar Traefik para aplicar cambios de red:**

```bash
cd /Users/lucasvsj/PersonalPlayground/Traefik
docker-compose down
docker-compose up -d
```

Luego verifica que Prometheus detecte el target:
```bash
curl http://localhost:9393/api/v1/targets | grep traefik
```

## 🔧 Troubleshooting:

### Si Prometheus no detecta Traefik:

1. **Verificar que Traefik esté en la red correcta:**
   ```bash
   docker inspect traefik | grep -A 10 Networks
   ```

2. **Verificar que el endpoint /metrics responda:**
   ```bash
   docker exec prometheus-dev wget -qO- http://traefik:8080/metrics
   ```

3. **Ver logs de Prometheus:**
   ```bash
   docker-compose logs prometheus-dev | grep traefik
   ```

### Si las métricas no aparecen en Grafana:

1. Verificar que Prometheus esté configurado como datasource
2. Test connection en Grafana → Configuration → Data Sources → Prometheus
3. Refrescar el dashboard

## 📝 Archivos modificados:

- ✅ `/Users/lucasvsj/PersonalPlayground/Traefik/docker-compose.yml`
  - Añadida red `grafana_grafana-dev-network`
  
- ✅ `/Users/lucasvsj/PersonalPlayground/grafana/prometheus/prometheus.yml`
  - Añadido job `traefik` para scraping

¡Listo! Ahora tienes un stack completo de observabilidad: Traefik → Prometheus → Grafana 🎉
