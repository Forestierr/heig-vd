# ISD - SA2022 - TP1 

Fichier de réponses

Professeur: Carlos Peña, Stephan Robert
Assistant: Thibault Schowing

Étudiant: Robin - Forestier (en plus du nom de fichier svp)

-----------------------

#  Partie 1

-----------------------

## Exercice 1

(5 points)

1) Ecrivez un script qui génère une liste contenant un million de valeurs entières aléatoires entre 1 et 10 (y compris) et qui calcule le pourcentage de valeurs paires dans cette liste.

```
# Copiez votre code ici:

# Importation du module random. 
from random import randrange

# Générer une liste de valeurs aléatoire
listOfNumber = []

for i in range(1000000):
    listOfNumber.append(randrange(1, 11))
    
# Générer une liste / compter les valeurs paires et calculer le pourcentage de ces valeurs. 
result = sum([1 - i % 2 for i in listOfNumber])
result = result / 1000000 * 100

# Afficher le résultat
print(result, "%")
```


**Points obtenus: /5**
**Remarques:**


## Exercice 2

(10 points)

2.1) Décrivez avec vos mots et l'aide de la documentation les trois methodes décrites ci-dessus, leur différences et les fonctions utilisées. 

Réponse: 

### Solution 1

`[x**2 for x in (list(range(1, 11, 2)) + list(range(12, 21, 2)))]`

Cette première méthode réalise une élévation au carré de x `x**2` pour x dans la liste suivante.

Cette liste est créée par l'addition de deux liste.

La première `list(range(1, 11, 2))` créée une liste de nombre impaire de 1 à 9 (1 départ, 11 fin non inclut, 2 saut entre chaque nombre.)

La deuxième `list(range(12, 21, 2))` créée une liste de nombre paire de 12 à 20.

### Solution 2

`[x**2 for x in range(1, 21) if (((x <= 10) and (x % 2 != 0)) or ((x > 10) and (x % 2 == 0)))]`

Cette deuxième méthode réalise le carré de x uniquement si :

x et plus petit ou égale à 10 et qu'il n'est pas un multiple de 2 ou

x est plus grand que x et qu'il est un multiple de 2.

### Solution 3

`[x**2 for x in range(1, 11, 2)] + [x**2 for x in range(12, 21, 2)]`

Pour cette troisième méthode, on va additionner nos deux liste de résultats.

La première liste `[x**2 for x in range(1, 11, 2)]` calcule le carré des nombres impaire.

Puis la deuxième liste, `[x**2 for x in range(12, 21, 2)]` calcule le carré des nombres paire.


2.2) A partir de la liste "objets" données ci-dessous, créez une liste contenant uniquement les mots de la première liste qui contiennent la lettre "z" ou "Z".

```
# Copiez votre code ici:

listeZonly = [i for i in objets if (i[0] == "Z")] # comparez la valeur 0 de chaque mot avec le caractère Z.
print(listeZonly) # affichage

```

**Points obtenus: /5**
**Remarques:**

-----------------------

#  Partie 2

-----------------------

(5 points)


1) Pourquoi utiliser NumPy ?

Réponse: Numpy est rapide, est open source et est très utilisé actuellement.


2) Comment s'appelle (n.b. "de quel type est") l'objet "array" dans NumPy et que signifie son nom ?

Réponse: ndarray | The N-dimensional array | Le tableau à N dimensions


3) Pourquoi utiliser NumPy est-il plus rapide qu'utiliser les listes ?

Réponse: 

* NumPy arrays are stored at one continuous place in memory unlike lists, so processes can access and manipulate them very efficiently.

* This behavior is called locality of reference in computer science.

* This is the main reason why NumPy is faster than lists. Also it is optimized to work with latest CPU architectures.


4) A quelle question le code "# Question 4" ci-dessous répond-il ?

Réponse: Quelle est le type de "arr" ?  `<class 'numpy.ndarray'>`


5) Affichez la somme des deux derniers éléments du tableau

```
# Copiez votre code ici:
arr = np.array([1, 2, 3, 4, 5])

print(arr[3] + arr[4]) # si la taille ne change pas
# ou
print(arr[-1] + arr[-2])

```


**Points obtenus: /5**
**Remarques:**


-----------------------

#  Partie 3

-----------------------

(5 points)

1) Pourquoi utiliser Pandas ?

Réponse:

* Pandas nous permet d'analyser des données volumineuses et de tirer des conclusions fondées sur des théories statistiques.

* Pandas peut nettoyer des ensembles de données désordonnés et les rendre lisibles et pertinents.

2) Que peut faire pandas (d'après le tuto w3schools) ?

Réponse: Pandas vous donne des réponses sur les données. Par exemple :

* Y a-t-il une corrélation entre deux ou plusieurs colonnes ?
* Quelle est la valeur moyenne ?
* La valeur maximale ?
* La valeur minimale ?

Pandas est également capable de supprimer les lignes qui ne sont pas pertinentes ou qui contiennent des valeurs erronées, comme des valeurs vides ou NULL. C'est ce qu'on appelle le nettoyage des données.

3) Que fait l'exemple "Question 3" ci-dessous ?

Réponse: Il crée un data set (un array multi dimentionelle) appelé DataFrame. Avec comme entêt cars & passings.

4) Compléter la cellule "Question 4" pour afficher les lignes demandées. Utiliser l'attribut *loc* comme décrit dans le tutoriel. Que remarquez vous concernant l'utilisation de simples crochets ([...]) ou doubles crochets ([[x,y]]) pour extraire _une_ colonne du dataframe ? En utilisant la fonction type(), donnez le type de données retournées avec les simples crochets ([...]) ou doubles crochets ([[x,y]]).

Réponse:

* simple crochet  ([...])  <class 'pandas.core.series.Series'>
* double crochet ([[...]]) <class 'pandas.core.frame.DataFrame'>

5) Complétez le code comme demandé dans la cellule "Question 5 - exercice". Extrait du tutoriel Pandas de w3school.

```
# Copiez votre code ici:

# 1) Enlevez les données manquantes (NaN = Not a Number) et créez un nouveau dataframe appelé df_clean 
#    (n.b ne changez pas le dataframe original, n'utilisez pas *inplace=True*)
#    n'hésitez pas à utiliser "print(df_clean)" pour voir les changements, mais déplacez-le / commentez-le
#    pour ne pas encombrer l'affichage de votre cellule !

df_clean = df.dropna() # remove NaN


# 2) La ligne 26 contient une date au mauvais format. Pour cela nous allons convertir la colonne "Date".
#    Attention a bien faire cette opération sur df_clean et non sur df (modifiez par rapport au tutoriel). 
#    En cas de Warnings, vous pouvez l'ignorer.

df_clean['Date'] = pd.to_datetime(df_clean['Date'])

# 3) La valeur à la ligne 7 vous semble suspecte. Vous pouvez choisir de la remplacer par une valeur qui a plus de sense (45) 
#    ou vous pouvez simplement supprimer la ligne. Basez-vous toujours sur le tutoriel pour réaliser cette tâche. 

df_clean.loc[7, 'Duration'] = 45

# Enfin on affiche notre dataframe propre et ses infos. Décommentez les "print" pour afficher le dataframe df_clean et ses infos

print("\n\n===================== Dataframe ====================\n\n")
print(df_clean)
print("\n\n===================== Infos ====================\n\n")
print(df_clean.info()) 

```

**Points obtenus: /5**
**Remarques:**

-------------
  Partie 4
-------------

(2 points)

1) Pourquoi utiliser Matplotlib ?

Réponse: On utilise matplotlib pour la création de visualisation de données, comme des graphiques.


2) Allez regarder la gallerie des exemples de Matplotlib et regardez rapidement les 5 premières sections (jusqu'à la section "Pie and polar charts compris"). Choisissez 2 types de graphiques (Ou prenez les plus importants: Barchart, Boxplot et Scatterplot) et écrivez une courte description pour chaqu'un d'eux.

Réponse: 

* Barchart ou diagramme en bar est utilisé pour afficher une distribution de données sur un axe.

* Boxplot ou boite a moustache sont utiliser pour la comparaison de valeur. On peut aussi regarder leur variance par rapport aux autre valeurs.

* Scatterplot ou nuage de point est utilisé pour afficher des valeurs sur deux axes distincts.


**Points obtenus: /5**
**Remarques:**







