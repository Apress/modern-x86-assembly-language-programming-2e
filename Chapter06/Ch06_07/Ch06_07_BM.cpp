//------------------------------------------------
//               Ch06_07_BM.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include <string>
#include "Ch06_07.h"
#include "Matrix.h"
#include "BmThreadTimer.h"
#include "OS.h"

using namespace std;

extern void AvxMat4x4TransposeF32_BM(void)
{
    OS::SetThreadAffinityMask();
    cout << "\nRunning benchmark function AvxMat4x4TransposeF32_BM - please wait\n";

    const size_t num_rows = 4;
    const size_t num_cols = 4;
    Matrix<float> m_src(num_rows, num_cols);
    Matrix<float> m_des1(num_rows, num_cols);
    Matrix<float> m_des2(num_rows, num_cols);

    const float m_src_r0[] = { 10, 11, 12, 13 };
    const float m_src_r1[] = { 14, 15, 16, 17 };
    const float m_src_r2[] = { 18, 19, 20, 21 };
    const float m_src_r3[] = { 22, 23, 24, 25 };

    m_src.SetRow(0, m_src_r0);
    m_src.SetRow(1, m_src_r1);
    m_src.SetRow(2, m_src_r2);
    m_src.SetRow(3, m_src_r3);

    const size_t num_it = 500;
    const size_t num_alg = 2;
    const size_t num_ops = 1000000;

    BmThreadTimer bmtt(num_it, num_alg);

    for (size_t i = 0; i < num_it; i++)
    {
        bmtt.Start(i, 0);
        for (size_t j = 0; j < num_ops; j++)
            Matrix<float>::Transpose(m_des1, m_src);
        bmtt.Stop(i, 0);

        bmtt.Start(i, 1);
        for (size_t j = 0; j < num_ops; j++)
            AvxMat4x4TransposeF32_(m_des2.Data(), m_src.Data());
        bmtt.Stop(i, 1);
    }

    string fn = bmtt.BuildCsvFilenameString("Ch06_07_AvxMat4x4TransposeF32_BM");
    bmtt.SaveElapsedTimes(fn, BmThreadTimer::EtUnit::MicroSec, 2);
    cout << "Benchmark times save to file " << fn << '\n';
}
