#include <iostream>
#include <vector>

using namespace std;

void bubbleSort(vector<int>& v) {
    if (!v.empty()) {
        for (size_t i = 0; i < v.size() - 1; ++i) {
            for (size_t j = 1; j < v.size() - i; ++j) {
                if (v[j - 1] > v[j])
                swap(v[j - 1], v[j]); // permutation
            }
            for (int n : v)
            cout << n << ' ';
            cout << endl;
        }
    }
}


int main() {
    vector<int> v{9, 5, 2, 6, 7, 3, 4, 1, 8};
    bubbleSort(v);
    for (int n : v)
    cout << n << ' '; // 1 2 3 4 5 6 7 8 9
}