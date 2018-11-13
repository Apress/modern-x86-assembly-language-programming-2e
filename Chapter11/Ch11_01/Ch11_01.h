//------------------------------------------------
//               Ch11_01.h
//------------------------------------------------

#pragma once

// Ch11_01_Misc.cpp
extern void CreateSignal(float* x, int n, int kernel_size, unsigned int seed);
extern void PadSignal(float* x2, int n2, const float* x1, int n1, int ks2);
extern unsigned int g_RngSeedVal;

// Ch11_01.cpp
extern bool Convolve1Cpp(float* y, const float* x, int num_pts, const float* kernel, int kernel_size);
extern bool Convolve1Ks5Cpp(float* y, const float* x, int num_pts, const float* kernel, int kernel_size);

// Ch11_01_.asm
extern "C" bool Convolve1_(float* y, const float* x, int num_pts, const float* kernel, int kernel_size);
extern "C" bool Convolve1Ks5_(float* y, const float* x, int num_pts, const float* kernel, int kernel_size);

// Ch11_01_BM.cpp
extern void Convolve1_BM(void);
