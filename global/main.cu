#include <stdio.h>
#define M 3
#define N 3
#define P 3

__global__ void kernel(float*,float*,float*);
void random_floats(float*,int);
void print_matrix(float*,int,int);

int main(int argc,char** argv) {
  /**
   * Init all variables
   */
  int a_size      = sizeof(float)*M*N,
      b_size      = sizeof(float)*N*P,
      result_size = sizeof(float)*M*P;

  float a[]        = {1,2,3,4,5,6,7,8,9},
        b[]        = {9,8,7,6,5,4,3,2,1},
        answer[]   = {30,24,18,84,69,54,138,114,90},
        *result    = (float*)malloc(result_size),
        *d_a,
        *d_b,
        *d_result;

  /**
   * Setup device memory
   */
  cudaMalloc((void**)&d_a,a_size);
  cudaMalloc((void**)&d_b,b_size);
  cudaMalloc((void**)&d_result,result_size);
  cudaMemcpy(d_a,a,a_size,cudaMemcpyHostToDevice);
  cudaMemcpy(d_b,b,b_size,cudaMemcpyHostToDevice);

  /**
   * Start GPU
   */
  kernel<<<M,P>>>(d_a,d_b,d_result);

  /**
   * Copy results back to host
   */
  cudaMemcpy(result,d_result,sizeof(float)* M * P,cudaMemcpyDeviceToHost);

  /**
   * Print results
   */
  printf("Result: \n");
  print_matrix(result,M,P);
  printf("Expected: \n");
  print_matrix(answer,M,P);

  /**
   * Cleanup memory
   */
  cudaFree(d_a);
  cudaFree(d_b);
  cudaFree(d_result);
  free(result);
  return 0;
}

void print_matrix(float *a,int cols,int rows) {
  int i,j;
  for(i=0;i<cols;i++) {
    for(j=0;j<rows;j++)
      printf("%f ",a[i*M+j]);
    printf("\n");
  }
}

__global__ void kernel(float *a,float *b,float *result) {
  int row = blockIdx.x,
      col = threadIdx.x,
      i;

  for(result[row*M+col]=0,i=0;i<N;i++) {
    result[row*M+col] += a[row*M+i] * b[i*N+col];
  }
}

void random_floats(float* a, int size) {
  int i;
  for(i=0;i<size;i++)
    a[i] = rand() % 8 + 1; //generate a number betwee 1 and 9
}
