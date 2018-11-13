//------------------------------------------------
//               Ch07_06_Misc.cpp
//------------------------------------------------

#include "stdafx.h"
#include <cstdint>
#include <iostream>
#include <iomanip>

using namespace std;

uint32_t ConvertImgVerify(const float* src1, const float* src2, uint32_t num_pixels)
{
    uint32_t num_diff = 0;

    for (uint32_t i = 0; i < num_pixels; i++)
    {
        if (src1[i] != src2[i])
        {
            cout << fixed << setprecision(8) << i << ", " << src1[i] << ", " << src2[i] << '\n';
            num_diff++;
        }
    }

    return num_diff;
}

uint32_t ConvertImgVerify(const uint8_t* src1, const uint8_t* src2, uint32_t num_pixels)
{
    uint32_t num_diff = 0;

    for (uint32_t i = 0; i < num_pixels; i++)
    {
        // Pixels values are allowed to differ by 1 to account for
        // slight variations in FP arithmetic
        if (abs((int)src1[i] - (int)src2[i]) > 1)
        {
            cout << i << ", " << src1[i] << ", " << src2[i] << '\n';
            num_diff++;
        }
    }

    return num_diff;
}
