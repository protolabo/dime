# Conception

## Architecture

L’architecture repose sur trois couches : mobile, serveur et base de données. L’application mobile, conçue avec Flutter (Dart), offre l’interface utilisateur et communique via HTTP avec le backend.
<br><br>

**Diagramme des composants** *(Dernière mise à jour : 04-jun-2025)* ![Diagramme des composants](images/Components.png)
Le backend, développé en Node.js avec Express.js :

- gère la logique métier,
- sécurise les échanges,
- interagit avec la base de données et le stockage d’images.

MongoDB est utilisé pour les données structurées (produits, utilisateurs, etc.).
Les fichiers image sont stockés séparément (fichier local ou cloud), avec un lien (URL) conservé en base. Les formats pris en charge incluent PNG et JPEG, avec un éventuel redimensionnement côté backend pour optimiser le chargement sur mobile.

Cette architecture sépare bien les responsabilités, permet d’évoluer facilement, reste simple et adaptée aux besoins du projet Dime.

## Choix technologiques

- Justifier les technologies et outils choisis.

## Modèles et diagrammes
**Diagramme entité-relation** *(Dernière mise à jour : 21-jun-2025)* ![Diagramme entité-relation](images/Entity%20relationship.png)

## Prototype
[Lien Figma du prototype](https://www.figma.com/design/j39w8enj4lyx9PlnpdWOzb/Dime?node-id=0-1&t=R44g9gxVfHPhjDI2-1)



- Inclure des diagrammes UML, maquettes, etc.
