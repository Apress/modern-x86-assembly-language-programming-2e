//------------------------------------------------
//               Ch16_02.h
//------------------------------------------------

#pragma once

// Ch16_02.cpp
extern void Init(float* x, size_t n, unsigned int seed);
extern bool CalcResultCpp(float* c, const float* a, const float* b, size_t n);

// Ch16_02_.asm
extern "C" bool CalcResultA_(float* c, const float* a, const float* b, size_t n);
extern "C" bool CalcResultB_(float* c, const float* a, const float* b, size_t n);

// Ch16_02_BM.cpp
extern void NonTemporalStore_BM(void);
