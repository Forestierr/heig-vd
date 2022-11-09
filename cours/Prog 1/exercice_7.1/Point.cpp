//
// Created by robin on 09.11.2022.
//
#include <iostream>
#include "Point.h"

using namespace std;

void Point::deplacer (float pX, float pY) {
    this->x += pX;
    this->y += pY;
}

void Point::afficher ()
{
    cout << "x, y : " << x << ", " << y << endl;
}