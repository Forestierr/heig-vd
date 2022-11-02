#include <iostream>
#include <cstdlib>
#include <iomanip>
#include <time.h>

using namespace std;

int main() {

    const int N_ITERATIONS = 1000000;

    double aleatoire, x, y, pi;

    int number = 0;

    srand (time(NULL));

    for (int i = 0; i < N_ITERATIONS; i++) {
        aleatoire = rand() * 1.0 / RAND_MAX;
        x = -1 + 2 * aleatoire;
        aleatoire = rand() * 1.0 / RAND_MAX;
        y = -1 + 2 * aleatoire;

        if (x*x + y*y <= 1)
        {
            number ++;
        }
    }

    pi = 4 * number / N_ITERATIONS;

    cout << "estimation de Pi : " << fixed << setprecision(2) << pi << endl;

    return 0;
}
