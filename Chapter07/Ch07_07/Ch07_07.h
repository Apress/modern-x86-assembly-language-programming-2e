//------------------------------------------------
//               Ch07_07.h
//------------------------------------------------

#pragma once
#include <cstdint>

// Ch07_07.cpp
extern bool AvxBuildImageHistogramCpp(uint32_t* histo, const uint8_t* pixel_buff, uint32_t num_pixels);

// Ch07_07_.asm
// Functions defined in Sse64ImageHistogram_.asm
extern "C" bool AvxBuildImageHistogram_(uint32_t* histo, const uint8_t* pixel_buff, uint32_t num_pixels);

// Ch07_07_BM.cpp
extern void AvxBuildImageHistogram_BM(void);
