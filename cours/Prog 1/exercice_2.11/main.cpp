#include <iostream>
#include <iomanip>

using namespace std;

int main()
{
    const double PI = 3.141592;
    double r1, h1, r2, h2, h3;
    double volume = 0;

    cout << "entrer le rayon du premier cylindre r1 (cm) : ";
    cin >> r1;
    cout << "entrer le rayon du deuxieme cylindre r2 (cm) : ";
    cin >> r2;
    cout << "entrer la hauteur du premier cylindre h1 (cm) : ";
    cin >> h1;
    cout << "entrer la hauteur du deuxieme cylindre h2 (cm) : ";
    cin >> h2;
    cout << "entrer la hauteur du cone h3 (cm) : ";
    cin >> h3;

    // volumes des deux cylindre
    volume = PI * r1 * r1 * h1;
    volume += PI * r2 * r2 * h2;
    // volume du cone
    volume += PI * (r1 * r1 + r1 * r2 + r2 * r2) * h3 / 3;

    // 1 lites = 1000cm3
    double litre = volume / 1000;

    cout << "\nLa bouteille peut contenir " << fixed << setprecision(1) << litre << " litre.";
    return 0;
}