//------------------------------------------------
//               Ch13_07_BM.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include <iomanip>
#include <memory>
#include "Ch13_07.h"
#include "AlignedMem.h"
#include "BmThreadTimer.h"
#include "OS.h"

using namespace std;

void Avx512Vcp_BM(void)
{
    OS::SetThreadAffinityMask();
    cout << "\nRunning benchmark function Avx512VectorCrossProd_BM - please wait\n";

    const size_t align = 64;
    const size_t num_vec = 1000000;

    unique_ptr<Vector> a_aos_up {new Vector[num_vec] };
    unique_ptr<Vector> b_aos_up {new Vector[num_vec] };
    unique_ptr<Vector> c_aos_up {new Vector[num_vec] };
    Vector* a_aos = a_aos_up.get();
    Vector* b_aos = b_aos_up.get();
    Vector* c_aos = c_aos_up.get();

    VectorSoA a_soa, b_soa, c_soa;
    AlignedArray<double> a_soa_x_aa(num_vec, align);
    AlignedArray<double> a_soa_y_aa(num_vec, align);
    AlignedArray<double> a_soa_z_aa(num_vec, align);
    AlignedArray<double> b_soa_x_aa(num_vec, align);
    AlignedArray<double> b_soa_y_aa(num_vec, align);
    AlignedArray<double> b_soa_z_aa(num_vec, align);
    AlignedArray<double> c_soa_x_aa(num_vec, align);
    AlignedArray<double> c_soa_y_aa(num_vec, align);
    AlignedArray<double> c_soa_z_aa(num_vec, align);
    a_soa.X = a_soa_x_aa.Data();
    a_soa.Y = a_soa_y_aa.Data();
    a_soa.Z = a_soa_z_aa.Data();
    b_soa.X = b_soa_x_aa.Data();
    b_soa.Y = b_soa_y_aa.Data();
    b_soa.Z = b_soa_z_aa.Data();
    c_soa.X = c_soa_x_aa.Data();
    c_soa.Y = c_soa_y_aa.Data();
    c_soa.Z = c_soa_z_aa.Data();

    InitVec(a_aos, b_aos, a_soa, b_soa, num_vec);

    const size_t num_it = 500;
    const size_t num_alg = 2;
    BmThreadTimer bmtt(num_it, num_alg);

    for (size_t i = 0; i < num_it; i++)
    {
        bmtt.Start(i, 0);
        Avx512VcpAos_(c_aos, a_aos, b_aos, num_vec);
        bmtt.Stop(i, 0);

        bmtt.Start(i, 1);
        Avx512VcpSoa_(&c_soa, &a_soa, &b_soa, num_vec);
        bmtt.Stop(i, 1);
    }

    string fn = bmtt.BuildCsvFilenameString("Ch13_07_Avx512VectorCrossProd_BM");
    bmtt.SaveElapsedTimes(fn, BmThreadTimer::EtUnit::MicroSec, 2);
    cout << "Benchmark times save to file " << fn << '\n';
}
