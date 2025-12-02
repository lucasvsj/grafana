#!/bin/bash

# Script para iniciar Prometheus en modo desarrollo

echo "🚀 Iniciando Prometheus en modo DESARROLLO..."

# Iniciar contenedor
docker-compose up prometheus-dev -d

# Esperar a que esté listo
echo "⏳ Esperando que Prometheus inicie..."
sleep 5

# Verificar estado
if docker-compose ps prometheus-dev | grep -q "Up"; then
    echo "✅ Prometheus iniciado correctamente!"
    echo ""
    echo "📊 Accede a: http://localhost:9393"
    echo "🎯 Targets: http://localhost:9393/targets"
    echo "📈 Métricas: http://localhost:9393/graph"
    echo ""
    echo "📝 Ver logs: docker-compose logs -f prometheus-dev"
    echo ""
    echo "💡 Tip: Prometheus ya está configurado como datasource en Grafana"
else
    echo "❌ Error al iniciar Prometheus. Ver logs:"
    docker-compose logs prometheus-dev
    exit 1
fi
