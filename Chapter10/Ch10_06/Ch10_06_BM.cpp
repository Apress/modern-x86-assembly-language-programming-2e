//------------------------------------------------
//               Ch10_06_BM.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include "Ch10_06.h"
#include "BmThreadTimer.h"
#include "OS.h"

using namespace std;

void Avx2ConvertRgbToGs_BM(void)
{
    OS::SetThreadAffinityMask();
    cout << "\nRunning benchmark function Avx2ConvertRgbToGs_BM - please wait\n";

    const wchar_t* fn_rgb = L"..\\Ch10_Data\\TestImage3.bmp";

    ImageMatrix im_rgb(fn_rgb);
    int im_h = im_rgb.GetHeight();
    int im_w = im_rgb.GetWidth();
    int num_pixels = im_h * im_w;
    ImageMatrix im_gs1(im_h, im_w, PixelType::Gray8);
    ImageMatrix im_gs2(im_h, im_w, PixelType::Gray8);
    RGB32* pb_rgb = im_rgb.GetPixelBuffer<RGB32>();
    uint8_t* pb_gs1 = im_gs1.GetPixelBuffer<uint8_t>();
    uint8_t* pb_gs2 = im_gs2.GetPixelBuffer<uint8_t>();

    const size_t num_it = 500;
    const size_t num_alg = 2;
    BmThreadTimer bmtt(num_it, num_alg);

    for (size_t i = 0; i < num_it; i++)
    {
        bmtt.Start(i, 0);
        Avx2ConvertRgbToGsCpp(pb_gs1, pb_rgb, num_pixels, c_Coef);
        bmtt.Stop(i, 0);

        bmtt.Start(i, 1);
        Avx2ConvertRgbToGs_(pb_gs2, pb_rgb, num_pixels, c_Coef);
        bmtt.Stop(i, 1);
    }

    string fn = bmtt.BuildCsvFilenameString("Ch10_06_Avx2ConvertRgbToGs_BM");
    bmtt.SaveElapsedTimes(fn, BmThreadTimer::EtUnit::MicroSec, 2);
    cout << "Benchmark times save to file " << fn << '\n';
}
