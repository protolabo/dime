# dime_flutter

Ce répertoire contient **toute la partie frontend** du projet.  
Le projet utilise le framework **Flutter**, qui permet de développer des applications multiplateformes.  
Dans notre cas, il est utilisé pour créer **une application mobile** compatible **Android** et **iOS**.

---

## Compiler et lancer le projet Flutter

### 1️⃣ Se placer dans le répertoire Flutter
```bash
cd frontend-dime_flutter
```

### 2️⃣ Télécharger les [dépendances](#dépendances-flutter-utilisées-pour-le-projet)
```bash
flutter pub get
```

### 3️⃣ Lancer le projet sur un appareil mobile ou un émulateur
```bash
flutter run
```

💡 Pour vérifier si l’appareil est bien détecté par Flutter :
```bash
flutter devices
```

⚠️ **Limitation iOS** : il est uniquement possible d’exécuter l’application sur iOS depuis un Mac (oui, c’est vraiment poche).

---

## Dépendances Flutter utilisées pour le projet

Toutes les dépendances sont listées dans le fichier [pubspec.yaml](dime_flutter/pubspec.yaml), sous la section **dependencies**.

Voici la liste et leur utilité :
- **cupertino_icons** : Icônes au style iOS.
- **flutter_svg** : Affichage de fichiers SVG.
- **mobile_scanner** : Scanner de codes QR et codes-barres.
- **supabase_flutter** : Connexion à l’API Supabase (base de données du projet).
- **http** : Communication avec le [backend du générateur de codes QR](../backend).
- **provider** : Gestion et partage d’états à travers l’application.
- **flutter_dotenv** : Chargement de variables depuis un fichier `.env` (par ex. clés pour Supabase).
  > Le fichier `.env` doit être placé à la [racine du projet Flutter](dime_flutter).
- **shared_preferences** : Stockage de paires clé/valeur (semblable à un HashMap).

---

## Organisation du code - Frontend `dime_flutter`

Le frontend est une application **Flutter** située dans le dossier `frontend/dime_flutter`.  
L’architecture choisie est **MVVM** (Model/View/ViewModel).

---

### Arborescence générale

```text
frontend/
└─ dime_flutter/
   ├─ lib/
   │  ├─ main.dart
   │  ├─ auth_viewmodel.dart
   │  ├─ view/
   │  └─ vm/
   ├─ assets/
   ├─ android/
   ├─ ios/
   ├─ web/
   ├─ macos/
   ├─ linux/
   ├─ windows/
   ├─ pubspec.yaml
   └─ test/
```

---

### `lib/main.dart`

Point d’entrée de l’application Flutter :

- Initialisation de l’app (`runApp`).  
- Configuration du thème global et des styles principaux.  
- Définition des routes/pages de haut niveau.

---

### Architecture MVVM

L’architecture est organisée en **3 couches principales** :

1. **View (`lib/view`)** :  
   Widgets, pages et composants visibles par l’utilisateur.  
   - Aucune logique métier lourde.  
   - Interaction uniquement via les ViewModels (fichiers du dossier `vm`).

2. **ViewModel (`lib/vm`)** :  
   Logique métier et gestion d’état.  
   - Appelle les services (API, Supabase, etc.).  
   - Expose des données réactives à la vue (via `provider`).

3. **Model** (objets de données) :  
   - Représentation des entités métier (produits, commerces, étagères, etc.).  
   - Souvent définis dans les ViewModels ou dans des fichiers dédiés (si besoin de factorisation).

---

### 📂 Dossier `lib/view` - *Views*

Contient toutes les pages et composants graphiques.

- `styles.dart` : centralise les styles communs - couleurs, marges, typographies, etc.

Sous-dossiers :

- `view/client` :  
Pages destinées aux **clients** : favoris, recherche, page produit, page commerce, scanner QR, etc.

- `view/commercant` :  
Pages destinées aux **commerçants** : création d’items, création d’étagères, gestion des produits/étagères, scanner QR, etc.

- `view/components` :  
Composants réutilisables (headers, barres de navigation, etc.).

**Convention :**

- Une vue par fichier.  
- Pas d’appels directs au backend dans les vues.  
- Toute la logique métier passe par un ViewModel situé dans `lib/vm`.

---

### 📂 Dossier `lib/vm` - *ViewModels*

Contient la logique métier et de présentation.

- Relation **1-to-1** avec les fichiers du dossier `view` (même nom, suffixé par `_vm`), sauf quelques exceptions (comme les pages de scan QR qui partagent `scan_page_vm.dart`).

Exemples de fichiers notables :

- `current_connected_account_vm.dart` : simule la connexion d’un compte (client ou commerçant).  
- `current_store.dart` : simule la présence d’un client dans un commerce.  
- `favorite_product_vm.dart` : gère les produits favoris.  
- `favorite_store_vm.dart` : gère les commerces favoris.  
- `store_picker.dart` : change le commerce actif côté client (outil de dev).  
- `scan_page_vm.dart` : logique commune de scan de QR code (client et commerçant).

**Convention :**

- Un ViewModel par vue (quand nécessaire).  
- Toute la logique de récupération de données (Supabase, backend QR, etc.) va dans les ViewModels ou des services dédiés.  
- Les ViewModels exposent uniquement les données et méthodes nécessaires aux vues.

---

### 📂 Ressources et configuration

- `assets/` :  
Contient notamment les icônes (dont l’icône principale `dime.png`), déclarées dans `pubspec.yaml`.

- `.env` :  
Un fichier `.env` doit être ajouté **à la racine de `dime_flutter`** pour configurer les accès Supabase et backend (non versionné dans Git).

