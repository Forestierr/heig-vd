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
    if (board[place] == '.')
    {
        return true;
    }
    return false;
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
    cout << "\n\nC'est aux player : " << player << " de jouer !" << endl;
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
        if(gameType == 1 || gameType == 2 && player == 'X')
        {
            cin >> place;
        }
        else if(gameType == 2 && player == 'O')
        {
            place = rand() % 9;
        }
        else if(gameType == 3 && player == 'O')
        {
            // Min Max algo
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
