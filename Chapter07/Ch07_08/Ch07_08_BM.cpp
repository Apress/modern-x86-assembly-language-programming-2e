//------------------------------------------------
//               Ch07_08_BM.cpp
//------------------------------------------------

#include "stdafx.h"
#include <string>
#include <iostream>
#include "Ch07_08.h"
#include "AlignedMem.h"
#include "BmThreadTimer.h"
#include "ImageMatrix.h"
#include "OS.h"

using namespace std;

void AvxThreshold_BM(void)
{
    OS::SetThreadAffinityMask();
    cout << "\nRunning benchmark function AvxThreshold_BM - please wait\n";

    const wchar_t* fn_src = L"..\\Ch07_Data\\TestImage2.bmp";

    ImageMatrix im_src(fn_src);
    int im_h = im_src.GetHeight();
    int im_w = im_src.GetWidth();
    ImageMatrix im_mask1(im_h, im_w, PixelType::Gray8);
    ImageMatrix im_mask2(im_h, im_w, PixelType::Gray8);
    ITD itd1, itd2;

    itd1.m_PbSrc = im_src.GetPixelBuffer<uint8_t>();
    itd1.m_PbMask = im_mask1.GetPixelBuffer<uint8_t>();
    itd1.m_NumPixels = im_src.GetNumPixels();
    itd1.m_Threshold = c_TestThreshold;

    itd2.m_PbSrc = im_src.GetPixelBuffer<uint8_t>();
    itd2.m_PbMask = im_mask2.GetPixelBuffer<uint8_t>();
    itd2.m_NumPixels = im_src.GetNumPixels();
    itd2.m_Threshold = c_TestThreshold;

    const size_t num_it = 500;
    const size_t num_alg = 2;
    BmThreadTimer bmtt(num_it, num_alg);

    for (size_t i = 0; i < num_it; i++)
    {
        bmtt.Start(i, 0);
        AvxThresholdImageCpp(&itd1);
        AvxCalcImageMeanCpp(&itd1);
        bmtt.Stop(i, 0);

        bmtt.Start(i, 1);
        AvxThresholdImage_(&itd2);
        AvxCalcImageMean_(&itd2);
        bmtt.Stop(i, 1);
    }

    string fn = bmtt.BuildCsvFilenameString("Ch07_08_AvxThreshold_BM");
    bmtt.SaveElapsedTimes(fn, BmThreadTimer::EtUnit::MicroSec, 2);
    cout << "Benchmark times save to file " << fn << '\n';
}
