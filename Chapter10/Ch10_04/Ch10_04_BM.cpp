//------------------------------------------------
//               Ch10_04_BM.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include <limits>
#include <string>
#include "Ch10_04.h"
#include "AlignedMem.h"
#include "BmThreadTimer.h"
#include "OS.h"

using namespace std;

void Avx2ClipPixels_BM(void)
{
    OS::SetThreadAffinityMask();
    cout << "\nRunning benchmark function Avx2ClipPixels_BM - please wait\n";

    const uint8_t thresh_lo = 10;
    const uint8_t thresh_hi = 245;
    const uint64_t num_pixels = 8 * 1024 * 1024;

    AlignedArray<uint8_t> src(num_pixels, 32);
    AlignedArray<uint8_t> des1(num_pixels, 32);
    AlignedArray<uint8_t> des2(num_pixels, 32);

    Init(src.Data(), num_pixels, 157);

    ClipData cd1;
    ClipData cd2;

    cd1.m_Src = src.Data();
    cd1.m_Des = des1.Data();
    cd1.m_NumPixels = num_pixels;
    cd1.m_NumClippedPixels = numeric_limits<uint64_t>::max();
    cd1.m_ThreshLo = thresh_lo;
    cd1.m_ThreshHi = thresh_hi;

    cd2.m_Src = src.Data();
    cd2.m_Des = des2.Data();
    cd2.m_NumPixels = num_pixels;
    cd2.m_NumClippedPixels = numeric_limits<uint64_t>::max();
    cd2.m_ThreshLo = thresh_lo;
    cd2.m_ThreshHi = thresh_hi;

    const size_t num_it = 500;
    const size_t num_alg = 2;
    BmThreadTimer bmtt(num_it, num_alg);

    for (size_t i = 0; i < num_it; i++)
    {
        bmtt.Start(i, 0);
        Avx2ClipPixelsCpp(&cd1);
        bmtt.Stop(i, 0);

        bmtt.Start(i, 1);
        Avx2ClipPixels_(&cd2);
        bmtt.Stop(i, 1);
    }

    string fn = bmtt.BuildCsvFilenameString("Ch10_04_Avx2ClipPixels_BM");
    bmtt.SaveElapsedTimes(fn, BmThreadTimer::EtUnit::MicroSec, 2);
    cout << "Benchmark times save to file " << fn << '\n';
}
