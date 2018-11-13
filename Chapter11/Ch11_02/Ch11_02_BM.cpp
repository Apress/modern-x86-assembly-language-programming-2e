//------------------------------------------------
//               Ch11_02_BM.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include "Ch11_02.h"
#include "AlignedMem.h"
#include "BmThreadTimer.h"
#include "OS.h"

using namespace std;

void Convolve2_BM(void)
{
    OS::SetThreadAffinityMask();
    cout << "\nRunning benchmark function Convolve2_BM - please wait\n";

    const int n1 = 2000000;
    const float kernel[] { 0.0625f, 0.25f, 0.375f, 0.25f, 0.0625f };
    const int ks = sizeof(kernel) / sizeof(float);
    const int ks2 = ks / 2;
    const int n2 = n1 + ks2 * 2;
    const unsigned int alignment = 32;

    // Create signal array
    AlignedArray<float> x1_aa(n1, alignment);
    AlignedArray<float> x2_aa(n2, alignment);
    float* x1 = x1_aa.Data();
    float* x2 = x2_aa.Data();

    CreateSignal(x1, n1, ks, g_RngSeedVal);
    PadSignal(x2, n2, x1, n1, ks2);

    // Perform convolutions
    AlignedArray<float> y5_aa(n1, alignment);
    AlignedArray<float> y6_aa(n1, alignment);
    AlignedArray<float> y7_aa(n1, alignment);
    float* y5 = y5_aa.Data();
    float* y6 = y6_aa.Data();
    float* y7 = y7_aa.Data();

    const size_t num_it = 500;
    const size_t num_alg = 3;
    BmThreadTimer bmtt(num_it, num_alg);

    for (size_t i = 0; i < num_it; i++)
    {
        bmtt.Start(i, 0);
        Convolve2_(y5, x2, n1, kernel, ks);
        bmtt.Stop(i, 0);

        bmtt.Start(i, 1);
        Convolve2Ks5_(y6, x2, n1, kernel, ks);
        bmtt.Stop(i, 1);

        bmtt.Start(i, 2);
        Convolve2Ks5Test_(y7, x2, n1, kernel, ks);
        bmtt.Stop(i, 2);
    }

    string fn = bmtt.BuildCsvFilenameString("Ch11_02_Convolve2_BM");
    bmtt.SaveElapsedTimes(fn, BmThreadTimer::EtUnit::MicroSec, 2);
    cout << "Benchmark times save to file " << fn << '\n';
}
