#include <iostream>
#include <vector>
#include <math.h>

//Add two vectors
__global__
void add(int n, float *x, float *y){
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    for (int i = index; i < n; i += stride){
        y[i] = x[i] + y[i];
    }
}
int main(void) {
    const int N = 1 << 29;

    int blockSize = 256;
    int numBlocks = (N + blockSize - 1) / blockSize;

    std::cout << "Thrread blocks used: " << numBlocks << "\n";

    // Allocate Unified Memory -- accessible from CPU or GPU
    float *x, *y;
    cudaMallocManaged(&x, N*sizeof(float));
    cudaMallocManaged(&y, N*sizeof(float));

    //Initialize x and y arrays
    for (int i = 0; i < N; i++) {
        x[i] = 1.0f;
        y[i] = 2.0f;
    }

    int deviceID = 0;

    cudaMemPrefetchAsync((void *)x, N*sizeof(float), deviceID);
    cudaMemPrefetchAsync((void *)y, N*sizeof(float), deviceID);

    //Vector addition
    add<<<numBlocks, blockSize>>>(N, x, y);

    // Wait for GPU to finish before accessing on host
    cudaDeviceSynchronize();


//    std::cout << "Time passed: " << duration_ms.count() << " ms\n";

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