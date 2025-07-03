# Suivi de projet

## Semaine 1

??? note "Mettre en place l'environnement"
    - [x] Lorem ipsum dolor sit amet, consectetur adipiscing elit
    - [ ] Vestibulum convallis sit amet nisi a tincidunt
        * [x] In hac habitasse platea dictumst
        * [x] In scelerisque nibh non dolor mollis congue sed et metus
        * [ ] Praesent sed risus massa
    - [ ] Aenean pretium efficitur erat, donec pharetra, ligula non scelerisque

!!! info "Notes"
    - Il est possible que nous révisions les exigences après le prototypage

!!! warning "Difficultés rencontrées"
    - Le plugin Mermaid n'était pas reconnu : confusion entre `mkdocs-mermaid2-plugin` (pip) et `mermaid2` (plugin name)
        - Résolu après nettoyage et configuration correcte dans `mkdocs.yml`

!!! abstract "Prochaines étapes"
    - Démarrer l’analyse du problème
    

---

## Semaine 2
??? note "Débuter l'analyse du problème"
    - [x] Description du problème du projet
    - [x] Écrire les exigences
        * [x] Exigence fonctionnelles
        * [x] Exigences non fonctionnelles
    - [x] Rechercher des solutions existantes du problème avec des applications deja existantes
        * [x] Yuka
        * [x] ShopSavvy
        * [ ] une 3e application
    - [ ] Citer la méthodologie du projet.


!!! abstract "Prochaines étapes"
    - Finaliser l'analyse selon la rencontre du 14 mai.
        - Corriger les exigences (si les exigences les plus importantes de la liste doit se retrouver les plus haut).
        - Trouver une 3e application pour les "solutions existantes".
        - Inclure la méthodologie du problème (Développement par itération).
    - Débuter le prototype sur Figma
        - Côté commerçant
            - Mettre en place le système de code qr pour les produits.
        - Côté client
            - Mettre en place le système de lecture du code qr et la lecture des prix d'articles.



## Semaine 3
??? note "Compléter l'étude préliminaire"
    - [x] Arranger les exigences en ordre croissant de priorité
    - [x] Citer la méthodologie du projet
    - [x] Trouver une 3e application pour la recherche de solutions existantes (Google Lens).


??? note "Débuter le prototype Figma"
    - [x] Fonctionnement général de l'application, peut importe le type de compte
        * [x] Simulation de la page **Scan** pour scanner et voir la description d'un article ou d'une étagère.
        * [x] Création de la barre de navigation avec **Settings**, **Scan** et **Recherche**
    - [x] Coté compte commerçant
        * [x] Création de la page **MyCommerce** dans la barre de navigation
        * [x] Implementation du système pour créer un nouveau code barre d'article ou d'étagère.
        * [x] Implémentation du système pour ajouter un produit dans une étagère

!!! abstract "Prochaines étapes"
    - Améliorer le prototype selon les idées énoncées lors de la rencontre du 14 mai.
         - Changer l’emplacement des icônes de la nav (MyCommerce en premier en exemple).
         - Dans MyCommerce, faire un tabulaire de shelf.
         - Indiquer les items les plus populaires pour les clients.
         - Faire attention à l’espace entre les éléments des listes pour ne pas avoir de problème lorsqu'on clique sur l'item.
         - Écrire le nom du commerce dans le header de l'application
         - Système de favori avec code barre de produit
      - Débuter les diagrammes (UML, Classes, etc.)
         
!!! info "Notes pour le futur"
    - La base de données de l'application va être centralisé
    - Le système de favori va prioriser:
    - 1) Item pareille
    - 2) Variante de l'item
    - 3) Item similaire
    - **On priorise les commerces favoris sur eux qui ne le sont pas.**




## Semaine 4
??? note "Améliorer le prototype."
    - [x] Changement d'emplacement des icônes de la barre de navigation
    - [x] Nom du commerce présent dans le header de l'application.
    - [ ] **Pour les comptes de commerçant**
        - [x] Tabulaire des étagères selon l'ordre antéchronologique de la dernière modification de l'étagère.
        - [x] Tabulaire des items selon le niveau de popularité
        - [x] Système pour scanner le code barre lors de la création d'un nouvel item.
        - [x] Création de la page d'item.
        - [x] Nouveau buton _Edit_ dans les pages d'items et d'étagères.
    - [ ] **Pour les comptes de client**
        - [x] Création de la page ** Mes Favoris**
        - [ ] Création de la page d'un item et d'un commerce


!!! abstract "Prochaines étapes"
    - Améliorer le prototype selon les idées énoncées lors de la rencontre du 28 mai
        - Garder un bouton QR code (Download/Print)
        - Pour popularité, nb de click
        - Mettre image article
        - Mettre promotion dans nav 
        - Setting mettre infos de compte
        - Personnalisée les noms de magasin
        - Ne pas se fier au client pour barre code
        - Mettre un historique 
        - Alerte bar code du client au commerçant
    - Compléter la première version de modèle de données
        


## Semaine 5
??? note "Améliorer le prototype."
    - [x] Réunir les butons "**Download QR Code**" et "**Print QR Code**" en un seul.
    - [x] Rajouter une image pour tous les articles.
    - [x] Rajouter la section "**Promotions**" pour les **comptes commerçants**.
    - [x] Personalisation des noms de commerces et d'items du côté des **comptes clients**.


??? note "Première itération du modèle de donnnées."
    - [x] _To be completed_


!!! abstract "Prochaines étapes pour le prototype"
    - Faire un niveau de connexion pour les employés du meme commerce
    - Les employés ont tous un ID et non un email. L’email est réservé pour les commerçants et clients
    - Review échelle 
    - Une promo peut affecter plusieurs items (Changer l'ordre d)
    - Mettre historique item
    - Alerte des clients vers
    - Faire système d’authentification 
    - Finalise prototype

## Semaine 6

## Semaine 7
??? note "Finition du prototype"
    - [ ] **Pour les comptes de commerçant**
        - [x] Faire la différence entre les comptes de commerçants et les comptes de ces associés.
        - [x] Création de la page "**My Team**" pour les commerçants avec lequel qu'ils peuvent voir les membres de leurs équipes et leurs activités dans l'application.
    - [ ] **Pour les comptes de client**
        - [x] Création de la page **Historic** avec lequel que les clients peuvent voir les articles qu'ils ont scannés avec l'application.
       


??? note "Amélioration du modèle de données"
    - [x] _To be completed_


!!! abstract "Début de l'implémentation (Première sprint)"
    - Le premier sprint va être plus focus sur le côté client. Chaque sprint va durer 3 semaines.
    - Pour la première semaine du premier sprint, compléter la page **Scan**, la fonction la plus importante de l'application.
    - Créer le système de code qr pour les étagères et les items.

## Semaine 8
??? note "Début de l'implémentation"
    - [x] Installation de Flutter pour le frontend ainsi que de Express.js avec Node.js pour le backend.
    - [ ] **Pour le frontend**
        - [x] Brouillon de la page **Scan**.
    - [ ] **Pour le backend**
        - [x] Installation des packages _ejs_, _qrcode_, _uuid_ et _nodemon_.
        - [x] Implémentation d'un générateur de code QR.

!!! abstract "Finir l'implémentation de la base de données"

!!! abstract "Finir la page **Scan**"
    - Faire la version propre et fonctionnelle de la page avec la caméra qui numérise les codes QR. 

## Semaine 9
??? note "Avancement de la page **Scan**"
    - [x] Tous les éléments les plus importants de la page **Scan** sont présentes et fonctionnelles:
        - [x] Header
        - [x] Caméra qui scanne les codes QR
        - [x] Navigation bar

!!! warning "Supabase est plus compliqué à utiliser qu'on le pensait être."
    - !! À compléter


!!! abstract "Améliorer la page **Scan**"
    - Faire une fenêtre translucide avec les informations du produit scannée.

## Semaine 10

## Semaine 11

## Semaine 12

## Semaine 13
