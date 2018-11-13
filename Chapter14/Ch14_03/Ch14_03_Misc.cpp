//------------------------------------------------
//               Ch14_03_Misc.cpp
//------------------------------------------------

#include "stdafx.h"
#include <string>
#include <iostream>
#include <random>
#include <memory.h>
#include "Ch14_03.h"

using namespace std;

void Init(uint8_t* x, size_t n, unsigned int seed)
{
    std::uniform_int_distribution<> ui_dist {0, 255};
    std::default_random_engine rng {seed};

    for (size_t i = 0; i < n; i++)
        x[i] = (uint8_t)ui_dist(rng);
}

void ShowResults(const uint8_t* des1, const uint8_t* des2, size_t num_pixels, CmpOp cmp_op,
    uint8_t cmp_val, size_t test_id)
{
    size_t num_nz = 0;
    bool are_same = memcmp(des1, des2, num_pixels * sizeof(uint8_t)) == 0;

    const string cmp_op_strings[] {"EQ", "NE", "LT", "LE", "GT", "GE"};

    if (are_same)
    {
        for (size_t i = 0; i < num_pixels; i++)
            num_nz += (des1[i] != 0) ? 1 : 0;
    }

    cout << "\nTest #" << test_id << '\n';
    cout << "  num_pixels: " << num_pixels << '\n';
    cout << "  cmp_op:     " << cmp_op_strings[cmp_op] << '\n';
    cout << "  cmp_val:    " << (int)cmp_val << '\n';

    if (are_same)
    {
        cout << "  Pixel masks are identical\n";
        cout << "  Number of non-zero mask pixels = " << num_nz << '\n';
    }
    else
        cout << "  Pixel masks are different\n";
}
