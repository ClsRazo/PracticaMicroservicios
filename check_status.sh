#!/bin/bash

# Script para verificar el estado de los microservicios
echo "Verificando estado de los microservicios..."
echo "=========================================="

# Función para verificar un servicio
check_service() {
    local service_name=$1
    local port=$2
    local pid_file="logs/${service_name}.pid"
    
    echo "Servicio: $service_name"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if ps -p $pid > /dev/null 2>&1; then
            echo "  Estado: EJECUTÁNDOSE (PID: $pid)"
            echo "  Puerto: $port"
            echo "  URL: http://18.224.56.4:$port"
        else
            echo "  Estado: DETENIDO (PID en archivo no válido)"
        fi
    else
        echo "  Estado: DETENIDO (sin archivo PID)"
    fi
    echo ""
}

# Verificar cada servicio
check_service "usuarios" "5000"
check_service "pagos" "5001"
check_service "gateway" "5002"

# Verificar RabbitMQ
echo "RabbitMQ:"
if systemctl is-active --quiet rabbitmq-server; then
    echo "  Estado: EJECUTÁNDOSE"
else
    echo "  Estado: DETENIDO"
fi
echo ""

# Mostrar puertos en uso
echo "Puertos en uso:"
netstat -tlnp 2>/dev/null | grep -E ':(5000|5001|5002|5672)' | while read line; do
    echo "  $line"
done
