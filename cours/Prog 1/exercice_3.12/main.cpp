#include <iostream>
#include <iomanip>

using namespace std;

int main() {

    double notes[4] = {0.0, 0.0, 0.0, 0.0};

    cout << "Enter 4 notes : ";
    cin >> notes[0] >> notes[1] >> notes[2] >> notes[3];

    double moyenne = (notes[0] + notes[1] + notes[2] + notes[3]) / 4;

    cout << "Moyenne = " << fixed << setprecision(1) << moyenne << " - ";

    if (moyenne < 4.0)
    {
        cout << "Insuffisant";
    }
    else if(moyenne <= 4.5)
    {
        cout << "Moyen";
    }
    else if(moyenne <= 5.0)
    {
        cout << "Bien";
    }
    else if(moyenne <= 5.5)
    {
        cout << "Très bien";
    }
    else
    {
        cout << "Excellent";
    }
    return 0;
}
