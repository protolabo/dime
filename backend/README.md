# dime-express
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

## Organisation du code - Backend `dime-express`

Ce backend est développé en **Node.js / Express.js**. Il expose une API REST utilisée par les autres parties du projet (apps mobiles, web, etc.).

---

## Arborescence

```text
backend/
└─ dime-express/
   ├─ index.js
   ├─ package.json
   ├─ supabaseClient.js
   ├─ controllers/
   ├─ routes/
   └─ services/
```

### `index.js`

Point d’entrée du serveur Express :

- Initialise l’application Express.  
- Monte les différentes routes (`routes/*`).  
- Configure les middlewares globaux (JSON, CORS, etc.).  
- Lance l’écoute sur le port défini dans les variables d’environnement.

---

## Dossier `controllers/`

Contient la logique métier de chaque ressource.  
Chaque contrôleur reçoit les requêtes depuis les routes, interagit avec la base de données (via `supabaseClient.js` ou des services) et renvoie une réponse HTTP.

- `alertController.js` : gestion des alertes.  
- `authController.js` : inscription, connexion, gestion des tokens.  
- `favoriteProductController.js` : produits favoris d’un utilisateur.  
- `favoriteStoreController.js` : commerces favoris d’un utilisateur.  
- `pricedProductController.js` : produits avec prix, promotions, etc.  
- `productController.js` : gestion des produits.  
- `promotionController.js` : gestion des promotions.  
- `reviewController.js` : avis / notes sur les produits ou magasins.  
- `shelfController.js` : gestion des étagères en magasin.  
- `shelfPlaceController.js` : emplacements précis sur une étagère.  
- `storeController.js` : gestion des magasins.

**Convention** :  
- Un fichier par ressource REST.  
- Fonctions exportées nommées `create*`, `get*`, `update*`, `delete*` lorsque pertinent.

---

## Dossier `routes/`

Mappe les URLs de l’API sur les fonctions des contrôleurs.

- `alertRoutes.js`  
- `authRoutes.js`  
- `favoriteProductRoutes.js`  
- `favoriteStoreRoutes.js`  
- `pricedProductRoutes.js`  
- `productRoutes.js`  
- `promotionRoutes.js`  
- `reviewRoutes.js`  
- `shelfRoutes.js`  
- `shelfPlaceRoutes.js`  
- `storeRoutes.js`

**Convention** :  
- Utiliser un `express.Router()`.  
- Monter les routes dans `index.js` (ex. `/api/products`, `/api/stores`, etc.).  
- Ne pas mettre de logique métier dans les routes : uniquement déléguer au contrôleur.

---

## Dossier `services/`

Contient les services transverses (utilisés par plusieurs contrôleurs).

- `cloudflareImageService.js` : gestion des images via l’API Cloudflare (upload, URLs, suppression, etc.).  
- `qrCode.js` : logique de génération de QR codes (appel au générateur, création des fichiers, etc.).

**Convention** :  
- Fonctions pures autant que possible.  
- Pas de gestion de requêtes HTTP directement (réservé aux contrôleurs).

---

## `supabaseClient.js`

Centralise la connexion à la base de données Supabase.

- Charge la configuration depuis le fichier `.env`.  
- Exporte un client unique réutilisable dans les contrôleurs / services.

---

## Variables d’environnement

Un fichier `.env` doit être placé à la racine de `dime-express` avec au minimum :

- `SUPABASE_URL`  
- `SUPABASE_KEY`  
- `PORT` (optionnel, sinon valeur par défaut dans `index.js`)

---

## Bonnes pratiques

- Créer un nouveau fichier dans `controllers/` et `routes/` pour chaque nouvelle ressource d’API.  
- Mettre la logique de communication externe (Cloudflare, QR, etc.) dans `services/`.  
- N’utiliser `supabaseClient.js` que dans les contrôleurs et services, jamais directement dans `routes/`.  
- Garder les contrôleurs fins : validation d’entrée, appel à un service, formatage de la réponse.