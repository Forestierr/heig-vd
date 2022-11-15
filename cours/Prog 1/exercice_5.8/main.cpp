#include <iostream>

using namespace std;

void decalageDroite(int tab[], int taille);
void decalageGauche(int tab[], int taille);

int main() {

    int taille = 5;
    int tab[5] = {0, 1, 2, 3, 4};

    decalageDroite(tab, taille);
    decalageGauche(tab, taille);

    for (int i = 0; i < taille; i++) {
        cout << tab[i];
    }

    return 0;
}

void decalageDroite(int tab[], const int taille) {
    int temp1 = tab[0];
    int temp2 = 0;

    for (int i = 0; i < taille; i++) {
        temp2 = tab[i + 1];

        if (i == taille - 1) {
            tab[0] = temp1;
        } else {
            tab[i + 1] = temp1;
        }
        temp1 = temp2;
    }
}

void decalageGauche(int tab[], const int taille) {
    int temp1 = tab[taille - 1];
    int temp2 = 0;

    for (int i = taille - 1; i >= 0; i--) {
        temp2 = tab[i - 1];
        if (i == 0) {
            tab[taille - 1] = temp1;
        } else {
            tab[i - 1] = temp1;
        }
        temp1 = temp2;
    }
}