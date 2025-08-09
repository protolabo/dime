# dime_flutter

Ce répertoire contient **toute la partie frontend** du projet.  
Le projet utilise le framework **Flutter**, qui permet de développer des applications multiplateformes.  
Dans notre cas, il est utilisé pour créer **une application mobile** compatible **Android** et **iOS**.

---

## Compiler et lancer le projet Flutter

### 1️⃣ Se placer dans le répertoire Flutter
```bash
cd frontend\dime_flutter
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

⚠️ **Limitation iOS** : il est uniquement possible d’exécuter l’application sur iOS depuis un Mac (Je le sais, c'est vraiment poche).

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

## Organisation du code

Comme tout projet Flutter, le code source se trouve dans le répertoire [lib](dime_flutter/lib).  
L’architecture utilisée est **[MVVM](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)**, recommandée dans la [documentation officielle Flutter](https://docs.flutter.dev/app-architecture/guide).

---

### 📂 [Répertoire _view_](dime_flutter/lib/view)

- **[styles.dart](dime_flutter/lib/view/styles.dart)** : Contient la majorité des paramètres de style (couleurs, marges, tailles de police, etc.).

Sous-répertoires :
- **[client](dime_flutter/lib/view/client)** : Pages et composants pour les utilisateurs clients.
  - `favorite_menu.dart` : Produits et commerces favoris du client connecté.
  - `item_page_customer.dart` : Template de la page d’un produit.
  - `scan_page_client.dart` : Scanner de code QR.
  - `search_page.dart` : Recherche de produits et commerces.
  - `store_page_customer.dart` : Page d’un commerce côté client.

- **[commercant](dime_flutter/lib/view/commercant)** : Pages et composants pour les commerçants.
  - `choose_commerce.dart` : Sélection du commerce actif (si plusieurs).
  - `create_item_page.dart` : Création d’un produit et génération de son QR code.

- **[components](dime_flutter/lib/view/components)** : En-têtes et barres de navigation.
  - `header_client.dart`
  - `header_commercant.dart`
  - `nav_bar_client.dart`
  - `nav_bar_commercant.dart`

- **[fenetre](dime_flutter/lib/view/fenetre)** : Encadrés et widgets réutilisables.
  - `fav_commerce_fenetre.dart`
  - `fav_item_fenetre.dart`

---

### 📂 [Répertoire _vm_](dime_flutter/lib/vm) — *ViewModel*

Chaque fichier du répertoire [view](dime_flutter/lib/view) possède un fichier correspondant dans ce répertoire (relation **1-to-1**).

Fichiers supplémentaires dans la racine :
- **`current_connected_account_vm.dart`** : Simule la connexion d’un compte (client ou commerçant).
- **`current_store.dart`** : Simule la présence d’un client dans un commerce.
- **`favorite_product_vm.dart`** : Récupère les produits favoris du client connecté.
- **`favorite_store_vm.dart`** : Récupère les commerces favoris du client connecté.
- **`store_picker.dart`** : Change le commerce actif côté client (outil temporaire pour le développement).  