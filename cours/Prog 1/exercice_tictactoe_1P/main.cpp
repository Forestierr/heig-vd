/*
 * exercice_tictactoe_1P
 * main.cpp
 * author: Robin Forestier
 * 29.09.2022
 * Explications : Jeu du tic tac toe, 1 ou 2 joueurs.
 *                Quand le jeu ce lance, vous pouvez choisir entre 2 joueur ou 1 joueurs (easy) / 1 joueur (hard) pas implémenter.
 *                Puis antrer un chiffre 0 à 8 pour celectionner la place ou vous voulez jouer.
 *
 * https://xkcd.com/832/
 */

#include <iostream>

using namespace std;

/*
 * win : Vérifie si quelle qu'un a gagné
 * @param board[9] : tableau contenant les infos du jeux
 * @param player : caractère du joueur (X ou O)
 * @return true if win else false
 */
bool win(char board[9], char player)
{
    // check les lignes
    for(int i = 0;i < 9;i += 3)
    {
        if (board[i] == board[i + 1] && board[i] == board[i + 2] && board[i] == player) {
            return true;
        }
    }
    // check les colones
    for(int i = 0;i < 3;i ++)
    {
        if (board[i] == board[i + 3] && board[i] == board[i + 6] && board[i] == player)
        {
            return true;
        }
    }
    // check les diagonales
    if (board[0] == board[4] && board[0] == board[8] && board[0] == player)
    {
        return true;
    }
    else if (board[2] == board[4] && board[2] == board[6] && board[2] == player)
    {
        return true;
    }

    return false;
}

/*
 * checkEmpty : vérifie si la place ou le joueur veux jouer est libre.
 * @param place : place ou le joueur veux jouer
 * @param board[9] : tableau contenant les infos du jeux
 * @return true si libre, sinon false
 */
bool checkEmpty(char place, char board[9])
{
    return board[place] == '.';
}

/*
 * draw : dessine dans le terminal
 * @param board[9] : tableau contenant les infos du jeux
 * @param player : caractère du joueur (X ou O)
 */
void draw(char board[9], char player)
{
    for (int i = 0; i < 9; i++)
    {
        cout << " " << board[i];
        if (i == 2 || i == 5)
        {
            cout << "\n---+---+---\n";
        }
        else if(i != 8)
        {
            cout << " |";
        }
    }
    cout << "\n\nC'est aux joueur : " << player << " de jouer !" << endl;
}

int evaluate(char board[9])
{
    if (win(board, 'X'))
    {
        return -10;
    }
    else if (win(board, 'O'))
    {
        return +10;
    }
    else
    {
        return 0;
    }
}

// This function returns true if there are moves
// remaining on the board. It returns false if
// there are no moves left to play.
bool isMovesLeft(char board[9])
{
    for (int i = 0; i<9; i++)
        if (board[i]=='.')
            return true;
    return false;
}

// This is the minimax function. It considers all
// the possible ways the game can go and returns
// the value of the board
int minimax(char board[9], int depth, bool isMax)
{
    int score = evaluate(board);

    // If Maximizer has won the game return his/her
    // evaluated score
    if (score == 10)
        return score;

    // If Minimizer has won the game return his/her
    // evaluated score
    if (score == -10)
        return score;

    // If there are no more moves and no winner then
    // it is a tie
    if (isMovesLeft(board)==false)
        return 0;

    // If this maximizer's move
    if (isMax)
    {
        int best = -1000;

        // Traverse all cells
        for (int i = 0; i<9; i++)
        {
            // Check if cell is empty
            if (board[i]=='.')
            {
                // Make the move
                board[i] = 'O';

                // Call minimax recursively and choose
                // the maximum value
                best = max(best, minimax(board, depth+1, !isMax));

                // Undo the move
                board[i] = '.';
            }
        }
        return best;
    }

        // If this minimizer's move
    else
    {
        int best = 1000;

        // Traverse all cells
        for (int i = 0; i<9; i++)
        {
            // Check if cell is empty
            if (board[i]=='.')
            {
                // Make the move
                board[i] = 'X';

                // Call minimax recursively and choose
                // the minimum value
                best = min(best, minimax(board, depth+1, !isMax));

                // Undo the move
                board[i] = '.';
            }
        }
        return best;
    }
}

// This will return the best possible move for the player
int findBestMove(char board[9])
{
    int bestVal = -1000;
    int move = 0;

    // Traverse all cells, evaluate minimax function for
    // all empty cells. And return the cell with optimal
    // value.
    for (int i = 0; i<9; i++)
    {
        // Check if cell is empty
        if (board[i]=='.')
        {
            // Make the move
            board[i] = 'O';

            // compute evaluation function for this
            // move.
            int moveVal = minimax(board, 0, false);

            // Undo the move
            board[i] = '.';

            // If the value of the current move is
            // more than the best value, then update
            // best/
            if (moveVal > bestVal)
            {
                move = i;
                bestVal = moveVal;
            }
        }
    }
    return move;
}

int main() {
    // initialisation des variables
    char player = 'X';
    int numberOfPlay = 0;
    int place = 0;
    char board[9] = {'.', '.', '.','.', '.', '.','.', '.', '.'};

    int gameType = 1;

    cout << "Voulez-vous jouer :\n"
            " 1) contre un autre joueur ?\n"
            " 2) contre l'ordinateur (easy) \n"
            " 3) contre l'ordinateur (hard) \n";

    cin >> gameType;

    // Règles du jeux
    cout << "Regle du jeux :\n  Pour jouer, entrer chacun votre tour une nombre de 0 a 8.\n"
            "  O etant le coin en haut a gauche et 8 le coin en bas a droite.\n"
            "  Puis presser sur ENTER.\n\n";

    // boucle infinie
    while(1)
    {
        // dessine la grille
        draw(board, player);
        // lit l'entrée du joueur
        if(gameType == 1 || (gameType == 2 || gameType == 3) && player == 'X')
        {
            cin >> place;
        }
        else if(gameType == 2 && player == 'O') {
            do {
                place = rand() % 9;
            }while (!checkEmpty(place, board));
        }
        else if(gameType == 3 && player == 'O')
        {
            place = findBestMove(board);
        }

        // si la place est libre
        if (checkEmpty(place, board))
        {
            // remplace le caractère du joueur dans la grille
            board[place] = player;

            // regarder si le joueur gagne
            if(win(board, player))
            {
                // GAGNÉ
                cout << "Le joueur : " << player << " a gagne !" << endl;
                break;
            }
                // pas encore gagné
            else
            {
                // changement de joueur
                if(player == 'X')
                {
                    player = 'O';
                }
                else {
                    player = 'X';
                }

                // ajoute 1 aux nombre de coup joué
                numberOfPlay ++;

                // vérifier si il y a encore de la place sur la grille
                if(numberOfPlay == 9)
                {
                    cout << "Egalite !!!" << endl;
                    break;
                }
            }
        }
        // Emplacement déjà occupé
        else
        {
            system("cls");
            cout << "Cette position est deja prise !" << endl;
        }
    }
    // dessine la dernière grille.
    for (int i = 0; i < 9; i++)
    {
        cout << board[i] << "  ";
        if (i == 2 || i == 5 || i == 8)
        {
            cout << "\n";
        }
    }
    return 0;
}
