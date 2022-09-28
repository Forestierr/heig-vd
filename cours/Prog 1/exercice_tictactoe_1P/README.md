# 1 Player Tic Tac Toe

## 2 Player

Pour le mode 2 player, chacun joue quand son symbole apparait.

Pour indiquer la position de jeu :

0 | 1 | 2
--+---+--
3 | 4 | 5
--+---+--
6 | 7 | 8

## 1 Player easy

Le mode 1 player easy, est un mode ou l'ordinateur joue aléatoirement.

## 1 Player hard

### Min Max algorithms

> Non implémenter !

https://fr.wikipedia.org/wiki/Algorithme_minimax

Pseudo code de l'algorithms (Wikipedia article) :
```
function minimax(node, depth, maximizingPlayer) is
    if depth = 0 or node is a terminal node then
        return the heuristic value of node
    if maximizingPlayer then
        value := −∞
        for each child of node do
            value := max(value, minimax(child, depth − 1, FALSE))
    else (* minimizing player *)
        value := +∞
        for each child of node do
            value := min(value, minimax(child, depth − 1, TRUE))
    return value
```

Ou alpha beta :

https://fr.wikipedia.org/wiki/Élagage_alpha-bêta

```
fonction alphabeta(nœud, α, β) /* α < β */
   si nœud est une feuille alors
       retourner la valeur de nœud
   sinon
       v = -∞
       pour tout fils de nœud faire
           v = max(v, -alphabeta(fils, -β, -α))     
           si v ≥ β alors
               retourner v
           α = max(α, v)
       retourner v
```

## Solution
![](tic_tac_toe.png)

https://xkcd.com/832/
