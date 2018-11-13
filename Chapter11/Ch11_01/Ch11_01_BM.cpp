//------------------------------------------------
//               Ch11_01_BM.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include <memory>
#include "Ch11_01.h"
#include "BmThreadTimer.h"
#include "OS.h"

using namespace std;

void Convolve1_BM(void)
{
    OS::SetThreadAffinityMask();
    cout << "\nRunning benchmark function Convolve1_BM - please wait\n";

    const int n1 = 2000000;
    const float kernel[] { 0.0625f, 0.25f, 0.375f, 0.25f, 0.0625f };
    const int ks = sizeof(kernel) / sizeof(float);
    const int ks2 = ks / 2;
    const int n2 = n1 + ks2 * 2;

    unique_ptr<float[]> x1_up {new float[n1]};
    unique_ptr<float[]> x2_up {new float[n2]};
    float* x1 = x1_up.get();
    float* x2 = x2_up.get();

    CreateSignal(x1, n1, ks, g_RngSeedVal);
    PadSignal(x2, n2, x1, n1, ks2);

    const int num_pts = n1;
    unique_ptr<float[]> y1_up {new float[num_pts]};
    unique_ptr<float[]> y2_up {new float[num_pts]};
    unique_ptr<float[]> y3_up {new float[num_pts]};
    unique_ptr<float[]> y4_up {new float[num_pts]};
    float* y1 = y1_up.get();
    float* y2 = y2_up.get();
    float* y3 = y3_up.get();
    float* y4 = y4_up.get();

    const size_t num_it = 500;
    const size_t num_alg = 4;
    BmThreadTimer bmtt(num_it, num_alg);

    for (size_t i = 0; i < num_it; i++)
    {
        bmtt.Start(i, 0);
        Convolve1Cpp(y1, x2, num_pts, kernel, ks);
        bmtt.Stop(i, 0);

        bmtt.Start(i, 1);
        Convolve1_(y2, x2, num_pts, kernel, ks);
        bmtt.Stop(i, 1);

        bmtt.Start(i, 2);
        Convolve1Ks5Cpp(y3, x2, num_pts, kernel, ks);
        bmtt.Stop(i, 2);

        bmtt.Start(i, 3);
        Convolve1Ks5_(y4, x2, num_pts, kernel, ks);
        bmtt.Stop(i, 3);
    }

    string fn = bmtt.BuildCsvFilenameString("Ch11_01_Convolve1_BM");
    bmtt.SaveElapsedTimes(fn, BmThreadTimer::EtUnit::MicroSec, 2);
    cout << "Benchmark times save to file " << fn << '\n';
}
