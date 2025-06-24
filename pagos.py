from flask import Flask, jsonify
import pika
import json
import threading
import time

pagos_app = Flask(__name__)

def procesarPago(user_id):
    print(f"Procesando pago para el usuario {user_id}")
    # Aquí podrías agregar lógica real de procesamiento de pagos
    time.sleep(2)  # Simular procesamiento
    print(f"Pago procesado exitosamente para usuario {user_id}")

def callback(ch, method, properties, body):
    try:
        data = json.loads(body)
        user_id = data["user_id"]
        procesarPago(user_id)
        ch.basic_ack(delivery_tag=method.delivery_tag)
    except Exception as e:
        print(f"Error procesando mensaje: {e}")
        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)

def consumirMensajes():
    while True:
        try:
            connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
            channel = connection.channel()
            channel.queue_declare(queue='pagos', durable=True)
            
            channel.basic_qos(prefetch_count=1)
            channel.basic_consume(queue='pagos', on_message_callback=callback)
            
            print("Microservicio de pagos esperando mensajes...")
            channel.start_consuming()
        except Exception as e:
            print(f"Error en conexión RabbitMQ: {e}")
            time.sleep(5)  # Esperar 5 segundos antes de reintentar

# Iniciar el consumidor en un hilo separado
def iniciar_consumidor():
    consumer_thread = threading.Thread(target=consumirMensajes)
    consumer_thread.daemon = True
    consumer_thread.start()

@pagos_app.route("/pagos/status", methods=["GET"])
def status():
    return jsonify({"mensaje": "Microservicio de pagos activo", "status": "running"})

@pagos_app.route("/pagos/procesar", methods=["POST"])
def iniciarProcesamiento():
    return jsonify({"mensaje": "Microservicio de pagos está procesando mensajes automáticamente"})

if __name__ == "__main__":
    # Iniciar el consumidor de mensajes
    iniciar_consumidor()
    # Iniciar la aplicación Flask
    pagos_app.run(host='0.0.0.0', port=5001, debug=False)
