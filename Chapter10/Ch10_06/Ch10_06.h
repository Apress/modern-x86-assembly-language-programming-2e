//------------------------------------------------
//               Ch10_06.h
//------------------------------------------------

#pragma once
#include <cstdint>
#include "ImageMatrix.h"

// Ch10_06.cpp
extern const float c_Coef[4];
extern bool Avx2ConvertRgbToGsCpp(uint8_t* pb_gs, const RGB32* pb_rgb, int num_pixels, const float coef[4]);

// Ch10_06_.asm
extern "C" bool Avx2ConvertRgbToGs_(uint8_t* pb_gs, const RGB32* pb_rgb, int num_pixels, const float coef[4]);

// Ch10_06_BM.cpp
extern void Avx2ConvertRgbToGs_BM(void);
