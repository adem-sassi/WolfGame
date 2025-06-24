import tkinter as tk
from client.local_game.engine import LocalGame

class GameGUI:
    def __init__(self, master, role='wolf'):
        self.master = master
        self.master.title("Les Loups – Mode Solo")
        self.game = LocalGame(role=role)
        self.buttons = []

        tk.Label(master, text=f"Rôle : {role}", font=("Arial", 14)).pack()
        self.grid_frame = tk.Frame(master)
        self.grid_frame.pack()

        for i in range(self.game.rows):
            row_buttons = []
            for j in range(self.game.cols):
                btn = tk.Button(self.grid_frame, width=6, height=3,
                                command=lambda r=i, c=j: self.handle_move(r, c))
                btn.grid(row=i, column=j)
                row_buttons.append(btn)
            self.buttons.append(row_buttons)

        self.status = tk.Label(master, text="Clique pour te déplacer", font=("Arial", 12))
        self.status.pack()

        self.update_board()

    def handle_move(self, row, col):
        self.game.move_player(row, col)
        self.update_board()
        if self.game.game_over:
            self.status.config(text=self.game.result)

    def update_board(self):
        for i in range(self.game.rows):
            for j in range(self.game.cols):
                val = self.game.board[i][j]
                btn = self.buttons[i][j]
                if val == 0:
                    btn.config(text="", bg="lightgrey")
                elif val == 1:
                    btn.config(text="👨‍🌾", bg="green")
                elif val == 2:
                    btn.config(text="🐺", bg="red")

if __name__ == "__main__":
    role = input("Choisis ton rôle (wolf/villager) : ").strip()
    root = tk.Tk()
    GameGUI(root, role if role in ['wolf', 'villager'] else 'wolf')
    root.mainloop()
