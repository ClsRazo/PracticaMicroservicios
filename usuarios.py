from flask import Flask, jsonify
import pika
import json

usuarios_app = Flask(__name__)

usuarios = {
    1: {"nombre": "Willis", "saldo": 500},
    2: {"nombre": "Ana", "saldo": 700}
}

def enviarMensaje(user_id):
    connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
    channel = connection.channel()
    channel.queue_declare(queue='pagos', durable=True)
    
    mensaje = json.dumps({"user_id": user_id})
    channel.basic_publish(exchange='', routing_key='pagos', body=mensaje, 
                         properties=pika.BasicProperties(delivery_mode=2))  # Hacer el mensaje persistente
    print(f"Mensaje enviado a la cola de pagos: {mensaje}")
    
    connection.close()

@usuarios_app.route("/usuarios/<int:user_id>", methods=["GET"])
def obtenerUsuario(user_id):
    user = usuarios.get(user_id)
    if not user:
        return jsonify({"error": "Usuario no encontrado"}), 404
    return jsonify(user)

@usuarios_app.route("/usuarios/<int:user_id>/pagar", methods=["POST"])
def pagarUsuario(user_id):
    if user_id not in usuarios:
        return jsonify({"error": "Usuario no encontrado"}), 404
    
    enviarMensaje(user_id)
    return jsonify({"mensaje": "Solicitud de pago enviada", "usuario": usuarios[user_id]})

if __name__ == "__main__":
    usuarios_app.run(host='0.0.0.0', port=5004, debug=False)
