-- trigger qui appelle COMPLETE_TOUR quand un tour est termine

-- fonction du trigger pour appliquer la procedure COMPLETE_TOUR
CREATE OR REPLACE FUNCTION trigger_complete_tour()
RETURNS TRIGGER AS $$
BEGIN
  -- si le champ ended_at vient d'etre rempli
  IF NEW.ended_at IS NOT NULL AND OLD.ended_at IS DISTINCT FROM NEW.ended_at THEN
    CALL COMPLETE_TOUR(NEW.id_turn, NEW.id_game);  -- on appelle la procedure
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- creation du trigger lie a la table turns
CREATE TRIGGER trg_complete_tour
AFTER UPDATE ON turns
FOR EACH ROW
WHEN (NEW.ended_at IS NOT NULL)
EXECUTE FUNCTION trigger_complete_tour();

-- trigger qui appelle USERNAME_TO_LOWER quand un joueur s'inscrit

-- fonction du trigger pour mettre les pseudos en minuscule
CREATE OR REPLACE FUNCTION trigger_username_to_lower()
RETURNS TRIGGER AS $$
BEGIN
  CALL USERNAME_TO_LOWER();  -- on applique la procedure
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- creation du trigger lie a la table game_players
CREATE TRIGGER trg_username_to_lower
AFTER INSERT ON game_players
FOR EACH STATEMENT
EXECUTE FUNCTION trigger_username_to_lower();
