#!/bin/bash

# Script para detener todos los microservicios
echo "Deteniendo microservicios..."

# Función para detener un servicio por PID
stop_service() {
    local service_name=$1
    local pid_file="logs/${service_name}.pid"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if ps -p $pid > /dev/null 2>&1; then
            echo "Deteniendo $service_name (PID: $pid)..."
            kill $pid
            rm "$pid_file"
        else
            echo "$service_name no está ejecutándose"
            rm "$pid_file" 2>/dev/null
        fi
    else
        echo "No se encontró archivo PID para $service_name"
    fi
}

# Detener servicios
stop_service "usuarios"
stop_service "pagos"
stop_service "gateway"

# También buscar y detener cualquier proceso Python que pueda estar ejecutando nuestros servicios
echo "Buscando procesos residuales..."
pkill -f "usuarios.py"
pkill -f "pagos.py"
pkill -f "apiGateway.py"

echo "Todos los microservicios han sido detenidos."
