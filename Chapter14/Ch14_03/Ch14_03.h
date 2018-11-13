//------------------------------------------------
//               Ch14_03.h
//------------------------------------------------

#pragma once
#include <cstdint>

// Compare operators
enum CmpOp { EQ, NE, LT, LE, GT, GE };

// Ch14_03_Misc.cpp
extern void Init(uint8_t* x, size_t n, unsigned int seed);
extern void ShowResults(const uint8_t* des1, const uint8_t* des2, size_t num_pixels, CmpOp cmp_op,
    uint8_t cmp_val, size_t test_id);

// Ch14_03_.asm
extern "C" bool Avx512ComparePixels_(uint8_t* des, const uint8_t* src, size_t num_pixels,
    CmpOp cmp_op, uint8_t cmp_val);

