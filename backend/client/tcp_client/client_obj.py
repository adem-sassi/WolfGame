import socket
import json

class TCPClient:
    def __init__(self, host="localhost", port=6000):
        self.host = host
        self.port = port
        self.sock = None
        self.id_party = None
        self.id_player = None

    def connect(self):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.connect((self.host, self.port))

    def disconnect(self):
        if self.sock:
            self.sock.close()
            self.sock = None

    def send(self, action, parameters):
        request = {"action": action, "parameters": parameters}
        self.sock.sendall(json.dumps(request).encode())

    def receive(self):
        data = self.sock.recv(4096)
        return json.loads(data.decode())

    def request(self, action, parameters):
        self.connect()
        self.send(action, parameters)
        response = self.receive()
        self.disconnect()
        return response

    def subscribe(self, username, id_party):
        self.id_party = id_party
        response = self.request("subscribe", [
            {"player": username},
            {"id_party": id_party}
        ])
        if response["status"] == "OK":
            self.id_player = response["response"]["id_player"]
        return response

    def party_status(self):
        return self.request("party_status", [
            {"id_player": self.id_player},
            {"id_party": self.id_party}
        ])

    def gameboard_status(self):
        return self.request("gameboard_status", [
            {"id_party": self.id_party},
            {"id_player": self.id_player}
        ])

    def move(self, direction):
        return self.request("move", [
            {"id_party": self.id_party},
            {"id_player": self.id_player},
            {"move": direction}
        ])

    def list_parties(self):
        return self.request("list", [])
