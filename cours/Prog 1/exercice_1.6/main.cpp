#include <iostream>

using namespace std;

int main() {

    float solde; // solde de départ sur le compt
    float taux_interet; // taux d'intéret par année
    float retrait; // retrait d'argent chaque mois
    int nombre_mois(0); // nombre de mois

    cout << "Quelle est le solde de votre compt (Chf) ? " << endl;
    cin >> solde;
    cout << "Quelle est votre taux d'interet annuel (%) ?" << endl;
    cin >> taux_interet;
    cout << "Combient voulez-vous retirer chaque mois (Chf) ?" << endl;
    cin >> retrait;

    while (solde >= 0) {
        solde -= retrait;
        if (nombre_mois % 12 == 0 && nombre_mois != 0){
            solde += solde / 100 * taux_interet;
        }
        nombre_mois += 1;
    }

    cout << "\nVous serrez a decouvert apres : " << nombre_mois << " mois. " << endl;

    return 0;
}
