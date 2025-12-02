#!/bin/bash

# Script para iniciar Grafana en modo producción

echo "🚀 Iniciando Grafana en modo PRODUCCIÓN..."

# Verificar que existe .env
if [ ! -f .env ]; then
    echo "❌ Archivo .env no encontrado."
    echo "   Debes crear el archivo .env desde .env.example"
    exit 1
fi

# Verificar que Traefik está corriendo
if ! docker ps | grep -q traefik; then
    echo "⚠️  Traefik no está corriendo. Grafana necesita Traefik para funcionar en producción."
    echo "   ¿Continuar de todas formas? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Verificar que existe la network traefik-public
if ! docker network ls | grep -q traefik-public; then
    echo "❌ La network 'traefik-public' no existe."
    echo "   Crear network: docker network create traefik-public"
    exit 1
fi

# Iniciar contenedor
docker-compose up grafana-prod -d

# Esperar a que esté listo
echo "⏳ Esperando que Grafana inicie..."
sleep 5

# Verificar estado
if docker-compose ps grafana-prod | grep -q "Up"; then
    echo "✅ Grafana iniciado correctamente en PRODUCCIÓN!"
    echo ""
    echo "📊 Accede a: https://grafana.lucasvsj.com"
    echo "👤 Usuario: admin"
    echo "🔑 Contraseña: (la que configuraste en .env)"
    echo ""
    echo "📝 Ver logs: docker-compose logs -f grafana-prod"
    echo "🔒 Verificar SSL: curl -I https://grafana.lucasvsj.com"
else
    echo "❌ Error al iniciar Grafana. Ver logs:"
    docker-compose logs grafana-prod
    exit 1
fi
