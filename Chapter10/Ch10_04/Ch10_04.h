//------------------------------------------------
//               Ch10_04.h
//------------------------------------------------

#pragma once
#include <cstdint>

// The following structure must match the structure that's declared in the file .asm file
struct ClipData
{
    uint8_t* m_Src;                 // source buffer pointer
    uint8_t* m_Des;                 // destination buffer pointer
    uint64_t m_NumPixels;           // number of pixels
    uint64_t m_NumClippedPixels;    // number of clipped pixels
    uint8_t m_ThreshLo;             // low threshold
    uint8_t m_ThreshHi;             // high threshold
};

// Functions defined in Ch10_04.cpp
extern void Init(uint8_t* x, uint64_t n, unsigned int seed);
extern bool Avx2ClipPixelsCpp(ClipData* cd);

// Functions defined in Ch10_04_.asm
extern "C" bool Avx2ClipPixels_(ClipData* cd);

// Functions defined in Ch10_04_BM.cpp
extern void Avx2ClipPixels_BM(void);
