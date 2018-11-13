//------------------------------------------------
//               Ch13_08_BM.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include <iomanip>
#include "Ch13_08.h"
#include "AlignedMem.h"
#include "BmThreadTimer.h"
#include "OS.h"

using namespace std;

void Avx512MatVecMulF32_BM(void)
{
    OS::SetThreadAffinityMask();
    cout << "\nRunning benchmark function Avx512MatVecMulF32_BM - please wait\n";

    const size_t num_vec = 1000000;

    alignas(64) float mat[4][4]
    {
       10.0, 11.0, 12.0, 13.0,
       20.0, 21.0, 22.0, 23.0,
       30.0, 31.0, 32.0, 33.0,
       40.0, 41.0, 42.0, 43.0
    };

    AlignedArray<Vec4x1_F32> vec_a_aa(num_vec, 64);
    AlignedArray<Vec4x1_F32> vec_b1_aa(num_vec, 64);
    AlignedArray<Vec4x1_F32> vec_b2_aa(num_vec, 64);

    Vec4x1_F32* vec_a = vec_a_aa.Data();
    Vec4x1_F32* vec_b1 = vec_b1_aa.Data();
    Vec4x1_F32* vec_b2 = vec_b2_aa.Data();

    InitVecArray(vec_a, num_vec);

    const size_t num_it = 500;
    const size_t num_alg = 2;
    BmThreadTimer bmtt(num_it, num_alg);

    for (size_t i = 0; i < num_it; i++)
    {
        bmtt.Start(i, 0);
        Avx512MatVecMulF32Cpp(vec_b1, mat, vec_a, num_vec);
        bmtt.Stop(i, 0);

        bmtt.Start(i, 1);
        Avx512MatVecMulF32_(vec_b2, mat, vec_a, num_vec);
        bmtt.Stop(i, 1);
    }

    string fn = bmtt.BuildCsvFilenameString("Ch13_08_Avx512MatVecMulF32_BM");
    bmtt.SaveElapsedTimes(fn, BmThreadTimer::EtUnit::MicroSec, 2);
    cout << "Benchmark times save to file " << fn << '\n';
}
