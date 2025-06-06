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
- Créer des codes QR pour les commerçants
- Rentrer le prix de plusieurs articles avec le même code QR
- Permettre de scanner des codes QR
- Le prix de chaque article lié au code QR scanné (et possiblement une courte description de l'article sera accompagnée).
- Les prix dans les commerces à proximité s'ils le possèdent.
- Possibilité de faire un compte "Acheteur" ou "Commerce", car beaucoup de petits commerces ne possèdent pas de sites web. Ils pourront inclure les produits qu'ils ont en stock facilement (Le compte "Acheteur" ne sera pas obligatoire. Par compte, celui du commerçant le sera).


### Exigences non fonctionnelles
- Frontend avec Flutter
- Backend avec Express.js
- Doit marcher sur Android et IOS
- Pouvoir utiliser un API qui possède déjà une banque de produits (s'il existe) ([Google Lens/Google Cloud Vision](https://support.google.com/websearch/thread/301813986/is-there-a-api-for-google-lens?hl=en))
- Priorité sur les commerces locaux que sur les grandes marques.
- Possibilité d'alertes selon les allergènes de l'utilisateur.
- Écrire des avis sur le produit.
- Doit posséder un mode hors-connexion pour scanner les articles, sans WIFI.


## Recherche de solutions

Toutes les applications mentionnées sont similaires à ce que Dime vise à devenir. Elles sont toutes disponibles sur Android et iOS.

### [Yuka](https://yuka.io/)

Cette application est centrée sur la qualité des produits alimentaires et cosmétiques. Après avoir scanné un produit, elle lui attribue une note sur 100 indiquant à quel point il est bon pour la santé. Une courte description explique ensuite pourquoi le produit a obtenu cette note. L’application affiche aussi les allergènes potentiels et propose des produits similaires, mais meilleurs pour la santé, si possible.

### [ShopSavvy](https://shopsavvy.com/about)

Cette application permet de scanner des produits, de consulter leur prix en ligne, leur historique de prix et les promotions passées. Les utilisateurs peuvent laisser des avis sur les articles, et l’application suggère des produits similaires. Il est aussi possible de rechercher un produit à l’aide d’une barre de recherche. Si un produit nous intéresse, on peut l’ajouter à une liste de suivi, et l’application nous enverra une notification en cas de changement de prix.

Cependant, le design de l’application laisse à désirer. Il serait facile de le rendre plus attrayant pour les utilisateurs.

### [Google Lens](https://lens.google/)

Google Lens est une application développée par Google qui permet de scanner des objets, codes-barres ou images pour obtenir rapidement des informations. Elle affiche le nom du produit, une courte description, un prix estimé et des liens pour l’acheter en ligne. Elle se distingue par sa capacité à reconnaître des éléments visuels même sans code-barres.

Bien qu’elle soit rapide, précise et souvent intégrée aux appareils Android, elle reste peu axée sur les commerces locaux, n’offre pas toujours les meilleurs prix ni de recommandations personnalisées. D’où l’intérêt d’une application comme Dime, centrée sur les besoins concrets des consommateurs au quotidien.



## Méthodologie

Développement par itération

