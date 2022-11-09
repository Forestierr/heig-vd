//
// Created by robin on 09.11.2022.
//

#ifndef EXERCICE_7_1_POINT_H
#define EXERCICE_7_1_POINT_H


class Point {
public :
    Point (float pX, float pY) : x(pX), y(pY) {}
    void deplacer (float pX, float pY);
    void afficher ();
private :
    float x;
    float y;
};

#endif //EXERCICE_7_1_POINT_H
