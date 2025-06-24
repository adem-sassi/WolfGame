import socket
from backend.tcp_server.tcp_protocol import TCPProtocol
from backend.tcp_server import actions

HOST = "0.0.0.0"
PORT = 6000

action_map = {
    "list": actions.handle_list,
    "subscribe": actions.handle_subscribe,
    "party_status": actions.handle_party_status,
    "gameboard_status": actions.handle_gameboard_status,
    "move": actions.handle_move
}

def handle_client(conn, addr):
    print(f"🟢 Connexion reçue de {addr}")
    try:
        data = conn.recv(4096)
        if not data:
            return

        message, error = TCPProtocol.parse_message(data)
        if error:
            response = TCPProtocol.make_response(status="KO", response_data={"error": error})
        else:
            action = message.get("action")
            parameters = message.get("parameters", [])

            if action in action_map:
                result = action_map[action](parameters)
                response = TCPProtocol.make_response(status="OK", response_data=result)
            else:
                response = TCPProtocol.make_response(status="KO", response_data={"error": "Action inconnue"})

        conn.sendall(response)

    except Exception as e:
        print(f"❌ Erreur : {e}")
    finally:
        conn.close()
        print(f"🔴 Connexion fermée avec {addr}")

def start_server():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server_socket:
        server_socket.bind((HOST, PORT))
        server_socket.listen()
        print(f"🐺 Serveur TCP Les Loups prêt sur {HOST}:{PORT}")

        while True:
            conn, addr = server_socket.accept()
            handle_client(conn, addr)

if __name__ == "__main__":
    start_server()
