//------------------------------------------------
//               Ch16_02_BM.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include "Ch16_02.h"
#include "AlignedMem.h"
#include "BmThreadTimer.h"
#include "OS.h"

using namespace std;

void NonTemporalStore_BM(void)
{
    OS::SetThreadAffinityMask();
    cout << "\nRunning benchmark function NonTemporalStore_BM - please wait\n";

    const size_t n = 2000000;
    const size_t align = 32;

    AlignedArray<float> a_aa(n, align);
    AlignedArray<float> b_aa(n, align);
    AlignedArray<float> c1_aa(n, align);
    AlignedArray<float> c2a_aa(n, align);
    AlignedArray<float> c2b_aa(n, align);
    float* a = a_aa.Data();
    float* b = b_aa.Data();
    float* c1 = c1_aa.Data();
    float* c2a = c2a_aa.Data();
    float* c2b = c2b_aa.Data();

    Init(a, n, 67);
    Init(b, n, 79);

    const size_t num_it = 500;
    const size_t num_alg = 3;
    BmThreadTimer bmtt(num_it, num_alg);

    for (size_t i = 0; i < num_it; i++)
    {
        size_t order = i % 3;

        // Note: Order of function execution is changed each iteration to
        // obtain more accurate measurements

        if (order == 0)
        {
            bmtt.Start(i, 0);
            CalcResultCpp(c1, a, b, n);
            bmtt.Stop(i, 0);

            bmtt.Start(i, 1);
            CalcResultA_(c2a, a, b, n);
            bmtt.Stop(i, 1);

            bmtt.Start(i, 2);
            CalcResultB_(c2b, a, b, n);
            bmtt.Stop(i, 2);
        }
        else if (order == 1)
        {
            bmtt.Start(i, 1);
            CalcResultA_(c2a, a, b, n);
            bmtt.Stop(i, 1);

            bmtt.Start(i, 2);
            CalcResultB_(c2b, a, b, n);
            bmtt.Stop(i, 2);

            bmtt.Start(i, 0);
            CalcResultCpp(c1, a, b, n);
            bmtt.Stop(i, 0);
        }
        else
        {
            bmtt.Start(i, 2);
            CalcResultB_(c2b, a, b, n);
            bmtt.Stop(i, 2);

            bmtt.Start(i, 0);
            CalcResultCpp(c1, a, b, n);
            bmtt.Stop(i, 0);

            bmtt.Start(i, 1);
            CalcResultA_(c2a, a, b, n);
            bmtt.Stop(i, 1);
        }
    }

    string fn = bmtt.BuildCsvFilenameString("Ch16_02_NonTemporalStore_BM");
    bmtt.SaveElapsedTimes(fn, BmThreadTimer::EtUnit::MicroSec, 2);
    cout << "Benchmark times save to file " << fn << '\n';
}
