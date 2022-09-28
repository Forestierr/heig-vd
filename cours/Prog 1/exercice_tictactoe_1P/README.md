# 1 Player Tic Tac Toe

## 2 Player

## 1 Player easy

## 1 Player hard

### Min Max algorithms

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