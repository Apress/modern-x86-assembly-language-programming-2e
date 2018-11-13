//------------------------------------------------
//               Ch07_05_BM.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include "Ch07_05.h"
#include "AlignedMem.h"
#include "BmThreadTimer.h"
#include "OS.h"

using namespace std;

void AvxCalcMeanU8_BM(void)
{
    OS::SetThreadAffinityMask();
    cout << "\nRunning benchmark function AvxCalcMeanU8_BM - please wait\n";

    size_t n = c_NumElements;
    AlignedArray<uint8_t> x_aa(n, 16);
    uint8_t* x = x_aa.Data();

    Init(x, n, c_RngSeedVal);

    const size_t num_it = 500;
    const size_t num_alg = 2;
    BmThreadTimer bmtt(num_it, num_alg);

    for (size_t i = 0; i < num_it; i++)
    {
        int64_t sum0 = -1, sum1 = -1;
        double mean0 = -1, mean1 = -1;

        bmtt.Start(i, 0);
        AvxCalcMeanU8Cpp(x, n, &sum0, &mean0);
        bmtt.Stop(i, 0);

        bmtt.Start(i, 1);
        AvxCalcMeanU8_(x, n, &sum1, &mean1);
        bmtt.Stop(i, 1);
    }

    string fn = bmtt.BuildCsvFilenameString("Ch07_05_AvxCalcMeanU8_BM");
    bmtt.SaveElapsedTimes(fn, BmThreadTimer::EtUnit::MicroSec, 2);
    cout << "Benchmark times save to file " << fn << '\n';
}
