# Études préliminaires

## Analyse du problème

### Décrire le problème à résoudre.

Le projet Dime vise à accompagner les consommateurs dans leurs achats en leur fournissant des informations instantanées sur les produits, telles que le prix dans les magasins à proximité et les alternatives. L'application dépend actuellement de Supabase, ce qui complique la gestion et la validation des données au fur et à mesure que les fonctionnalités s'étoffent. Un backend plus robuste est nécessaire pour améliorer la performance et la sécurité.

De plus, des fonctionnalités essentielles pour les commerçants, comme le scan de codes-barres pour l'ajout de produits et la gestion des employés, ne sont pas encore intégrées. L'interface utilisateur pourrait aussi être améliorée pour une meilleure expérience. Ces lacunes limitent l'utilité de Dime pour les commerces locaux et l'attrait pour les utilisateurs. Les améliorations proposées ont pour but de renforcer la fondation technique de l'application et d'y ajouter des fonctionnalités clés pour en faire un outil plus puissant, fiable et convivial.

---

## Exigences

### Exigences fonctionnelles

- **Mettre en place un backend robuste** avec Express.js pour une meilleure structuration et validation des requêtes, réduisant la dépendance à Supabase.
- **Implémenter le scan de codes-barres** pour les commerçants, afin de simplifier l'ajout et la gestion des produits en stock.
- **Implémenter un système d'authentification et de gestion des employés** pour les comptes "Commerce", permettant aux propriétaires de magasins d'attribuer et de gérer des accès.
- **Intégrer Cloudflare** pour optimiser la gestion des images et améliorer la performance.

### Exigences non fonctionnelles

- Le backend doit être développé avec **Express.js**.
- L'application doit fonctionner sur **Android et iOS**.
- Le design et l'interface utilisateur (**UI/UX**) doivent être améliorés pour une expérience plus fluide.
- L'application doit pouvoir scanner des produits sans connexion réseau (mode hors-connexion).

---

## Recherche de solutions

Toutes les applications mentionnées sont similaires à ce que Dime vise à devenir.

### [eezly](https://www.eezly.com/fr/)
Permet de scanner un code-barre, comparer les prix de milliers de produits entre les grandes bannières au Québec (Maxi, Super C, Metro, Provigo, ...).
On peut créer une liste d’épicerie et voir le coût total selon les magasins.

### [reebee](https://apps.apple.com/ca/app/reebee-circulaires-et-rabais/id558297215?l=fr-CA)
Permet de parcourir les circulaires (flyers), créer des listes d’épicerie, comparer certaines offres/promos, et voir les deals dans les magasins locaux.

### [Open Food Facts](https://play.google.com/store/apps/details?id=org.openfoodfacts.scanner)
Base de données collaborative de produits alimentaires. Permet de scanner les produits pour obtenir des informations sur leur composition, leur Nutri-Score et leur Eco-Score.

---

## Méthodologie

Le développement sera mené par itération, en priorisant les améliorations techniques et fonctionnelles.

1.  **Backend Express.js** : La première phase consistera à finaliser l'architecture du backend avec Express.js pour une meilleure gestion des données et une plus grande sécurité.
2.  **Gestion des employés et authentification** : La deuxième itération se concentrera sur la mise en place du système d'authentification des employés pour les commerçants.
3.  **Scan de codes-barres pour les commerçants** : La fonctionnalité de scan de codes-barres sera développée pour simplifier l'ajout des produits.
4.  **Intégration de Cloudflare** : Cloudflare sera intégré pour optimiser la gestion des images et la performance globale de l'application.
5.  **Amélioration de l'UI/UX** : L'interface utilisateur sera continuellement améliorée pour offrir une expérience plus intuitive et agréable aux utilisateurs et aux commerçants.