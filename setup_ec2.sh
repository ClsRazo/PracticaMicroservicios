#!/bin/bash

# Script de instalación para EC2
echo "Configurando entorno en EC2..."

# Actualizar sistema
sudo apt update

# Instalar Python y pip si no están instalados
sudo apt install -y python3 python3-pip

# Instalar RabbitMQ
echo "Instalando RabbitMQ..."
sudo apt install -y rabbitmq-server

# Iniciar y habilitar RabbitMQ
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server

# Instalar dependencias de Python
echo "Instalando dependencias de Python..."
pip3 install -r requirements.txt

# Hacer ejecutables los scripts
chmod +x start_services.sh
chmod +x stop_services.sh
chmod +x check_status.sh

# Configurar firewall (si ufw está habilitado)
echo "Configurando puertos en firewall..."
sudo ufw allow 5000
sudo ufw allow 5001
sudo ufw allow 5002

echo "Instalación completada."
echo "Para iniciar los servicios, ejecuta: ./start_services.sh"
