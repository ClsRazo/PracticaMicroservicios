from flask import Flask, jsonify
import requests

gateway_app = Flask(__name__)

SERVICIOUSUARIOS = "http://localhost:5004"
SERVICIOPAGOS = "http://localhost:5001"

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
    gateway_app.run(host='0.0.0.0', port=5002, debug=False)
