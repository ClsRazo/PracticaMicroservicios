#!/bin/bash

# Script para iniciar todos los microservicios
echo "Iniciando microservicios..."

# Crear directorio para logs si no existe
mkdir -p logs

# Verificar que RabbitMQ esté ejecutándose
echo "Verificando RabbitMQ..."
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server

# Esperar un poco para que RabbitMQ se inicie completamente
sleep 5

# Instalar dependencias de Python si no están instaladas
pip3 install -r requirements.txt

# Iniciar microservicio de usuarios
echo "Iniciando microservicio de usuarios..."
nohup python3 usuarios.py > logs/usuarios.log 2>&1 &
echo $! > logs/usuarios.pid

# Esperar un poco
sleep 2

# Iniciar microservicio de pagos
echo "Iniciando microservicio de pagos..."
nohup python3 pagos.py > logs/pagos.log 2>&1 &
echo $! > logs/pagos.pid

# Esperar un poco
sleep 2

# Iniciar API Gateway
echo "Iniciando API Gateway..."
nohup python3 apiGateway.py > logs/gateway.log 2>&1 &
echo $! > logs/gateway.pid

echo "Todos los microservicios han sido iniciados."
echo "Usuarios: http://18.224.56.4:5000"
echo "Pagos: http://18.224.56.4:5001"
echo "Gateway: http://18.224.56.4:5002"
echo ""
echo "Logs disponibles en el directorio 'logs/'"
echo "Para detener los servicios, ejecuta: ./stop_services.sh"
