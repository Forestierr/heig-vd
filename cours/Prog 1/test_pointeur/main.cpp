#include <iostream>

using namespace std;

int& func(int *a){
    *a = 3;
    int b = 0;
    return b;
}

void func2(){
}

int main() {
    cout << "test" << endl;
    int a = 0;
    int &b = func(&a);
    cout << "test2 : " << endl;
    cout << b << endl;
    cout << "t..." << endl;
    b = 4;
    cout << b << endl;
    func2();
    cout << b << endl;
    return 0;
}
