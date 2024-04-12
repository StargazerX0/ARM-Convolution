/**
 ******************************************************************************
 * @project        : CG2028 Assignment 1 Program Template
 * @file           : main.c
 * @author         : Hou Linxin, ECE, NUS
 * @brief          : Main program body
 ******************************************************************************
 * @attention
 *
 * <h2><center>&copy; Copyright (c) 2021 STMicroelectronics.
 * All rights reserved.</center></h2>
 *
 * This software component is licensed by ST under BSD 3-Clause license,
 * the "License"; You may not use this file except in compliance with the
 * License. You may obtain a copy of the License at:
 *                        opensource.org/licenses/BSD-3-Clause
 *
 ******************************************************************************
 */

#include "stdio.h"
#include "stdlib.h"

// helper functions to get the min and max of two numbers

#define MIN(X, Y) (((X) < (Y)) ? (X) : (Y))
#define MAX(X, Y) (((X) < (Y)) ? (Y) : (X))

#define M 5 // size of signal array
#define N 5 // size of kernel array

// 1D convolution implementation in C

int* convolution_c(int h[], int x[], int lenH, int lenX, int* lenY)
{
	int nconv = lenH+lenX-1;
	(*lenY) = nconv;
	int i,j,h_start,x_start,x_end;

	int *y = (int*) calloc(nconv, sizeof(int));

    // Convolution Process
	for (i=0; i<nconv; i++)
	{
		x_start = MAX(0,i-lenH+1);
		x_end   = MIN(i+1,lenX);
		h_start = MIN(i,lenH-1);
		for(j=x_start; j<x_end; j++)
		{
			y[i] += h[h_start--]*x[j];
		}
	}
	return y;
}

// function to print an array
void printArray(int arr[], int size)
{
	printf("The result array is: {");
	for (int i = 0; i < size; ++i)
	{
		printf("%d  ", arr[i]);
	}
	printf("}\n");
}

// Necessary function to enable printf() using semihosting
extern void initialise_monitor_handles(void);

// Functions to be written
extern int* convolve(int* arg1, int* arg2, int arg3, int arg4);

int main(void)
{
	// Necessary function to enable printf() using semihosting

	initialise_monitor_handles();

	int h[M] = { 1, 1, 1, 1, 1 }; //signal array
	int x[N] = { 1, 1, 1, 1, 1 }; //kernel array
	int lenY = M+N-1;

	//call convolution.s
	printf("Output from convolution.s: \n");
	int *ys = convolve((int*)h, (int*)x, (int)M, (int)N);
	printArray(ys, lenY);

	//call convolution_c:
	printf("Output from convolution_c: \n");
	int *yc = convolution_c(h,x,M,N,&lenY);
	printArray(yc, lenY);

}
