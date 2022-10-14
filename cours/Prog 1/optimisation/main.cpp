#include <iostream>
#include <windows.h>

using namespace std;
/*
The different color codes are

https://dev.to/tenry/terminal-colors-in-c-c-3dgc
https://cplusplus.com/forum/beginner/54360/

0   BLACK
1   BLUE
2   GREEN
3   CYAN
4   RED
5   MAGENTA
6   BROWN
7   LIGHTGRAY
8   DARKGRAY
9   LIGHTBLUE
10  LIGHTGREEN
11  LIGHTCYAN
12  LIGHTRED
13  LIGHTMAGENTA
14  YELLOW
15  WHITE
*/

int main(void) {

    HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);

    SetConsoleTextAttribute(hConsole, FOREGROUND_RED);
    printf("red text\n");

    SetConsoleTextAttribute(hConsole, FOREGROUND_RED | FOREGROUND_GREEN | BACKGROUND_BLUE);
    printf("yellow on blue\n");


    for (int i = 0; i <= 15; i++) {
        SetConsoleTextAttribute(hConsole, i);
        cout << "test" << endl;
    }


    for (int j = 0; j <= 255; j += 16) {
        SetConsoleTextAttribute(hConsole, j);
        cout << " ";
    }

    cout << endl;

    for (int j = 0; j <= 255; j ++) {
        SetConsoleTextAttribute(hConsole, j);
        cout << "X";
    }

    return 0;
}