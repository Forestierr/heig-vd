/*
 * exercice_1.4
 * main.cpp
 *
 * But : Programme demandant des entrée à l'utilisateur et calcule son année de naissance.
 *
 * Robin Forestier 2022
 */
#include <iostream>
#include <string>

using namespace std;

string prenom;
int age;
int annee_naissance;

int main() {
    cout << "Entrer votre prenom : " << endl;
    getline(cin, prenom);
    cout << "Entrer votre age : " << endl;
    cin >> age;
    annee_naissance = 2022 - age;

    cout << "Bonjour " + prenom << "," << endl;
    cout << "Vous avez " << age << " ans et vous êtes ne(e) en " << annee_naissance << "." << endl;
    return 0;
}
