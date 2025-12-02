#!/bin/bash

# Script para iniciar Grafana en modo desarrollo

echo "🚀 Iniciando Grafana en modo DESARROLLO..."

# Verificar que existe .env
if [ ! -f .env ]; then
    echo "⚠️  Archivo .env no encontrado. Copiando desde .env.example..."
    cp .env.example .env
    echo "✏️  Por favor edita el archivo .env con tus credenciales antes de continuar."
    echo "   Específicamente:"
    echo "   - GRAFANA_ADMIN_PASSWORD"
    echo "   - GRAFANA_SECRET_KEY (genera con: openssl rand -base64 32)"
    exit 1
fi

# Iniciar contenedor
docker-compose up grafana-dev -d

# Esperar a que esté listo
echo "⏳ Esperando que Grafana inicie..."
sleep 5

# Verificar estado
if docker-compose ps grafana-dev | grep -q "Up"; then
    echo "✅ Grafana iniciado correctamente!"
    echo ""
    echo "📊 Accede a: http://localhost:3948"
    echo "👤 Usuario: admin"
    echo "🔑 Contraseña: (la que configuraste en .env)"
    echo ""
    echo "📝 Ver logs: docker-compose logs -f grafana-dev"
else
    echo "❌ Error al iniciar Grafana. Ver logs:"
    docker-compose logs grafana-dev
    exit 1
fi
