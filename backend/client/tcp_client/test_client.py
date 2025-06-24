from client.tcp_client.client_obj import TCPClient

client = TCPClient()

print("🔍 Parties disponibles :")
print(client.list_parties())

username = input("Nom du joueur : ")
party_id = int(input("ID de la partie : "))
print(client.subscribe(username, party_id))

print("🧠 Statut de la partie :")
print(client.party_status())

print("🗺️ Plateau visible :")
print(client.gameboard_status())

move = input("Mouvement (ex: 01, 10) : ")
print(client.move(move))
