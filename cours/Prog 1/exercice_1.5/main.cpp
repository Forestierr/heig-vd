#include <iostream>

using namespace std;

int main() {
    // déclaration des variables
    int distance(50); // distance en Km
    double prix_train(60.3); // prix du billet de train
    int consomation(4.2); // consoamtion de la voiture l/100 Km
    double prix_essence(2.06); // prix de l'essence
    double amortissement(0.2); // amortissement de la voiture en frs / Km

    double prix_voiture;

    // calcule du prix pour la voiture
    prix_voiture = (distance / 100) * consomation * prix_essence;
    prix_voiture += distance * amortissement;

    if (prix_voiture < prix_train)
    {
        cout << "La voiture " << prix_voiture << endl;
    }
    else
    {
        cout << "Le train" << prix_voiture << endl;
    }

    return 0;
}
