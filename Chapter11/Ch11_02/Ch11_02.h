//------------------------------------------------
//               Ch11_02.h
//------------------------------------------------

#pragma once

// Ch11_02_Misc.cpp
extern void CreateSignal(float* x, int n, int kernel_size, unsigned int seed);
extern void PadSignal(float* x2, int n2, const float* x1, int n1, int ks2);
extern unsigned int g_RngSeedVal;

// Ch11_02_.asm
extern "C" bool Convolve2_(float* y, const float* x, int num_pts, const float* kernel, int kernel_size);
extern "C" bool Convolve2Ks5_(float* y, const float* x, int num_pts, const float* kernel, int kernel_size);

// Ch11_02_Test_.asm
extern "C" bool Convolve2Ks5Test_(float* y, const float* x, int num_pts, const float* kernel, int kernel_size);

// Ch11_02_BM.cpp
extern void Convolve2_BM(void);
