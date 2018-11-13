//------------------------------------------------
//               Ch13_09.h
//------------------------------------------------

#pragma once

// Ch13_09_Misc.cpp
extern void CreateSignal(float* x, int n, int kernel_size, unsigned int seed);
extern void PadSignal(float* x2, int n2, const float* x1, int n1, int ks2);
extern unsigned int g_RngSeedVal;

// Ch13_09_.asm
extern "C" bool Avx512Convolve2_(float* y, const float* x, int num_pts, const float* kernel, int kernel_size);
extern "C" bool Avx512Convolve2Ks5_(float* y, const float* x, int num_pts, const float* kernel, int kernel_size);

// Ch13_00_BM.cpp
extern void Avx512Convolve2_BM(void);
