class LocalGame:
    def __init__(self, rows=5, cols=5, role='wolf'):
        self.rows = rows
        self.cols = cols
        self.role = role
        self.board = [[0 for _ in range(cols)] for _ in range(rows)]

        self.player_pos = [0, 0]
        self.bot_pos = [rows - 1, cols - 1]

        if role == 'wolf':
            self.board[self.bot_pos[0]][self.bot_pos[1]] = 1  # villageois
            self.board[self.player_pos[0]][self.player_pos[1]] = 2  # loup
        else:
            self.board[self.bot_pos[0]][self.bot_pos[1]] = 2  # loup
            self.board[self.player_pos[0]][self.player_pos[1]] = 1  # villageois

        self.game_over = False
        self.result = None

    def move_player(self, new_row, new_col):
        if self.game_over:
            return

        if not (0 <= new_row < self.rows and 0 <= new_col < self.cols):
            return

        self.board[self.player_pos[0]][self.player_pos[1]] = 0
        self.player_pos = [new_row, new_col]

        if self.player_pos == self.bot_pos:
            self.result = "Victoire du loup 🐺" if self.role == "wolf" else "Défaite du villageois 💀"
            self.game_over = True

        self.board[new_row][new_col] = 1 if self.role == 'villager' else 2
