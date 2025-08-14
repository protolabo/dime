# Projet Dime

## 🌐 Infrastructure


# 📘 Documentation

## Prérequis

Assurez-vous d’avoir les outils suivants installés :

- Python **3.8** ou plus récent
- `pip` (gestionnaire de paquets Python)
- [Flutter](https://docs.flutter.dev/get-started/install)
- [Node.js](https://nodejs.org/en/download)

## Installation

1. Clonez ce dépôt :
```bash
git clone git@github.com:udem-diro/template-projet.git
cd ift3150-template
```

2. Installez les dépendances :
```bash
pip install -r requirements.txt
```

## Utilisation

### Développement local

Pour lancer un serveur de développement local :

```bash
mkdocs serve
```

Le site sera accessible à l'adresse [http://127.0.0.1:8000](http://127.0.0.1:8000)

### Construction du site

Pour construire le site :

```bash
mkdocs build
```

Les fichiers générés seront dans le dossier `site/`.

### Déploiement

Pour déployer sur GitHub Pages :

```bash
mkdocs gh-deploy
```

> Cette commande pousse automatiquement le contenu du site sur la branche gh-pages.


Pour le fonctionnement du frontend ainsi que du "backend", veuillez lire les instructions des README correspondants:

- [README du repertoire frontend](frontend/README.md)
- [README du repertoire backend](backend/README.md)

## Structure du projet

- `docs/` : Contient tous les fichiers Markdown du site
- `mkdocs.yml` : Configuration de MkDocs
- `requirements.txt` : Dépendances Python
- `site/` : Site généré (créé lors de la construction)
- `frontend/` : Développement du frontend Flutter
- `backend/` : Développement du générateur de code QR avec Express.js. Pour l'instant, le projet utilise l'API auto-généré de la base de donnée Supabase. Il n'y a techniquement pas de backend ordinaire.

## Personnalisation

1. Modifiez `mkdocs.yml` pour changer la configuration du site
2. Ajoutez/modifiez les fichiers Markdown (`.md`) dans `docs/`
3. Personnalisez le thème en modifiant les paramètres dans `mkdocs.yml`

# 🗂️ Organisation

L'organisation des répertoires [frontend](frontend/README.md) et [backend](backend/README.md) est expliqué en détail dans les README.md correspondants.

# 🌟 Contribution

Si vous êtes intéressé à participer au projet, veuillez prendre contact avec [Louis-Edouard LAFONTANT](mailto:louis.edouard.lafontant@umontreal.ca).

## Contributeurs
- De-Webertho Dieudonné 
- Patrick Symenouh
