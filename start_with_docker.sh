#!/bin/bash

# Script para iniciar servicios con RabbitMQ en Docker
echo "Iniciando servicios con Docker..."

# Crear directorio para logs si no existe
mkdir -p logs

# Iniciar RabbitMQ en Docker
echo "Iniciando RabbitMQ en Docker..."
docker run -d --name rabbitmq \
  -p 5672:5672 \
  -p 15672:15672 \
  rabbitmq:3-management

# Esperar a que RabbitMQ esté listo
echo "Esperando a que RabbitMQ esté listo..."
sleep 15

# Verificar que RabbitMQ esté funcionando
echo "Verificando RabbitMQ..."
docker ps | grep rabbitmq

# Configurar variables de entorno
export PATH=$PATH:/home/ec2-user/.local/bin
PYTHON_CMD="python3"

# Verificar dependencias
echo "Verificando dependencias de Python..."
$PYTHON_CMD -c "import flask, pika, requests" 2>/dev/null || {
    echo "Instalando dependencias..."
    pip3 install --user -r requirements.txt
}

# Iniciar microservicio de usuarios
echo "Iniciando microservicio de usuarios..."
nohup $PYTHON_CMD usuarios.py > logs/usuarios.log 2>&1 &
echo $! > logs/usuarios.pid

sleep 3

# Iniciar microservicio de pagos
echo "Iniciando microservicio de pagos..."
nohup $PYTHON_CMD pagos.py > logs/pagos.log 2>&1 &
echo $! > logs/pagos.pid

sleep 3

# Iniciar API Gateway
echo "Iniciando API Gateway..."
nohup $PYTHON_CMD apiGateway.py > logs/gateway.log 2>&1 &
echo $! > logs/gateway.pid

sleep 3

# Verificar servicios
echo ""
echo "Verificando servicios..."
echo "========================"

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
echo "Estado de RabbitMQ:"
docker ps | grep rabbitmq && echo "✓ RabbitMQ funcionando" || echo "✗ RabbitMQ no está funcionando"

echo ""
echo "URLs de acceso:"
echo "Gateway (Principal): http://18.224.56.4:5002"
echo "Usuarios: http://18.224.56.4:5004"
echo "Pagos: http://18.224.56.4:5001"
echo "RabbitMQ Management: http://18.224.56.4:15672 (guest/guest)"
echo ""
echo "Prueba rápida:"
echo "curl http://18.224.56.4:5002/usuarios/1"
