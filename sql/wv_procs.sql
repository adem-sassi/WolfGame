-- procedure qui insere des donnees de base pour une partie
CREATE OR REPLACE PROCEDURE SEED_DATA(nb_players INT, party_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
  i INT := 0;
  new_player_id INT;
  new_role TEXT;
BEGIN
  WHILE i < nb_players LOOP
    -- creation d'un joueur fictif
    INSERT INTO players(username) VALUES ('joueur_' || i)
    RETURNING id_player INTO new_player_id;

    -- attribution du role en respectant les quotas
    SELECT random_role(party_id) INTO new_role;

    -- ajout du joueur dans la partie avec le role
    INSERT INTO game_players(id_game, id_player, id_role)
    VALUES
    (
        party_id,
        new_player_id,
        (SELECT id_role FROM roles WHERE name = new_role)
    );

    i := i + 1;
  END LOOP;
END;
$$;

-- procedure qui applique les deplacements d'un tour
CREATE OR REPLACE PROCEDURE COMPLETE_TOUR(tour_id INT, party_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
  gp RECORD;
  loup RECORD;
  villageois RECORD;
BEGIN
  -- boucle sur les joueurs pour appliquer les deplacements
  FOR gp IN 
    SELECT m.*, gp.id_role
    FROM moves m
    JOIN game_players gp ON gp.id_game_player = m.id_game_player
    WHERE m.id_turn = tour_id
  LOOP
    -- ici on peut ajouter la logique de verif si le deplacement est valide ou non
    -- mais on garde simple pour l'instant
    CONTINUE;
  END LOOP;

  -- verifie si un loup est sur la meme case qu'un villageois
  FOR loup IN
    SELECT m.move_row, m.move_col, m.id_game_player
    FROM moves m
    JOIN game_players gp ON gp.id_game_player = m.id_game_player
    WHERE gp.id_role = (SELECT id_role FROM roles WHERE name = 'wolf')
      AND m.id_turn = tour_id
  LOOP
    FOR villageois IN
      SELECT m.move_row, m.move_col, m.id_game_player
      FROM moves m
      JOIN game_players gp ON gp.id_game_player = m.id_game_player
      WHERE gp.id_role = (SELECT id_role FROM roles WHERE name = 'villager')
        AND m.id_turn = tour_id
    LOOP
      IF loup.move_row = villageois.move_row AND loup.move_col = villageois.move_col THEN
        -- le villageois est elimine
        INSERT INTO eliminations(id_turn, id_game_player, eliminated)
        VALUES (tour_id, villageois.id_game_player, TRUE);
      END IF;
    END LOOP;
  END LOOP;
END;
$$;

-- procedure qui met tous les pseudos en minuscule
CREATE OR REPLACE PROCEDURE USERNAME_TO_LOWER()
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE players
  SET username = LOWER(username);
END;
$$;
