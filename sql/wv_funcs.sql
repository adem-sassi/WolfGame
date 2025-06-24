-- fonction qui retourne une position aleatoire libre sur le plateau
CREATE OR REPLACE FUNCTION random_position(party_id INT)
RETURNS TABLE(row_pos INT, col_pos INT)
AS $$
BEGIN
  LOOP
    -- on genere une ligne entre 0 et 9
    row_pos := FLOOR(RANDOM() * 10)::INT;

    -- on genere une colonne entre 0 et 9
    col_pos := FLOOR(RANDOM() * 10)::INT;

    -- on verifie que cette position n'est pas deja prise
    EXIT WHEN NOT EXISTS 
    (
      SELECT 1 FROM moves m
      JOIN game_players gp ON gp.id_game_player = m.id_game_player
      WHERE gp.id_game = party_id
      AND m.move_row = row_pos AND m.move_col = col_pos
    );

    -- si elle est libre, on la retourne
    RETURN NEXT;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- fonction qui retourne le prochain role a attribuer (loup ou villageois)
CREATE OR REPLACE FUNCTION random_role(party_id INT)
RETURNS TEXT
AS $$
DECLARE
  nb_loups INT;  -- nombre de loups deja inscrits
  nb_villageois INT;  -- nombre de villageois deja inscrits
BEGIN
  -- on compte les loups
  SELECT COUNT(*) INTO nb_loups FROM game_players gp
  JOIN roles r ON r.id_role = gp.id_role
  WHERE gp.id_game = party_id AND r.name = 'wolf';

  -- on compte les villageois
  SELECT COUNT(*) INTO nb_villageois FROM game_players gp
  JOIN roles r ON r.id_role = gp.id_role
  WHERE gp.id_game = party_id AND r.name = 'villager';

  -- on retourne 'wolf' si moins ou egal de loups que de villageois
  IF nb_loups <= nb_villageois THEN
    RETURN 'wolf';
  ELSE
    RETURN 'villager';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- fonction qui retourne les infos du gagnant d'une partie
CREATE OR REPLACE FUNCTION get_the_winner(party_id INT)
RETURNS TABLE
(
  username TEXT,  -- pseudo du joueur
  role TEXT,  -- role du joueur
  nom_partie TEXT,  -- nom de la partie
  nb_tours_joues INT,  -- nombre de tours joues
  nb_total_tours INT,  -- nombre total de tours de la partie
  temps_moyen DECIMAL  -- temps moyen de reaction du joueur
)
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.username,
    r.name,
    g.name,
    COUNT(m.id_move),
    MAX(t.number),
    ROUND(AVG(EXTRACT(EPOCH FROM m.action_time - t.started_at)))
  FROM players p
  JOIN game_players gp ON gp.id_player = p.id_player
  JOIN roles r ON r.id_role = gp.id_role
  JOIN games g ON g.id_game = gp.id_game
  JOIN moves m ON m.id_game_player = gp.id_game_player
  JOIN turns t ON t.id_turn = m.id_turn
  WHERE g.id_game = party_id
  GROUP BY p.username, r.name, g.name;
END;
$$ LANGUAGE plpgsql;
