from backend.database.db import SessionLocal
from backend.database.models import Party, Player
import random

# 1. Lister les parties ouvertes non commencées
def handle_list(params):
    session = SessionLocal()
    try:
        parties = session.query(Party).filter(Party.started == False).all()
        return {
            "id_parties": [p.id for p in parties]
        }
    finally:
        session.close()


# 2. Inscription à une partie
def handle_subscribe(params):
    session = SessionLocal()
    try:
        player_name = next((p.get("player") for p in params if "player" in p), None)
        party_id = next((p.get("id_party") for p in params if "id_party" in p), None)

        if not player_name or not party_id:
            return {"error": "Paramètres manquants"}

        existing = session.query(Player).filter_by(username=player_name, party_id=party_id).first()
        if existing:
            return {"error": "Joueur déjà inscrit"}

        # Rôle aléatoire (à remplacer par fonction PostgreSQL)
        role = random.choice(["wolf", "villager"])

        new_player = Player(username=player_name, role=role, party_id=party_id)
        session.add(new_player)
        session.commit()

        return {
            "role": role,
            "id_player": new_player.id
        }
    except Exception as e:
        session.rollback()
        return {"error": str(e)}
    finally:
        session.close()


# 3. Statut de la partie (ex: état du tour)
def handle_party_status(params):
    id_player = next((p.get("id_player") for p in params if "id_player" in p), None)
    id_party = next((p.get("id_party") for p in params if "id_party" in p), None)

    if not id_player or not id_party:
        return {"error": "Paramètres manquants"}

    # 🔧 Exemples mockés à améliorer plus tard
    return {
        "party": {
            "id_party": id_party,
            "id_player": id_player,
            "started": True,
            "round_in_progress": 1,
            "move": {
                "next_position": {
                    "row": 0,
                    "col": 1
                }
            }
        }
    }


# 4. État du plateau (mock)
def handle_gameboard_status(params):
    id_party = next((p.get("id_party") for p in params if "id_party" in p), None)
    id_player = next((p.get("id_player") for p in params if "id_player" in p), None)

    if not id_party or not id_player:
        return {"error": "Paramètres manquants"}

    # Exemple : 3x3 autour du joueur
    return {
        "visible_cells": "010010000"
    }


# 5. Déplacement du joueur (mock)
def handle_move(params):
    id_party = next((p.get("id_party") for p in params if "id_party" in p), None)
    id_player = next((p.get("id_player") for p in params if "id_player" in p), None)
    move_vector = next((p.get("move") for p in params if "move" in p), None)

    if not id_party or not id_player or not move_vector:
        return {"error": "Paramètres manquants"}

    # Pour le moment, on retourne juste ce qui a été reçu
    try:
        row_offset = int(move_vector[0])
        col_offset = int(move_vector[1])
    except:
        return {"error": "Mouvement invalide"}

    return {
        "round_in_progress": 1,
        "move": {
            "next_position": {
                "row": row_offset,
                "col": col_offset
            }
        }
    }
