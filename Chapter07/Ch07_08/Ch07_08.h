//------------------------------------------------
//               Ch07_08.h
//------------------------------------------------

#pragma once
#include <cstdint>

// Image threshold data structure. This structure must agree with the
// structure that's defined in Ch07_08_.asm
struct ITD
{
    uint8_t* m_PbSrc;                 // Source image pixel buffer
    uint8_t* m_PbMask;                // Mask mask pixel buffer
    uint32_t m_NumPixels;             // Number of source image pixels
    uint32_t m_NumMaskedPixels;       // Number of masked pixels
    uint32_t m_SumMaskedPixels;       // Sum of masked pixels
    uint8_t m_Threshold;              // Image threshold value
    uint8_t m_Pad[3];                 // Available for future use
    double m_MeanMaskedPixels;        // Mean of masked pixels
};

// Functions defined in Ch07_08.cpp
extern bool AvxThresholdImageCpp(ITD* itd);
extern bool AvxCalcImageMeanCpp(ITD* itd);
extern "C" bool IsValid(uint32_t num_pixels, const uint8_t* pb_src, const uint8_t* pb_mask);

// Functions defined in Ch07_08_.asm
extern "C" bool AvxThresholdImage_(ITD* itd);
extern "C" bool AvxCalcImageMean_(ITD* itd);

// Functions defined in Ch07_08_BM.cpp
extern void AvxThreshold_BM(void);

// Miscellaneous constants
const uint8_t c_TestThreshold = 96;
