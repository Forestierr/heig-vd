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

### Minimax algorithms

L'algorithme minimax, est un algorithme minimisant les chance de perdre.
Il va réaliser chaque possibilité de grille est y attribuer des points.
Si il gagne +10, si il perd -10 et 0 en cas d'égalité.
Grace a cela, il peut donc trouver la position avec la plus grande chance de victoire.

[Wikipedia Minimax](https://fr.wikipedia.org/wiki/Algorithme_minimax)

Pseudo code de l'algorithme (Wikipedia article) :
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

[geeksforgeeks Minimax Algorithm](https://www.geeksforgeeks.org/minimax-algorithm-in-game-theory-set-3-tic-tac-toe-ai-finding-optimal-move/)

## Solution
![](tic_tac_toe.png)

https://xkcd.com/832/
