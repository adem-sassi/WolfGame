from backend.database.db import SessionLocal, engine
from backend.database.models import Base, Party, Player, Tour, Action
import random
from datetime import datetime, timedelta

# Réinitialise la base (optionnel)
def reset_db():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)

# Peuple la base avec des données simples
def seed_data():
    session = SessionLocal()
    try:
        # Créer une partie
        party = Party(name="Partie de test", started=True, max_players=6, nb_tours=3, time_limit=60)
        session.add(party)
        session.commit()

        # Ajouter des joueurs
        roles = ["wolf", "villager", "villager", "wolf", "villager", "villager"]
        for i, role in enumerate(roles):
            player = Player(username=f"joueur{i+1}", role=role, party_id=party.id)
            session.add(player)

        session.commit()

        # Créer des tours
        for round_num in range(1, 4):
            tour = Tour(party_id=party.id, round_number=round_num,
                        started_at=datetime.now() - timedelta(minutes=round_num))
            session.add(tour)
            session.commit()

            # Actions pour chaque joueur
            players = session.query(Player).filter_by(party_id=party.id).all()
            for p in players:
                move = random.choice(["00", "01", "10", "11", ""])
                action = Action(player_id=p.id, tour_id=tour.id, direction=move)
                session.add(action)

        session.commit()
        print("✅ Données injectées avec succès !")

    except Exception as e:
        session.rollback()
        print(f"❌ Erreur : {e}")
    finally:
        session.close()


if __name__ == "__main__":
    print("🧪 Seeding base de données Les Loups...")
    reset_db()  # ❗ Peut être commenté si tu ne veux pas reset
    seed_data()
