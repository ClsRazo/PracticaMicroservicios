#!/bin/bash

# Script de instalación para Amazon Linux EC2
echo "Configurando entorno en Amazon Linux EC2..."

# Actualizar sistema
sudo yum update -y

# Instalar Python y pip si no están instalados (ya están en Amazon Linux)
sudo yum install -y python3 python3-pip

# Instalar Erlang (requerido para RabbitMQ)
echo "Instalando Erlang..."
sudo yum install -y erlang

# Instalar RabbitMQ
echo "Instalando RabbitMQ..."
# Descargar e instalar RabbitMQ para Amazon Linux
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.12.0/rabbitmq-server-3.12.0-1.el8.noarch.rpm
sudo rpm -Uvh rabbitmq-server-3.12.0-1.el8.noarch.rpm

# Iniciar y habilitar RabbitMQ
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server

# Verificar que RabbitMQ esté funcionando
sleep 5
sudo systemctl status rabbitmq-server

# Instalar dependencias de Python
echo "Instalando dependencias de Python..."
pip3 install --user -r requirements.txt

# Hacer ejecutables los scripts
chmod +x start_services.sh
chmod +x stop_services.sh
chmod +x check_status.sh

# Configurar Security Groups en lugar de firewall local
echo "IMPORTANTE: Asegúrate de que los siguientes puertos estén abiertos en el Security Group de tu EC2:"
echo "- Puerto 5000 (Microservicio Usuarios)"
echo "- Puerto 5001 (Microservicio Pagos)"
echo "- Puerto 5002 (API Gateway)"
echo "- Puerto 22 (SSH)"

echo "Instalación completada."
echo "Para iniciar los servicios, ejecuta: ./start_services.sh"
