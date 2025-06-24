# Guía de Despliegue - Amazon Linux EC2

## 🚀 Opción Recomendada: Docker (Más Fácil)

### 1. Configuración inicial
```bash
# En tu EC2
cd PracticaMicroservicios
chmod +x *.sh
./setup_simple.sh
```

### 2. Cerrar sesión y reconectar
```bash
exit
# Desde tu máquina local:
ssh -i tu-llave.pem ec2-user@18.224.56.4
cd PracticaMicroservicios
```

### 3. Iniciar servicios con Docker
```bash
./start_with_docker.sh
```

### 4. Verificar que funcione
```bash
curl http://18.224.56.4:5002/usuarios/1
curl -X POST http://18.224.56.4:5002/usuarios/1/pagar
```

### 5. Detener servicios
```bash
./stop_with_docker.sh
```

---

## 📋 Configuración del Security Group

**IMPORTANTE**: Asegúrate de que tu Security Group de EC2 tenga estos puertos abiertos:

1. Ve a la consola de AWS EC2
2. Selecciona tu instancia
3. Ve a la pestaña "Security"
4. Haz clic en el Security Group
5. Añade estas reglas de "Inbound Rules":

```
Tipo: Custom TCP
Puerto: 5000
Origen: 0.0.0.0/0
Descripción: Microservicio Usuarios

Tipo: Custom TCP  
Puerto: 5001
Origen: 0.0.0.0/0
Descripción: Microservicio Pagos

Tipo: Custom TCP
Puerto: 5002  
Origen: 0.0.0.0/0
Descripción: API Gateway

Tipo: Custom TCP
Puerto: 15672
Origen: 0.0.0.0/0  
Descripción: RabbitMQ Management (opcional)
```

---

## 🌐 URLs Finales para el Profesor

### Principal (API Gateway):
- **Obtener usuario Willis**: http://18.224.56.4:5002/usuarios/1
- **Obtener usuario Ana**: http://18.224.56.4:5002/usuarios/2
- **Procesar pago Willis**: `curl -X POST http://18.224.56.4:5002/usuarios/1/pagar`
- **Procesar pago Ana**: `curl -X POST http://18.224.56.4:5002/usuarios/2/pagar`

### Microservicios individuales:
- **Estado usuarios**: http://18.224.56.4:5000/usuarios/1
- **Estado pagos**: http://18.224.56.4:5001/pagos/status

### Panel de RabbitMQ (opcional):
- **Management UI**: http://18.224.56.4:15672 (usuario: guest, password: guest)

---

## 🔧 Comandos de Administración

```bash
# Ver estado de servicios
./check_status.sh

# Ver logs
tail -f logs/usuarios.log
tail -f logs/pagos.log  
tail -f logs/gateway.log

# Reiniciar servicios
./stop_with_docker.sh
./start_with_docker.sh

# Ver contenedores Docker
docker ps
```

---

## 🧪 Pruebas de Funcionamiento

### Desde tu EC2:
```bash
# Obtener usuario
curl http://localhost:5002/usuarios/1

# Enviar pago  
curl -X POST http://localhost:5002/usuarios/1/pagar

# Verificar estado de pagos
curl http://localhost:5001/pagos/status
```

### Desde cualquier lugar:
```bash
# Obtener usuario
curl http://18.224.56.4:5002/usuarios/1

# Enviar pago
curl -X POST http://18.224.56.4:5002/usuarios/1/pagar
```

### Desde navegador web:
- http://18.224.56.4:5002/usuarios/1
- http://18.224.56.4:5002/usuarios/2
- http://18.224.56.4:5001/pagos/status

---

## ❗ Solución de Problemas

### Si RabbitMQ no inicia:
```bash
docker logs rabbitmq
docker restart rabbitmq
```

### Si un microservicio no responde:
```bash
# Ver logs específicos
tail -f logs/usuarios.log
tail -f logs/pagos.log
tail -f logs/gateway.log

# Reiniciar servicio específico
kill $(cat logs/usuarios.pid)
nohup python3 usuarios.py > logs/usuarios.log 2>&1 &
echo $! > logs/usuarios.pid
```

### Verificar puertos en uso:
```bash
netstat -tlnp | grep -E ':(5000|5001|5002)'
```

---

## 📝 Respuestas Esperadas

### GET /usuarios/1:
```json
{
  "nombre": "Willis",
  "saldo": 500
}
```

### POST /usuarios/1/pagar:
```json
{
  "mensaje": "Solicitud de pago enviada",
  "usuario": {
    "nombre": "Willis", 
    "saldo": 500
  }
}
```
