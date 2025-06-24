import tkinter as tk
from client.tcp_client.client_obj import TCPClient

class TCPGameGUI:
    def __init__(self, root):
        self.root = root
        self.client = TCPClient()
        self.grid_size = 3  # pour visible_cells (3x3)
        self.role = None
        self.build_login_screen()

    def build_login_screen(self):
        self.clear_window()
        tk.Label(self.root, text="Nom du joueur").pack()
        self.username_entry = tk.Entry(self.root)
        self.username_entry.pack()

        tk.Label(self.root, text="ID de la partie").pack()
        self.party_entry = tk.Entry(self.root)
        self.party_entry.pack()

        tk.Button(self.root, text="S'inscrire", command=self.subscribe).pack(pady=10)

    def subscribe(self):
        username = self.username_entry.get()
        try:
            party_id = int(self.party_entry.get())
        except:
            return

        res = self.client.subscribe(username, party_id)
        if res["status"] == "OK":
            self.role = res["response"]["role"]
            self.build_game_screen()
        else:
            tk.Label(self.root, text="❌ Erreur d'inscription", fg="red").pack()

    def build_game_screen(self):
        self.clear_window()

        # Affiche le rôle (privé)
        role_text = f"🎭 Tu es un {self.role.upper()} {'🐺' if self.role == 'wolf' else '👨‍🌾'}"
        tk.Label(self.root, text=role_text, font=("Arial", 14, "bold"),
                 fg="red" if self.role == "wolf" else "green").pack(pady=5)

        self.info = tk.Label(self.root, text=f"Connecté – Joueur #{self.client.id_player} | Partie #{self.client.id_party}")
        self.info.pack()

        self.grid_frame = tk.Frame(self.root)
        self.grid_frame.pack()

        self.buttons = []
        for i in range(self.grid_size):
            row = []
            for j in range(self.grid_size):
                btn = tk.Button(self.grid_frame, width=6, height=3,
                                command=lambda r=i, c=j: self.send_move(r, c))
                btn.grid(row=i, column=j)
                row.append(btn)
            self.buttons.append(row)

        self.refresh_button = tk.Button(self.root, text="🔄 Rafraîchir le plateau", command=self.refresh_board)
        self.refresh_button.pack(pady=5)

        self.status = tk.Label(self.root, text="")
        self.status.pack()

        self.refresh_board()

    def send_move(self, r, c):
        # Convertit clic en déplacement relatif (row,col) vers "xy"
        row_diff = r - 1
        col_diff = c - 1
        if not (-1 <= row_diff <= 1 and -1 <= col_diff <= 1):
            self.status.config(text="❌ Déplacement invalide")
            return

        # Conversion pour respecter le protocole move "01", "10", etc.
        move_str = f"{row_diff:+d}{col_diff:+d}".replace("+", "").replace("-", "1")
        # ex: (-1, 0) → "10", (0, 1) → "01"

        res = self.client.move(move_str)
        if res["status"] == "OK":
            self.status.config(text="✅ Déplacement effectué")
        else:
            self.status.config(text="❌ Erreur : " + str(res["response"].get("error")))
        self.refresh_board()

    def refresh_board(self):
        res = self.client.gameboard_status()
        if res["status"] != "OK":
            self.status.config(text="❌ Impossible de récupérer le plateau")
            return

        visible = res["response"]["visible_cells"]
        for i in range(self.grid_size):
            for j in range(self.grid_size):
                cell_val = visible[i * self.grid_size + j]
                btn = self.buttons[i][j]
                if cell_val == "0":
                    btn.config(text="", bg="lightgrey")
                elif cell_val == "1":
                    btn.config(text="👨‍🌾", bg="green")
                elif cell_val == "2":
                    btn.config(text="🐺", bg="red")
                elif cell_val == "3":
                    btn.config(text="🪨", bg="black", fg="white")

    def clear_window(self):
        for widget in self.root.winfo_children():
            widget.destroy()

if __name__ == "__main__":
    root = tk.Tk()
    root.title("🌐 Les Loups – GUI TCP multijoueur")
    app = TCPGameGUI(root)
    root.mainloop()
