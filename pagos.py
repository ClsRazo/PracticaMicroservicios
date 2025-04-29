from flask import Flask, jsonify
import pika
import json

pagos_app = Flask(__name__)

def procesarPago(user_id):
    print(f"Procesando pago para el usuario {user_id}")

def callback(ch, method, properties, body):
    data = json.loads(body)
    user_id = data["user_id"]
    procesarPago(user_id)
    ch.basic_ack(delivery_tag=method.delivery_tag)

def consumirMensajes():
    connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
    channel = connection.channel()
    channel.queue_declare(queue='pagos')
    
    channel.basic_consume(queue='pagos', on_message_callback=callback)
    
    print("Microservicio de pagos esperando mensajes...")
    channel.start_consuming()

@pagos_app.route("/pagos/procesar", methods=["POST"])
def iniciarProcesamiento():
    consumirMensajes()
    return jsonify({"mensaje": "Procesamiento de pagos iniciado"})

if __name__ == "__main__":
    pagos_app.run(port=5001)
