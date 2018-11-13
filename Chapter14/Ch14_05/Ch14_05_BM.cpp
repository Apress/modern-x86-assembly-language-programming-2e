//------------------------------------------------
//               Ch14_05_BM.cpp
//------------------------------------------------

#include "stdafx.h"
#include <string>
#include <iostream>
#include <iomanip>
#include "Ch14_05.h"
#include "ImageMatrix.h"
#include "BmThreadTimer.h"
#include "OS.h"

using namespace std;
                    
void Avx512RgbToGs_BM()
{
    OS::SetThreadAffinityMask();
    cout << "\nRunning benchmark function Avx512RgbToGs_BM - please wait\n";

    const wchar_t* fn_rgb = L"..\\Ch14_Data\\TestImage3.bmp";

    ImageMatrix im_rgb(fn_rgb);
    int im_h = im_rgb.GetHeight();
    int im_w = im_rgb.GetWidth();
    int num_pixels = im_h * im_w;
    ImageMatrix im_r(im_h, im_w, PixelType::Gray8);
    ImageMatrix im_g(im_h, im_w, PixelType::Gray8);
    ImageMatrix im_b(im_h, im_w, PixelType::Gray8);
    RGB32* pb_rgb = im_rgb.GetPixelBuffer<RGB32>();
    uint8_t* pb_r = im_r.GetPixelBuffer<uint8_t>();
    uint8_t* pb_g = im_g.GetPixelBuffer<uint8_t>();
    uint8_t* pb_b = im_b.GetPixelBuffer<uint8_t>();
    uint8_t* pb_rgb_cp[3] {pb_r, pb_g, pb_b};

    for (int i = 0; i < num_pixels; i++)
    {
        pb_rgb_cp[0][i] = pb_rgb[i].m_R;
        pb_rgb_cp[1][i] = pb_rgb[i].m_G;
        pb_rgb_cp[2][i] = pb_rgb[i].m_B;
    }

    ImageMatrix im_gs1(im_h, im_w, PixelType::Gray8);
    ImageMatrix im_gs2(im_h, im_w, PixelType::Gray8);
    ImageMatrix im_gs3(im_h, im_w, PixelType::Gray8);
    uint8_t* pb_gs1 = im_gs1.GetPixelBuffer<uint8_t>();
    uint8_t* pb_gs2 = im_gs2.GetPixelBuffer<uint8_t>();
    uint8_t* pb_gs3 = im_gs3.GetPixelBuffer<uint8_t>();

    const size_t num_it = 500;
    const size_t num_alg = 3;
    BmThreadTimer bmtt(num_it, num_alg);

    for (size_t i = 0; i < num_it; i++)
    {
        bmtt.Start(i, 0);
        Avx512RgbToGsCpp(pb_gs1, pb_rgb_cp, num_pixels, c_Coef);
        bmtt.Stop(i, 0);

        bmtt.Start(i, 1);
        Avx512RgbToGs_(pb_gs2, pb_rgb_cp, num_pixels, c_Coef);
        bmtt.Stop(i, 1);

        bmtt.Start(i, 2);
        Avx2RgbToGs_(pb_gs3, pb_rgb_cp, num_pixels, c_Coef);
        bmtt.Stop(i, 2);
    }

    string fn = bmtt.BuildCsvFilenameString("Ch14_05_Avx512RgbToGs_BM");
    bmtt.SaveElapsedTimes(fn, BmThreadTimer::EtUnit::MicroSec, 2);
    cout << "Benchmark times save to file " << fn << '\n';
}
