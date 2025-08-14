# dime-express

Ce répertoire contient le générateur de codes QR. Il a été développé avec **Express.js** et **JavaScript**.

---

## Compiler et lancer le générateur de codes QR

### 1️⃣ Se placer dans le répertoire du backend
```bash
cd backend\dime-express
```

### 2️⃣ Télécharger les dépendances
```bash
npm install
```

### 3️⃣ Lancer le générateur
```bash
npm start
```

---

## Organisation du code

Le projet étant encore en phase de développement, certains fichiers sont inutilisés et pourront être supprimés à l’avenir.  
Ces fichiers sont marqués d’un **\***.

**⚠️ Le fichier `.env` contenant les informations liées à la base de données (non inclus dans le dépôt GitHub) doit être ajouté à la racine du répertoire [`dime-express`](dime-express) pour que le projet fonctionne correctement.**

---

- [database](dime-express/database)*
- [QR-CODE-GENERATOR](dime-express/QR-CODE-GENERATOR) : Répertoire contenant les fichiers principaux du générateur de codes QR. Son organisation est détaillée dans la section suivante.
- [index.js](dime-express/index.js)*
- [package.json](dime-express/package.json) : Fichier de configuration Node.js.
- [package-lock.json](dime-express/package-lock.json) : Fichier de verrouillage des dépendances Node.js.
- [supabaseClient.js](dime-express/supabaseClient.js) : Gère la connexion avec la base de données (utilise le fichier `.env`).

---

### Répertoire `QR-CODE-GENERATOR`

- [public/qr](dime-express/QR-CODE-GENERATOR/public/qr) : Contient tous les codes QR des étagères et items de la base de données, organisés par commerce. Les nouveaux codes QR sont générés à la [racine de ce répertoire](dime-express/QR-CODE-GENERATOR/public/qr).
- [QR_Code.js](dime-express/QR-CODE-GENERATOR/QR_Code.js) : Contient tout le code nécessaire pour la communication avec l’application [Flutter](../frontend/dime_flutter) et la génération des nouveaux codes QR.
