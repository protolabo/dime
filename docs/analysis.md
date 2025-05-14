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

Toutes les applications mentionnées sont similaires à ce que Dime vise à devenir. Elles sont toutes disponibles sur Android et iOS.

### [Yuka](https://yuka.io/)

Cette application est centrée sur la qualité des produits alimentaires et cosmétiques. Après avoir scanné un produit, elle lui attribue une note sur 100 indiquant à quel point il est bon pour la santé. Une courte description explique ensuite pourquoi le produit a obtenu cette note. L’application affiche aussi les allergènes potentiels et propose des produits similaires, mais meilleurs pour la santé, si possible.

### [ShopSavvy](https://shopsavvy.com/about)

Cette application permet de scanner des produits, de consulter leur prix en ligne, leur historique de prix et les promotions passées. Les utilisateurs peuvent laisser des avis sur les articles, et l’application suggère des produits similaires. Il est aussi possible de rechercher un produit à l’aide d’une barre de recherche. Si un produit nous intéresse, on peut l’ajouter à une liste de suivi, et l’application nous enverra une notification en cas de changement de prix.

Cependant, le design de l’application laisse à désirer. Il serait facile de le rendre plus attrayant pour les utilisateurs.



## Méthodologie

Étude qualitative

