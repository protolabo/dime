# Études préliminaires

## Analyse du problème

### Décrire le problème à résoudre.

Faire l'épicerie est une activité essentielle du quotidien. Pour vivre, chacun doit se nourrir, entretenir son hygiène 
et subvenir à ses besoins de base. Or, ces actions ont un coût, et bien souvent, les consommateurs n'ont pas une connaissance 
précise des produits qu'ils achètent.

Il arrive qu’une personne achète un article :
- sans en connaitre les caractéristiques ou la qualité,
- sans savoir qu'il est disponible à un meilleur prix ailleurs,
- sans être informée des alternatives similaires et moins couteuses.




Ces situations mènent à des dépenses inutiles ou à des choix de consommation sous-optimaux.

Le but de Dime est d’accompagner les utilisateurs dans leurs achats en leur fournissant instantanément des informations utiles 
sur les produits, comme :
- une description claire et précise,
- le prix dans d'autres commerces à proximité,
- potentiellement des recommandations ou alertes sur de meilleures options.

## Exigences

### Exigences fonctionnelles
- Permettre de scanner des codes barres des articles et d'accéder à une page selon l'article
- Une description pour chaque article
- Les prix dans les commerces à proximité
- Peut savoir les commerces à proximité qui possède le produit.
- Doit pouvoir marcher pour les produits des petits commerces
- Possibilité de rajouter un produit dans le système s'il ne se retrouve pas. (Je ne suis pas 100% sûr de celui-ci)
- Possibilité de faire un compte "Acheteur" ou "Commerce", car beaucoup de petits commerces ne possèdent pas de sites web. Ils pourront inclure les produits qu'ils ont en stock facilement.


### Exigences non fonctionnelles
- Frontend avec Flutter
- Backend avec Express.js
- Doit marcher sur Android et IOS
- Pouvoir utiliser un API qui possède déjà une banque de produits (s'il existe)
- Possibilité d'alertes selon les allergènes de l'utilisateur.
- Priorité sur les commerces locaux que sur les grandes marques.
- Écrire des avis sur le produit.
- Doit posséder un mode hors-connexion pour scanner les articles, sans WIFI.


## Recherche de solutions

Toutes les applications nommées sont similaires à ce qui Dime va être. Elles sont toutes disponibles sur Android et IOS.

### [Yuka](https://yuka.io/)


### [ShopSavvy](https://shopsavvy.com/about)

L'application permet de scanner les produits, voir les prix de l'article en ligne, l'historique du prix de l'article et de ces promotions.
On peut laisser des revues sur l'article et l'application donnent des suggestions pour l'article en question. On peut aussi chercher un article avec une barre de recherche.
Si un produit nous intéresse, on peut "regarder" le produit et l'application donnera une notification s'il y a un changement de prix.

Par compte, le design de l'application laisse à désirer. Il est très facile de rendre cela plus attrayant pour les utilisateurs

### Barcode Scanner

## Méthodologie

