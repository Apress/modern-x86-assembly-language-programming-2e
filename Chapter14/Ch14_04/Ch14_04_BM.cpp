//------------------------------------------------
//               Ch14_04_BM.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include "Ch14_04.h"
#include "AlignedMem.h"
#include "BmThreadTimer.h"
#include "ImageMatrix.h"
#include "OS.h"

using namespace std;

void Avx512CalcImageStats_BM(void)
{
    OS::SetThreadAffinityMask();
    cout << "\nRunning benchmark function Avx512CalcImageStats_BM - please wait\n";

    const wchar_t* image_fn = L"..\\Ch14_Data\\TestImage4.bmp";

    ImageStats is1, is2;
    ImageMatrix im(image_fn);
    uint64_t num_pixels = im.GetNumPixels();
    uint8_t* pb = im.GetPixelBuffer<uint8_t>();

    is1.m_PixelBuffer = pb;
    is1.m_NumPixels = num_pixels;
    is1.m_PixelValMin = c_PixelValMin;
    is1.m_PixelValMax = c_PixelValMax;

    is2.m_PixelBuffer = pb;
    is2.m_NumPixels = num_pixels;
    is2.m_PixelValMin = c_PixelValMin;
    is2.m_PixelValMax = c_PixelValMax;

    const size_t num_it = 500;
    const size_t num_alg = 2;
    BmThreadTimer bmtt(num_it, num_alg);

    for (size_t i = 0; i < num_it; i++)
    {
        bmtt.Start(i, 0);
        Avx512CalcImageStatsCpp(is1);
        bmtt.Stop(i, 0);

        bmtt.Start(i, 1);
        Avx512CalcImageStats_(is2);
        bmtt.Stop(i, 1);
    }

    string fn = bmtt.BuildCsvFilenameString("Ch14_04_Avx512CalcImageStats_BM");
    bmtt.SaveElapsedTimes(fn, BmThreadTimer::EtUnit::MicroSec, 2);
    cout << "Benchmark times save to file " << fn << '\n';
}
