# Microservicios - Sistema Distribuido

Este proyecto implementa una arquitectura de microservicios con Flask y RabbitMQ desplegada en AWS EC2.

## Arquitectura

- **Microservicio de Usuarios** (Puerto 5004): Gestiona usuarios y sus saldos
- **Microservicio de Pagos** (Puerto 5001): Procesa pagos mediante colas de mensajes
- **API Gateway** (Puerto 5002): Punto de entrada único para todos los servicios
- **RabbitMQ**: Sistema de mensajería para comunicación asíncrona

## URLs de Acceso

**IP Pública EC2**: 18.224.56.4

### API Gateway (Recomendado - Puerto 5002)
- Base URL: `http://18.224.56.4:5002`

### Endpoints Disponibles

#### 1. Obtener información de usuario
```
GET http://18.224.56.4:5002/usuarios/1
GET http://18.224.56.4:5002/usuarios/2
```
**Respuesta ejemplo:**
```json
{
  "nombre": "Willis",
  "saldo": 500
}
```

#### 2. Solicitar pago de usuario
```
POST http://18.224.56.4:5002/usuarios/1/pagar
POST http://18.224.56.4:5002/usuarios/2/pagar
```
**Respuesta ejemplo:**
```json
{
  "mensaje": "Solicitud de pago enviada",
  "usuario": {
    "nombre": "Willis",
    "saldo": 500
  }
}
```

#### 3. Verificar estado del servicio de pagos
```
GET http://18.224.56.4:5001/pagos/status
```

### Acceso Directo a Microservicios

#### Microservicio de Usuarios (Puerto 5004)
```
GET http://18.224.56.4:5004/usuarios/1
POST http://18.224.56.4:5004/usuarios/1/pagar
```

#### Microservicio de Pagos (Puerto 5001)
```
GET http://18.224.56.4:5001/pagos/status
```

## Cómo Funciona

1. **Consulta de Usuario**: El API Gateway redirige la petición al microservicio de usuarios
2. **Solicitud de Pago**: 
   - El usuario solicita un pago a través del API Gateway
   - El microservicio de usuarios envía un mensaje a la cola RabbitMQ
   - El microservicio de pagos consume automáticamente el mensaje y procesa el pago
3. **Procesamiento Asíncrono**: Los pagos se procesan en background sin bloquear las peticiones

## Comandos de Administración

### En la instancia EC2:

```bash
# Iniciar todos los servicios
./start_services.sh

# Verificar estado
./check_status.sh

# Detener todos los servicios
./stop_services.sh
```

## Logs

Los logs de cada servicio se almacenan en:
- `logs/usuarios.log`
- `logs/pagos.log`
- `logs/gateway.log`

## Pruebas Rápidas

### Con curl:
```bash
# Obtener usuario
curl http://18.224.56.4:5002/usuarios/1

# Solicitar pago
curl -X POST http://18.224.56.4:5002/usuarios/1/pagar

# Verificar estado de pagos
curl http://18.224.56.4:5001/pagos/status
```

### Con navegador web:
- `http://18.224.56.4:5002/usuarios/1`
- `http://18.224.56.4:5002/usuarios/2`
- `http://18.224.56.4:5001/pagos/status`

## Usuarios Disponibles

- Usuario 1: Willis (saldo: 500)
- Usuario 2: Ana (saldo: 700)

---

**Nota**: Los servicios están configurados para ejecutarse automáticamente y mantenerse activos sin necesidad de supervisión manual.
