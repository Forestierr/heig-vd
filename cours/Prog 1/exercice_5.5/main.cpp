#include <iostream>
#include <iomanip>

using namespace std;

int lectureNotes(double notes[10]);
double calculMoyenne(const double notes[10], int nombreNotes);

int main() {
    double notes[10] = { };
    int nombreNotes;

    nombreNotes = lectureNotes(notes);

    if (nombreNotes == 0) {
        cout << "Moyenne non calculable car aucune note saisie !" << endl;
    }
    else {
        cout << fixed << setprecision(2) << "La moyenne des notes saisies = " << calculMoyenne(notes, nombreNotes) << endl;
    }
    return 0;
}

int lectureNotes(double notes[10])
{
    cout << "Entrez la liste de vos notes (10 notes max), 0 pour quitter : " << endl;
    double entree = 0.0;
    int nombreNotes = 0;

    do {
        cin >> entree;
        if (entree != 0)
        {
            notes[nombreNotes++] = entree;
        }
    } while (entree != 0 && nombreNotes < 10);
    return nombreNotes;
}

double calculMoyenne(const double notes[10], const int nombreNotes)
{
    double moyenne = 0.0;
    for (int i = 0; i < nombreNotes; i++)
    {
        moyenne += notes[i];
    }
    return moyenne /= nombreNotes;
}