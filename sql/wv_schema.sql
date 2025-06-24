-- table des joueurs
CREATE TABLE players (
    id_player SERIAL PRIMARY KEY,  -- id de chaque joueur
    username VARCHAR(50) NOT NULL,  -- pseudo du joueur
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- date et heure d'inscription
);

-- table des parties
CREATE TABLE games (
    id_game SERIAL PRIMARY KEY,  -- id unique de la partie
    name VARCHAR(100) NOT NULL,  -- nom ou titre de la partie
    rows INTEGER NOT NULL,  -- nombre de lignes du plateau
    cols INTEGER NOT NULL,  -- nombre de colonnes du plateau
    nb_turns INTEGER NOT NULL,  -- nombre total de tours
    max_players INTEGER NOT NULL,  -- nb max de joueurs dans la partie
    time_per_turn INTEGER NOT NULL,  -- temps max par tour (en secondes)
    nb_obstacles INTEGER NOT NULL,  -- nb d'obstacles sur le plateau
    started BOOLEAN DEFAULT FALSE  -- true si la partie a commence
);

-- table des roles (loup ou villageois)
CREATE TABLE roles (
    id_role SERIAL PRIMARY KEY,  -- id du role
    name VARCHAR(20) CHECK (name IN ('wolf', 'villager'))  -- nom du role
);

-- table des joueurs dans les parties
CREATE TABLE game_players (
    id_game_player SERIAL PRIMARY KEY,  -- id unique de joueur dans la partie
    id_game INTEGER REFERENCES games(id_game),  -- reference a la partie
    id_player INTEGER REFERENCES players(id_player),  -- reference au joueur
    id_role INTEGER REFERENCES roles(id_role),  -- role attribue
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- date d'entree dans la partie
    UNIQUE(id_game, id_player)  -- un joueur ne peut s'inscrire qu'une fois par partie
);

-- table des obstacles sur le plateau
CREATE TABLE obstacles (
    id_obstacle SERIAL PRIMARY KEY,  -- id de l'obstacle
    id_game INTEGER REFERENCES games(id_game),  -- reference a la partie
    row_pos INTEGER,  -- position ligne
    col_pos INTEGER  -- position colonne
);

-- table des tours
CREATE TABLE turns (
    id_turn SERIAL PRIMARY KEY,  -- id du tour
    id_game INTEGER REFERENCES games(id_game),  -- partie concernee
    number INTEGER NOT NULL,  -- numero du tour
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- debut du tour
    ended_at TIMESTAMP  -- fin du tour
);

-- table des deplacements
CREATE TABLE moves (
    id_move SERIAL PRIMARY KEY,  -- id du deplacement
    id_turn INTEGER REFERENCES turns(id_turn),  -- tour concerne
    id_game_player INTEGER REFERENCES game_players(id_game_player),  -- joueur concerne
    move_row INTEGER,  -- deplacement vertical (-1 0 1)
    move_col INTEGER,  -- deplacement horizontal (-1 0 1)
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- moment ou le joueur a joue
    valid BOOLEAN DEFAULT TRUE  -- si le deplacement est valide
);

-- table des eliminations
CREATE TABLE eliminations (
    id_elimination SERIAL PRIMARY KEY,  -- id de l'elimination
    id_turn INTEGER REFERENCES turns(id_turn),  -- tour ou ca s'est passe
    id_game_player INTEGER REFERENCES game_players(id_game_player),  -- joueur elimine
    eliminated BOOLEAN DEFAULT FALSE  -- true si elimine
);
