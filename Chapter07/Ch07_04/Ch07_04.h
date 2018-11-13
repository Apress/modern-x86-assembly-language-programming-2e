//------------------------------------------------
//               Ch07_04.h
//------------------------------------------------

#pragma once
#include <cstdint>

// Ch07_04.cpp
extern void Init(uint8_t* x, size_t n, unsigned int seed);
extern bool AvxCalcMinMaxU8Cpp(const uint8_t* x, size_t n, uint8_t* x_min, uint8_t* x_max);

// Ch07_04_BM.cpp
extern void AvxCalcMinMaxU8_BM(void);

// Ch07_04_.asm
extern "C" bool AvxCalcMinMaxU8_(const uint8_t* x, size_t n, uint8_t* x_min, uint8_t* x_max);

// c_NumElements must be > 0 and even multiple of 64
const size_t c_NumElements = 16 * 1024 * 1024;
const unsigned int c_RngSeedVal = 23;
