#!/bin/bash

# Script para iniciar todos los microservicios en Amazon Linux
echo "Iniciando microservicios..."

# Crear directorio para logs si no existe
mkdir -p logs

# Verificar que RabbitMQ esté ejecutándose
echo "Verificando RabbitMQ..."
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server

# Esperar un poco para que RabbitMQ se inicie completamente
sleep 5

# Usar la ruta completa de Python y añadir el PATH local del usuario
export PATH=$PATH:/home/ec2-user/.local/bin
PYTHON_CMD="python3"

# Verificar que las dependencias estén instaladas
echo "Verificando dependencias..."
$PYTHON_CMD -c "import flask, pika, requests" 2>/dev/null || {
    echo "Instalando dependencias faltantes..."
    pip3 install --user -r requirements.txt
}

# Iniciar microservicio de usuarios
echo "Iniciando microservicio de usuarios..."
nohup $PYTHON_CMD usuarios.py > logs/usuarios.log 2>&1 &
echo $! > logs/usuarios.pid

# Esperar un poco
sleep 3

# Iniciar microservicio de pagos
echo "Iniciando microservicio de pagos..."
nohup $PYTHON_CMD pagos.py > logs/pagos.log 2>&1 &
echo $! > logs/pagos.pid

# Esperar un poco
sleep 3

# Iniciar API Gateway
echo "Iniciando API Gateway..."
nohup $PYTHON_CMD apiGateway.py > logs/gateway.log 2>&1 &
echo $! > logs/gateway.pid

# Esperar un poco y verificar que los procesos estén ejecutándose
sleep 3

echo "Verificando servicios..."
echo "=================================="

for service in usuarios pagos gateway; do
    if [ -f "logs/${service}.pid" ]; then
        pid=$(cat "logs/${service}.pid")
        if ps -p $pid > /dev/null 2>&1; then
            echo "✓ $service está ejecutándose (PID: $pid)"
        else
            echo "✗ $service falló al iniciar. Verifica logs/${service}.log"
        fi
    fi
done

echo ""
echo "URLs de acceso:"
echo "Usuarios: http://18.224.56.4:5000"
echo "Pagos: http://18.224.56.4:5001"
echo "Gateway: http://18.224.56.4:5002"
echo ""
echo "Logs disponibles en el directorio 'logs/'"
echo "Para detener los servicios, ejecuta: ./stop_services.sh"
echo "Para verificar estado, ejecuta: ./check_status.sh"
