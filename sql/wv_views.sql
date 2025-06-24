-- vue 1 : infos de base sur les joueurs
CREATE VIEW ALL_PLAYERS AS
SELECT 
    p.username,  -- pseudo du joueur
    COUNT(DISTINCT gp.id_game) AS nb_parties,  -- nombre de parties jouees
    COUNT(m.id_move) AS nb_tours,  -- nombre de tours joues
    MIN(gp.joined_at) AS premiere_participation,  -- premiere participation
    MAX(m.action_time) AS derniere_action  -- derniere action
FROM players p
JOIN game_players gp ON gp.id_player = p.id_player
LEFT JOIN moves m ON m.id_game_player = gp.id_game_player
GROUP BY p.username
ORDER BY nb_parties, premiere_participation, derniere_action, p.username;

-- vue 2 : temps total par joueur et par partie
CREATE VIEW ALL_PLAYERS_ELAPSED_GAME AS
SELECT 
    p.username,  -- pseudo du joueur
    g.name AS nom_partie,  -- nom de la partie
    COUNT(DISTINCT gp2.id_game_player) AS nb_participants,  -- nb de joueurs dans la partie
    MIN(m.action_time) AS debut,  -- debut de la partie pour le joueur
    MAX(m.action_time) AS fin,  -- fin de la partie pour le joueur
    EXTRACT(EPOCH FROM MAX(m.action_time) - MIN(m.action_time)) AS temps_ecoule  -- temps passe en secondes
FROM players p
JOIN game_players gp ON gp.id_player = p.id_player
JOIN games g ON g.id_game = gp.id_game
JOIN game_players gp2 ON gp2.id_game = g.id_game
LEFT JOIN moves m ON m.id_game_player = gp.id_game_player
GROUP BY p.username, g.name;

-- vue 3 : temps mis par joueur pour chaque tour
CREATE VIEW ALL_PLAYERS_ELAPSED_TOUR AS
SELECT 
    p.username,  -- pseudo du joueur
    g.name AS nom_partie,  -- nom de la partie
    t.number AS numero_tour,  -- numero du tour
    t.started_at,  -- debut du tour
    m.action_time,  -- moment ou le joueur a joue
    EXTRACT(EPOCH FROM m.action_time - t.started_at) AS temps_tour  -- temps mis en secondes
FROM players p
JOIN game_players gp ON gp.id_player = p.id_player
JOIN games g ON g.id_game = gp.id_game
JOIN turns t ON t.id_game = g.id_game
JOIN moves m ON m.id_turn = t.id_turn AND m.id_game_player = gp.id_game_player;

-- vue 4 : stats completes par joueur et par partie
CREATE VIEW ALL_PLAYERS_STATS AS
SELECT 
    p.username,  -- pseudo du joueur
    r.name AS role,  -- role du joueur
    g.name AS nom_partie,  -- nom de la partie
    COUNT(m.id_move) AS nb_tours_joues,  -- nb de tours joues
    MAX(t.number) AS nb_total_tours,  -- total de tours dans la partie

    -- determination du vainqueur
    CASE 
        WHEN r.name = 'wolf' AND COUNT(e.id_elimination) = (
            SELECT COUNT(*) FROM game_players gp2 
            JOIN roles r2 ON r2.id_role = gp2.id_role 
            WHERE gp2.id_game = g.id_game AND r2.name = 'villager'
        ) THEN 'wolf'
        WHEN r.name = 'villager' AND COUNT(e.id_elimination) < (
            SELECT COUNT(*) FROM game_players gp2 
            JOIN roles r2 ON r2.id_role = gp2.id_role 
            WHERE gp2.id_game = g.id_game AND r2.name = 'villager'
        ) THEN 'villager'
        ELSE 'en cours'
    END AS vainqueur,

    ROUND(AVG(EXTRACT(EPOCH FROM m.action_time - t.started_at))) AS temps_moyen  -- temps moyen en secondes
FROM players p
JOIN game_players gp ON gp.id_player = p.id_player
JOIN roles r ON r.id_role = gp.id_role
JOIN games g ON g.id_game = gp.id_game
JOIN moves m ON m.id_game_player = gp.id_game_player
JOIN turns t ON t.id_turn = m.id_turn
LEFT JOIN eliminations e ON e.id_game_player = gp.id_game_player
GROUP BY p.username, r.name, g.name;
