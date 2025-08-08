# dime_flutter

Toute la partie frontend du projet se retrouve dans ce répertoire. Le projet utilise le framework Flutter, utilisé pour faire des applications multiplateformes. Dans le cas de ce projet, on l'utilise pour faire une application mobile (Android et IOS).

## Pour compiler le projet Fl

### Se diriger dans le répertoire flutter

``
cd frontend\dime_flutter
``

### Télecharger les [dépendances](#Dépendances-Flutter-utilisé-pour-le-projet)
``
flutter pub get
``

### Lancer le projet sur un cellulaire branché à ta machine ou un émulateur
``
flutter run
``

Il est possible de vérifier si l'appareil mobile est bien reconnu par Flutter avec la commande suivante:
``
flutter devices
``

Malheuresement, on ne peut seulement utiliser une appareil mobile IOS qu'avec une machine macOS (Je le sais, c'est vraiment poche).

## Dépendances Flutter utilisées pour le projet

Toutes les dépendances utilisées pour le projet se retrouve dans le fichier [pubspec.yaml](pubspec.yaml) en dessous de la section _dependecies_:

Voici une liste des dépendances utilisées et de leurs utilités: 
- cupertino_icons: Permet d'avoir des icons de style IOS
- flutter_svg: Utiliser des fichiers svg dans le projet
- mobile_scanner: Scanner de code QR
- supabase_flutter: Connecter l'application avec l'API de la base de donnée du projet, crée dans Supabase
- http: Connecté le projet Flutter avec le [backend du générateur de code QR](../../backend).
- provider: Permet de manager et de partager des states efficacement à travers l'application.
- flutter_dotenv: Utilisé le fichier .env pour les informations nécessaires à la connexion à la base de donnée Supabase. Le fichier .env devrait être placé à la [racine du projet Flutter](../dime_flutter)
- shared_preferences: Permet de créer des paires de clés (Semblable à un hashmap).


## Code de l'application

Comme tous projets Flutter, le code de l'application se retrouve dans le répertoire [lib](lib). Le projet utilise l'architecture [MVVM](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel) (Model–view–viewmodel) comme il est [suggéré dans le site officiel de Flutter](https://docs.flutter.dev/app-architecture/guide).

### [Repertoire _view_](lib/view)

Le fichier de la racine de ce répertoire, [style.dart](lib/view/styles.dart), possède la grande majorité des éléments de style de l'application (Couleurs utilisées, Taille de marge, Taille de police, ect.)

Ce répertoire est divisé en 4 autres répertoires: 
- [client](lib/view/client), Fichier pour l'interface d'un compte de client
  - [favorite_menu.dart](lib/view/client/favorite_menu.dart)
  - [item_page_customer.dart](lib/view/client/item_page_customer.dart)
  - [scan_page_client.dart](lib/view/client/scan_page_client.dart)
  - [search_page.dart](lib/view/client/search_page.dart)
  - [store_page_customer.dart](lib/view/client/store_page_customer.dart)
- [commercant](lib/view/commercant), Fichier pour l'interface d'un compte de commerçant
  - [](lib/view/commercant/choose_commerce.dart)
  - [](lib/view/commercant/create_item_page.dart)
- [components](lib/view/components), Headers et barres de navigation de l'application (Pour commerçant et client)
  - [](lib/view/components/header_client.dart)
  - [](lib/view/components/header_commercant.dart)
  - [](lib/view/components/nav_bar_client.dart)
  - [](lib/view/components/nav_bar_commercant.dart)
- [fenetre](lib/view/fenetre), Encadré utilisé dans l'application.
  - []()
  - []()


### [Repertoire _vm_](lib/vm) (view-model)


[]()