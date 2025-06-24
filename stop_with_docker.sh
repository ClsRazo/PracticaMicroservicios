#!/bin/bash

# Script para detener servicios y Docker
echo "Deteniendo todos los servicios..."

# Detener microservicios
for service in usuarios pagos gateway; do
    if [ -f "logs/${service}.pid" ]; then
        pid=$(cat "logs/${service}.pid")
        if ps -p $pid > /dev/null 2>&1; then
            echo "Deteniendo $service (PID: $pid)..."
            kill $pid
            rm "logs/${service}.pid"
        else
            echo "$service no está ejecutándose"
            rm "logs/${service}.pid" 2>/dev/null
        fi
    fi
done

# Detener procesos residuales
pkill -f "usuarios.py"
pkill -f "pagos.py"  
pkill -f "apiGateway.py"

# Detener RabbitMQ Docker
echo "Deteniendo RabbitMQ..."
docker stop rabbitmq 2>/dev/null
docker rm rabbitmq 2>/dev/null

echo "Todos los servicios han sido detenidos."
