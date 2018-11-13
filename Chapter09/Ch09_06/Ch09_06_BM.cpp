//------------------------------------------------
//               Ch09_05_B6.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include "Ch09_06.h"
#include "Matrix.h"
#include "BmThreadTimer.h"
#include "OS.h"

using namespace std;

extern void Avx2Mat4x4InvF64_BM(const Matrix<double>& m)
{
    OS::SetThreadAffinityMask();
    cout << "\nRunning benchmark function Avx2Mat4x4InvF64_BM - please wait\n";

    Matrix<double> m_inv0(m.GetNumRows(), m.GetNumCols());
    Matrix<double> m_inv1(m.GetNumRows(), m.GetNumCols());

    const size_t num_it = 500;
    const size_t num_alg = 2;
    const size_t num_ops = 100000;

    BmThreadTimer bmtt(num_it, num_alg);

    for (size_t i = 0; i < num_it; i++)
    {
        bool is_singular;
        const double epsilon = 1.0e-9;

        bmtt.Start(i, 0);
        for (size_t j = 0; j < num_ops; j++)
            Avx2Mat4x4InvF64Cpp(m_inv0, m, epsilon, &is_singular);
        bmtt.Stop(i, 0);

        bmtt.Start(i, 1);
        for (size_t j = 0; j < num_ops; j++)
            Avx2Mat4x4InvF64_(m_inv1.Data(), m.Data(), epsilon, &is_singular);
        bmtt.Stop(i, 1);
    }

    string fn = bmtt.BuildCsvFilenameString("Ch09_06_Avx2Mat4x4InvF64_BM");
    bmtt.SaveElapsedTimes(fn, BmThreadTimer::EtUnit::MicroSec, 2);
    cout << "Benchmark times save to file " << fn << '\n';
}
