#!/bin/bash

# Script simplificado para Amazon Linux EC2
echo "Configuración simplificada para Amazon Linux..."

# Actualizar sistema
sudo yum update -y

# Instalar Docker (alternativa más fácil para RabbitMQ)
echo "Instalando Docker..."
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Nota: Necesitarás cerrar sesión y volver a conectarte para que los permisos de Docker funcionen
echo "IMPORTANTE: Después de ejecutar este script, cierra sesión y vuelve a conectarte:"
echo "exit"
echo "ssh -i tu-llave.pem ec2-user@18.224.56.4"

# Instalar dependencias de Python
echo "Instalando dependencias de Python..."
pip3 install --user -r requirements.txt

# Hacer ejecutables los scripts
chmod +x *.sh

echo "Configuración básica completada."
echo ""
echo "PASOS SIGUIENTES:"
echo "1. Cierra esta sesión SSH: exit"
echo "2. Vuelve a conectarte: ssh -i tu-llave.pem ec2-user@18.224.56.4" 
echo "3. Ejecuta: ./start_with_docker.sh"
