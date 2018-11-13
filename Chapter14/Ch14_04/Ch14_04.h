//------------------------------------------------
//               Ch14_04.h
//------------------------------------------------

#pragma once
#include <cstdint>

// This structure must match the structure that's defined in Ch14_04_.asm.
struct ImageStats
{
    uint8_t* m_PixelBuffer;
    uint64_t m_NumPixels;
    uint32_t m_PixelValMin;
    uint32_t m_PixelValMax;
    uint64_t m_NumPixelsInRange;
    uint64_t m_PixelSum;
    uint64_t m_PixelSumOfSquares;
    double m_PixelMean;
    double m_PixelSd;
};

// Ch14_04.cpp
extern bool Avx512CalcImageStatsCpp(ImageStats& im_stats);

// Ch14_04_.asm
extern "C" bool Avx512CalcImageStats_(ImageStats& im_stats);

// Ch04_04_BM.cpp
extern void Avx512CalcImageStats_BM(void);

// Common constants
const uint32_t c_PixelValMin = 40;
const uint32_t c_PixelValMax = 230;
