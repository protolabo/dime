# Projet IFT3150: Dime

> **Thèmes**: Science de données, Génie logiciel  
> **Superviseur**: Lafontant, Louis Edouard  
> **Collaborateurs:** N/A

## Informations Générales
Le présent projet constitue une suite et une amélioration du système
Dime, initialement développé par De-Webertho Dieudonné et Patrick
Symenouh. Ce travail vise à enrichir la plateforme existante, en consolidant
son architecture et en introduisant de nouvelles fonctionnalités adaptées aux
besoins des commerçants et des utilisateurs. Les détails des améliorations
proposées seront précisés plus tard dans la description détaillé du projet.

## Équipe

- Ben Amor, Hazem (20236062)

## Description du projet

### Contexte
Le projet Dime s’inscrit dans la tendance de la numérisation du com-
merce de détail, où de nombreux petits commerces peinent encore à rivaliser
avec les grandes chaînes disposant d’infrastructures numériques avancées.
Une première version du système a été développée afin de répondre à ce be-
soin, en offrant une plateforme permettant d’explorer des produits via des
étiquettes numériques et des codes QR. Ce travail constitue une continuité de
ces efforts, visant à renforcer l’architecture logicielle et à enrichir l’expérience
utilisateur.

### Problématique ou motivations

Bien que l’application existante fournisse une base fonctionnelle, elle pré-
sente certaines limites qui freinent son évolution et son adoption à grande
échelle. En effet, la dépendance exclusive à Supabase pour la gestion des
requêtes et du traitement des données limite la flexibilité du système. De
plus, plusieurs fonctionnalités essentielles ne sont pas encore intégrées, no-
tamment l’authentification des employés, la gestion des images et l’optimisa-
tion de l’expérience utilisateur. Ainsi, il est nécessaire de mettre en place une
architecture plus robuste, notamment à travers l’intégration d’un backend
dédié, permettant de mieux structurer et valider les échanges de données,
tout en offrant une marge de manœuvre accrue pour l’évolution future de
l’application.

### Proposition et objectifs

Le présent travail vise à consolider la solution existante et atteindre les
objectifs suivants :

1. Mettre en place un backend afin de mieux structurer et valider le trai-
tement des requêtes actuellement gérées exclusivement par Supabase.
2. Intégrer un serveur backend basé sur Express, amorcé dans une version
   initiale.
3. Mettre en place l’intégration de Cloudflare pour assurer une gestion
   sécurisée et optimisée des images.
4. Implémenter une fonctionnalité de scan de code-barres dédiée aux
   commerçants.
5. Mettre en œuvre un système d’authentification et de gestion des
   employés.
6. Améliorer l’interface utilisateur et l’expérience utilisateur (UI/UX ) afin
   de rendre l’application plus intuitive et accessible.

### Méthodologie
La planification du projet s’étend sur 12 semaines et se divise en plusieurs
étapes :

## Échéancier

!!! info
    Le suivi complet est disponible dans la page [Suivi de projet](suivi.md).

| Jalon (*Milestone*)                                                      | Date prévue  | Tache                                                                  | Statut    |
|--------------------------------------------------------------------------|--------------|------------------------------------------------------------------------|-----------|
| Ouverture de projet                                                      | 11 Septembre | Proposition de projet                                                  | ✅ Terminé |
| Analyse des exigences                                                    | 18 Septembre | Document d'analyse                                                     | ✅ Terminé |
| Prototype                                                                | 25 Septembre | Diagramme C4                                                           | ✅ Terminé |
| Mise en place du backend (1)                                             | 2 Octobre    | Structuration du serveur avec Express                                  | ✅ Terminé |
| Mise en place du backend (2)                                             | 9 Octobre    | Mise en place de la communication entre le backend et le frontend      | ⏳ À venir |
| Intégration de Cloudflare / Tests                                        | 16 Octobre   | Configuration pour la gestion et l’optimisation des images produits    | ⏳ À venir|
| Implémentation du scan de code-barres (1)                                | 23 Octobre   | Intégration du scanner dans l’application mobile                       | ⏳ À venir |
| Implémentation du scan de code-barres (2)                                | 30 Octobre   | Intégration du scanner dans l’application mobile                       | ⏳ À venir |
| Implémentation d’authentification et du gestion des employés / Tests (1) | 6 Novembre   | Mise en place d’un système d’inscription/connexion sécurisé            | ⏳ À venir |
| Implémentation d’authentification et du gestion des employés / Tests (2) | 13 Novembre  | Mise en place d’un système d’inscription/connexion sécurisé            | ⏳ À venir |
| Amélioration du UI/UX                                                    | 20 Novembre  | Révision de l’interface utilisateur pour une navigation plus intuitive | ⏳ À venir |
| Amélioration du UI/UX                                                    | 27 Novembre  | Révision de l’interface utilisateur pour une navigation plus intuitive | ⏳ À venir |
| Rapport                                                                  | 4 Décembre   | Intégration des résultats et préparation de la remise                  | ⏳ À venir |
| Présentation + Rapport                                                   | 11 Décembre  | Présentation                                                | ⏳ À venir |
