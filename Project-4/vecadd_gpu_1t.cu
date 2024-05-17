#include <iostream>
#include <chrono>
#include <vector>
#include <math.h>

//Add two vectors
void add(int n, float *x, float *y) {
    for (int i = 0; i < n; i++) {
        y[i] = x[i] + y[i];
    }
}

int main(void) {
    const int N = 1 << 29;

    // Allocate Unified Memory -- accessible from CPU or GPU
    float *x, *y;
    cudaMallocManaged(&x, N*sizeof(float));
    cudaMallocManaged(&y, N*sizeof(float));

    //Initialize x and y arrays
    for (int i = 0; i < N; i++) {
        x[i] = 1.0f;
        y[i] = 2.0f;
    }

    //Start timer
    auto start = std::chrono::high_resolution_clock::now();

    //Vector addition
    add<<<1, 1>>>(N, x, y);

    //Stop timer
    auto stop = std::chrono::high_resolution_clock::now();

    //Calculate time passed
    std::chrono::duration<float, std::milli> duration_ms = stop - start;
    std::cout << "Time passed: " << duration_ms.count() << " ms\n";

    //Check results
    float maxError = 0.0f;
    for (int i = 0; i < N; i++) {
        maxError = fmax(maxError, fabs(y[i]-3.0f));
    }
    std::cout << "Max error: " << maxError << std::endl;

    // Free memory
    cudaFree(x);
    cudaFree(y);

    return 0;
}