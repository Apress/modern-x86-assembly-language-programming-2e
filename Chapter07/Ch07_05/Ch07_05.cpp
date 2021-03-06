//------------------------------------------------
//               Ch07_05.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include <iomanip>
#include <random>
#include "Ch07_05.h"
#include "AlignedMem.h"

using namespace std;

extern "C" size_t g_NumElementsMax = c_NumElementsMax;  // Used in .asm code

void Init(uint8_t* x, size_t n, unsigned int seed)
{
    uniform_int_distribution<> ui_dist {0, 255};
    default_random_engine rng {seed};

    for (size_t i = 0; i < n; i++)
        x[i] = (uint8_t)ui_dist(rng);
}

bool AvxCalcMeanU8Cpp(const uint8_t* x, size_t n, int64_t* sum_x, double* mean_x)
{
    if (n == 0 || n > c_NumElementsMax)
        return false;

    if ((n % 64) != 0)
        return false;

    if (!AlignedMem::IsAligned(x, 16))
        return false;

    int64_t sum_x_temp = 0;

    for (int i = 0; i < n; i++)
        sum_x_temp += x[i];

    *sum_x = sum_x_temp;
    *mean_x = (double)sum_x_temp / n;
    return true;
}

void AvxCalcMeanU8()
{
    const size_t n = c_NumElements;
    AlignedArray<uint8_t> x_aa(n, 16);
    uint8_t* x = x_aa.Data();

    Init(x, n, c_RngSeedVal);

    bool rc1, rc2;
    int64_t sum_x1 = -1, sum_x2 = -1;
    double mean_x1 = -1, mean_x2 = -1;

    rc1 = AvxCalcMeanU8Cpp(x, n, &sum_x1, &mean_x1);
    rc2 = AvxCalcMeanU8_(x, n, &sum_x2, &mean_x2);

    cout << "\nResults for AvxCalcMeanU8\n";
    cout << fixed << setprecision(6);
    cout << "rc1: " << rc1 << "  ";
    cout << "sum_x1: " << sum_x1 << "  ";
    cout << "mean_x1: " << mean_x1 << '\n';
    cout << "rc2: " << rc2 << "  ";
    cout << "sum_x2: " << sum_x2 << "  ";
    cout << "mean_x2: " << mean_x2 << '\n';
}

int main()
{
    AvxCalcMeanU8();
    AvxCalcMeanU8_BM();
    return 0;
}
