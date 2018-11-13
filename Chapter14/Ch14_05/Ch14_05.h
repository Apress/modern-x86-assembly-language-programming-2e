//------------------------------------------------
//               Ch14_05.h
//------------------------------------------------

#pragma once
#include <cstdint>

// Ch14_05.cpp
bool Avx512RgbToGsCpp(uint8_t* pb_gs, const uint8_t* const* pb_rgb, int num_pixels, const float coef[4]);
extern const float c_Coef[3];

// Ch14_05_.asm
extern "C" bool Avx2RgbToGs_(uint8_t* pb_gs, const uint8_t* const* pb_rgb, int num_pixels, const float coef[4]);
extern "C" bool Avx512RgbToGs_(uint8_t* pb_gs, const uint8_t* const* pb_rgb, int num_pixels, const float coef[4]);

// Ch14_05_BM.cpp
extern void Avx512RgbToGs_BM(void);
