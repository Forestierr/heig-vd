#include <iostream>
using namespace std;

#include "Point.h"

int main()
{
    Point p(0, 0);
    p.afficher();
    p.deplacer(3, 5);
    p.afficher();

    return EXIT_SUCCESS;
}
