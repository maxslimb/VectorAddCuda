#include<stdio.h>
#include <stdlib.h>
#include<cuda.h>
#include <cassert>



__global__ void vectorAdd(int *a, int * b, int *c, int n){
	//Calculate global thread ID
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	
	if(tid < n){
		//Each thread adds a single element
		c[tid] = a[tid] + b[tid];
	}


}

__global__ void vectorAdd2(int *A, int *B, int *C, int n){
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	if(tid < n){
	
		//add easch element throught row

		for(int i= 0; i<n; i++){
		
			C[tid * n + i] = B[tid * n + i] + A[tid * n + i];
		}
	
	
	}


}

void result_check(int *a, int *b, int *c, int n){
	for(int i=0;i<n;i++){
	assert(c[i]==(a[i] + b[i]));
	}

}

int  main(){

// initialize arrays
	int *a, *b, *c;
	int n=100, size =n * sizeof(int);

//allocate memory
	a = (int *) malloc(n * sizeof(int));
	b = (int *) malloc(n*sizeof(int));
	c= (int *) malloc(n*sizeof(int));
	
// initialize values
	for(int i=0;i<n;i++)
	{	
		a[i]= rand()%100;
		b[i]=rand()%100;
		c[i]=0;
//	printf("%d ",a[i]);
	}

// intialize device arrays
	int * d_a, *d_b, *d_c;
	
// allocate device memory
	cudaMalloc(&d_a, size);
	cudaMalloc(&d_b, size);
	cudaMalloc(&d_c, size);

//copy data to device
	cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

//Number of Threads
	int numberOfThreads = 10;

//Number of Block size
	int numberblocks = n/numberOfThreads;
	
//call device function
	vectorAdd2<<<numberblocks, numberOfThreads>>>(d_a, d_b, d_c, n);

//copy data to host
	cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);

//check the result
	result_check(a, b, c, n);

	printf("Completed!");
//free all the memory
	free(a);
	free(b);
	free(c);
	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_c);

return 0;
}

