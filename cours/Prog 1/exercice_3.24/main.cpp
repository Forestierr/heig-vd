#include <iostream>
#include <iomanip>
#include <math.h>

using namespace std;

int main() {

    const double g = 9.81;

    int n;
    double e, h0, h, v0, v1;

    do {
        cout << "Entrer  le coefficient de rebond, (entre 0 et 1) : ";
        cin >> e;
    } while (e < 0.0 || e >= 1.0);
    do {
        cout << "Entrer  la hauteur initiale de la balle : ";
        cin >> h0;
    } while (h0 < 0);
    do {
        cout << " le nombre de rebonds : ";
        cin >> n;
    } while (n < 0);

    do {
        v0 = sqrt(2*g*h0);
        v1 = e * v0;
        h = (v1 * v1) / (2 * g);
        h0 = h;
    } while (n > 0, n --);

    cout << "La balle se trouvera a une hauteur de : " << fixed << setprecision(2) << h0 << " [m]";

    return 0;
}