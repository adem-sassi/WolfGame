## Projet Les Loups - L'Utilisation de Docker
# Présentation rapide
Ce projet utilise Docker pour lancer plusieurs services :

une base de donnée PostgreSQL

pgAdmin pour voir la base

un serveur HTTP

un serveur TCP

un script pour insérer des données 

Il faut avoir Docker et Docker Compose d’installer sur ton ordi.
Vérifie avec les commandes suivantes :

docker -v
docker-compose -v


# Lancer les services
Pour démarrer tous les services, va à la racine du projet (là ou y'a le fichier docker-compose.yml) et lance :

docker-compose up --build


# Une fois que tout est lancé :

PostgreSQL est dispo sur le port 5432 (user: loupuser, mdp: louppass, db: lesloups)

pgAdmin est dispo sur http://localhost:5055
(login: admin@loups.com, mdp: admin)

Serveur HTTP tourne sur http://localhost:5000

Serveur TCP écoute sur le port 6000

# Seed
Le service seed sert juste à insérer des données de test dans la base.
Il s'execute automatiquement au lancement, tu peux aussi le relancer comme ça :

docker-compose run seed



