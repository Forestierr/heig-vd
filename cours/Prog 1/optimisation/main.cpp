#include <iostream>
#include <chrono>

int test() {
    //
}

int main(void) {
    auto start = std::chrono::steady_clock::now();
    std::cout << "f(42) = " << test() << '\n';
    auto end = std::chrono::steady_clock::now();
    std::chrono::duration<double> elapsed_seconds = end-start;
    std::cout << "elapsed time: " << elapsed_seconds.count() << "s\n";
    return 0;
}