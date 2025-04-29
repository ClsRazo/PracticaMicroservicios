from flask import Flask, jsonify
import requests

gateway_app = Flask(__name__)

SERVICIOUSUARIOS = "http://127.0.0.1:5000"
SERVICIOPAGOS = "http://127.0.0.1:5001"

@gateway_app.route("/usuarios/<int:user_id>", methods=["GET"])
def obtenerUsuario(user_id):
    response = requests.get(f"{SERVICIOUSUARIOS}/usuarios/{user_id}")
    return jsonify(response.json())

@gateway_app.route("/usuarios/<int:user_id>/pagar", methods=["POST"])
def pagarUsuario(user_id):
    response = requests.post(f"{SERVICIOUSUARIOS}/usuarios/{user_id}/pagar")
    return jsonify(response.json())

@gateway_app.route("/pagos/procesar", methods=["POST"])
def procesarPagos():
    response = requests.post(f"{SERVICIOPAGOS}/pagos/procesar")
    return jsonify(response.json())

if __name__ == "__main__":
    gateway_app.run(port=5002)
