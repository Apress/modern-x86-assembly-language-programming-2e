//------------------------------------------------
//               Ch14_02_Misc.cpp
//------------------------------------------------

#include "stdafx.h"
#include <cstdint>
#include <iostream>
#include <iomanip>
#include "AlignedMem.h"

using namespace std;

extern "C" const uint32_t c_NumPixelsMax = 16777216;

bool Avx512ConvertImgU8ToF32Cpp(float* des, const uint8_t* src, uint32_t num_pixels)
{
    // Make sure num_pixels is valid
    if ((num_pixels == 0) || (num_pixels > c_NumPixelsMax))
        return false;
    if ((num_pixels & 0x3f) != 0)
        return false;

    // Make sure src and des are aligned to a 64-byte boundary
    if (!AlignedMem::IsAligned(src, 64))
        return false;
    if (!AlignedMem::IsAligned(des, 64))
        return false;

    // Convert the image
    const float sf = 1.0f / 255.0f;

    for (uint32_t i = 0; i < num_pixels; i++)
        des[i] = src[i] * sf;

    return true;
}

bool Avx512ConvertImgF32ToU8Cpp(uint8_t* des, const float* src, uint32_t num_pixels)
{
    // Make sure num_pixels is valid
    if ((num_pixels == 0) || (num_pixels > c_NumPixelsMax))
        return false;
    if ((num_pixels & 0x3f) != 0)
        return false;

    // Make sure src and des are aligned to a 64-byte boundary
    if (!AlignedMem::IsAligned(src, 64))
        return false;
    if (!AlignedMem::IsAligned(des, 64))
        return false;

    // Convert the image
    const float sf = 255.0f;

    for (uint32_t i = 0; i < num_pixels; i++)
    {
        if (src[i] > 1.0f)
            des[i] = 255;
        else if (src[i] < 0.0)
            des[i] = 0;
        else
            des[i] = (uint8_t)(src[i] * sf);
    }

    return true;
}

uint32_t Avx512ConvertImgVerify(const float* src1, const float* src2, uint32_t num_pixels)
{
    uint32_t num_diff = 0;

    for (uint32_t i = 0; i < num_pixels; i++)
    {
        if (src1[i] != src2[i])
        {
            cout << fixed << setprecision(8) << i << ", " << (int)src1[i] << ", " << (int)src2[i] << '\n';
            num_diff++;
        }
    }

    return num_diff;
}

uint32_t Avx512ConvertImgVerify(const uint8_t* src1, const uint8_t* src2, uint32_t num_pixels)
{
    uint32_t num_diff = 0;

    for (uint32_t i = 0; i < num_pixels; i++)
    {
        // Pixels values are allowed to differ by 1 to account for
        // slight variations in FP arithmetic
        if (abs((int)src1[i] - (int)src2[i]) > 1)
        {
            cout << i << ", " << (int)src1[i] << ", " << (int)src2[i] << '\n';
            num_diff++;
        }
    }

    return num_diff;
}
