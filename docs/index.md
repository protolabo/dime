# Projet IFT3150: Dime

> **Thèmes**: Science de données, Génie logiciel  
> **Superviseur**: Lafontant, Louis Edouard  
> **Collaborateurs:** N/A

## Informations importantes

!!! info "Dates importantes"
    - **Description du projet** : 16 mai 2025
    - **Foire 1: Prototypage** : 9-13 juin 2025
    - **Foire 2: Version beta** : 14-18 juillet 2025
    - **Présentation et rapport** : 11-15 août 2025

## Équipe

- Dieudonné, De-Webertho (20262379) : Responsable de...
- Symenouh, Patrick (20190082) : Responsable de...

## Description du projet

### Contexte

De plus en plus de grands commerces commencent à s’adapter à l’ère numérique actuelle. Dans la majorité des cas, ces grandes chaînes possèdent un site web et une application mobile. Cela facilite grandement la vie de la clientèle. Ces applications digitales permettent entre autres d'avoir un aperçu des produits de la chaîne du magasin, leurs prix, une petite description des articles et plus.

Par contre, il n'existe pas seulement que des grands commerces. Parmi les 30 073 commerces de détail au Québec en 2023, **34,47 %** sont considérés comme étant des **micros commerces** avec entre 1 et 4 employés et **62,95 %** sont classés **petits commerces** avec 5 à 99 employés à leurs actifs. Un large nombre de ces commerces locaux ne possèdent pas de sites web ou d'applications mobiles pour assister leur clientèle, ce qui peut, de nos jours, les décourager à acheter local.

### Problématique ou motivations

Faire l’épicerie est une activité courante, mais qui demeure complexe pour une grande partie de la population. Les consommateurs sont souvent confrontés à un manque d’information au moment de prendre des décisions d’achat. Il n’est pas rare qu’un client achète un produit sans connaître sa qualité, ses alternatives ou son prix réel ailleurs. Cela peut engendrer des dépenses inutiles et des choix sous-optimaux.

De plus, si certaines grandes bannières offrent des outils numériques modernes pour aider les consommateurs, la majorité des petits commerces ne disposent pas des ressources techniques ou financières pour en faire autant. Ce manque de présence numérique rend difficile l'accès à leurs produits pour une clientèle pourtant de plus en plus connectée.

Dime vise à combler cet écart numérique. En offrant une plateforme simple d’utilisation, accessible aux acheteurs et aux petits commerçants, le projet permet à chacun de prendre des décisions d’achat éclairées, tout en soutenant l’économie locale.

Selon le Baromètre de la consommation responsable 2023 publié par l’UQAM, 65 % des consommateurs québécois affirment vouloir adopter des comportements d’achat plus responsables, mais mentionnent le manque d’information comme un frein majeur. Par ailleurs, un rapport de Détail Québec indique que près de 35 % des commerces de détail québécois n’ont aucune présence en ligne.

### Proposition et objectifs

Le projet Dime consiste à développer une application mobile multiplateforme permettant aux utilisateurs de scanner des produits à l’aide de codes QR afin d’obtenir instantanément des informations utiles : description, prix comparés, avis clients et recommandations alternatives.

L’application intégrera deux types de comptes distincts. Les commerçants pourront ajouter facilement leurs produits, sans nécessiter de site web, ce qui est particulièrement utile pour les petits commerces. Les acheteurs, quant à eux, auront accès aux fonctionnalités de recherche, d’analyse de produits et d’alerte (ex. allergènes).

Les objectifs concrets sont :

* Permettre la création et la lecture de codes QR associés à des articles.
* Afficher les prix d’un même produit selon les commerces locaux disponibles.
* Offrir une interface utilisateur conviviale, compatible Android et iOS.
* Offrir une interface intuitive pour l'exploration des produits sans recours à des outils externes.
* Favoriser les petits commerçants sans infrastructure numérique.
* Proposer des recommandations et avis selon les préférences de l’utilisateur.

### Méthodologie

Le développement du projet Dime s’appuiera sur une approche itérative, inspirée de la méthode agile. Le travail sera organisé en courts cycles de développement, chacun visant à livrer une version partielle mais fonctionnelle du système. Cette méthode permettra une réévaluation constante des priorités et une adaptation rapide en fonction des défis rencontrés.

L’interface de l’application sera conçue avec Flutter, afin d’assurer une compatibilité native avec les systèmes Android et iOS. Le serveur backend reposera sur le framework Express.js, et gérera l’authentification des utilisateurs, l’accès aux données produits ainsi que les requêtes liées aux commerces. Une base de données orientée documents, MongoDB, sera utilisée pour sa flexibilité et sa facilité d’intégration avec les plateformes mobiles.

Le développement se déroulera en plusieurs phases, incluant la conception, l’implémentation et les tests. Chacune de ces étapes correspond à un jalon défini dans l’échéancier du cours. Des livrables tels que les maquettes, les diagrammes de conception et les prototypes seront produits au fil du temps, selon les dates prévues. Ce découpage progressif permet d’assurer un suivi rigoureux du projet tout en maintenant une cohérence entre les besoins identifiés et la solution développée.



## Échéancier

!!! info
    Le suivi complet est disponible dans la page [Suivi de projet](suivi.md).

| Jalon (*Milestone*)            | Date prévue   | Livrable                            | Statut      |
|--------------------------------|---------------|-------------------------------------|-------------|
| Ouverture de projet            | 1 mai         | Proposition de projet               | ✅ Terminé |
| Analyse des exigences          | 16 mai        | Document d'analyse                  | ✅ Terminé |
| Prototype 1                    | 23 mai        | Maquette + Flux d'activités         | 🔄 En cours |
| Prototype 2                    | 30 mai        | Prototype finale + Flux             | 🔄 En cours |
| Architecture                   | 30 mai        | Diagramme UML ou modèle C4          | 🔄 En cours |
| Modèle de donneés              | 6 juin        | Diagramme UML ou entité-association | 🔄 En cours |
| Revue de conception            | 6 juin        | Feedback encadrant + ajustements    | ⏳ À venir  |
| Implémentation v1              | 20 juin       | Application v1                      | ⏳ À venir  |
| Implémentation v2 + tests      | 11 juillet    | Application v2 + Tests              | ⏳ À venir  |
| Implémentation v3              | 1er août      | Version finale                      | ⏳ À venir  |
| Tests                          | 11-31 juillet | Plan + Résultats intermédiaires     | ⏳ À venir  |
| Évaluation finale              | 8 août        | Analyse des résultats + Discussion  | ⏳ À venir  |
| Présentation + Rapport         | 15 août       | Présentation + Rapport              | ⏳ À venir  |
