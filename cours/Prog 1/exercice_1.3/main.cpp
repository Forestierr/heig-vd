#include <iostream>

using namespace std;

int main() {
    cout << "Notre système solaire est composé de 8 planètes : Mercure, Vénus, Terre, Mars, Jupiter,\n"
            "Saturne, Uranus et Neptune (dans l'ordre de leur distance au Soleil). \n" << endl;

    cout << "type        |nom      | gaz 1 | gaz 2"<< endl;
    cout << "------------+---------+-------+------" << endl;
    cout << "telluriques | Mercure | /     | /" << endl;
    cout << "telluriques | Venus   | CO2   | N2" << endl;
    cout << "telluriques | Mars    | CO2   | N2" << endl;
    cout << "telluriques | Terre   | N2    | O2" << endl;
    cout << "gazeuses    | Jupiter | H2    | He" << endl;
    cout << "gazeuses    | Saturne | H2    | He" << endl;
    cout << "gazeuses    | Uranus  | H2    | He" << endl;
    cout << "gazeuses    | Neptune | H2    | He" << endl;

    return 0;
}
