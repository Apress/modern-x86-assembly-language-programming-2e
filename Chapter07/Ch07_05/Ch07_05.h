//------------------------------------------------
//               Ch07_05.h
//------------------------------------------------

#pragma once
#include <cstdint>

// Ch07_05.cpp
extern void Init(uint8_t* x, size_t n, unsigned int seed);
extern bool AvxCalcMeanU8Cpp(const uint8_t* x, size_t n, int64_t* sum_x, double* mean);

// Ch07_05_BM.cpp
extern void AvxCalcMeanU8_BM(void);

// Ch07_05_.asm
extern "C" bool AvxCalcMeanU8_(const uint8_t* x, size_t n, int64_t* sum_x, double* mean);

// Common constants
const size_t c_NumElements = 16 * 1024 * 1024;      // Must be multiple of 64
const size_t c_NumElementsMax = 64 * 1024 * 1024;   // Used to avoid overflows
const unsigned int c_RngSeedVal = 29;
