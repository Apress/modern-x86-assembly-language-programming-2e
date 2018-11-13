//------------------------------------------------
//               Ch07_07_BM.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include "Ch07_07.h"
#include "AlignedMem.h"
#include "BmThreadTimer.h"
#include "ImageMatrix.h"
#include "OS.h"

using namespace std;

void AvxBuildImageHistogram_BM(void)
{
    OS::SetThreadAffinityMask();
    cout << "\nRunning benchmark function AvxBuildImageHistogram_BM - please wait\n";

    const wchar_t* image_fn = L"..\\Ch07_Data\\TestImage1.bmp";

    ImageMatrix im(image_fn);
    uint32_t num_pixels = im.GetNumPixels();
    uint8_t* pixel_buff = im.GetPixelBuffer<uint8_t>();
    AlignedArray<uint32_t> histo1_aa(256, 16);
    AlignedArray<uint32_t> histo2_aa(256, 16);
    uint32_t* histo1 = histo1_aa.Data();
    uint32_t* histo2 = histo2_aa.Data();

    const size_t num_it = 500;
    const size_t num_alg = 2;
    BmThreadTimer bmtt(num_it, num_alg);

    for (size_t i = 0; i < num_it; i++)
    {
        bmtt.Start(i, 0);
        AvxBuildImageHistogramCpp(histo1, pixel_buff, num_pixels);
        bmtt.Stop(i, 0);

        bmtt.Start(i, 1);
        AvxBuildImageHistogram_(histo2, pixel_buff, num_pixels);
        bmtt.Stop(i, 1);
    }

    string fn = bmtt.BuildCsvFilenameString("Ch07_07_AvxBuildImageHistogram_BM");
    bmtt.SaveElapsedTimes(fn, BmThreadTimer::EtUnit::MicroSec, 2);
    cout << "Benchmark times save to file " << fn << '\n';
}
