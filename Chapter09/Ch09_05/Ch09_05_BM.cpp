//------------------------------------------------
//               Ch09_05_BM.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include "Ch09_05.h"
#include "Matrix.h"
#include "BmThreadTimer.h"
#include "OS.h"

using namespace std;

extern void AvxMat4x4TransposeF64_BM(void)
{
    OS::SetThreadAffinityMask();
    cout << "\nRunning benchmark function AvxMat4x4TransposeF64_BM - please wait\n";

    const size_t num_rows = 4;
    const size_t num_cols = 4;
    Matrix<double> m_src1(num_rows, num_cols);
    Matrix<double> m_des1(num_rows, num_cols);
    Matrix<double> m_des2(num_rows, num_cols);

    const double m_src1_r0[] = { 10, 11, 12, 13 };
    const double m_src1_r1[] = { 14, 15, 16, 17 };
    const double m_src1_r2[] = { 18, 19, 20, 21 };
    const double m_src1_r3[] = { 22, 23, 24, 25 };

    m_src1.SetRow(0, m_src1_r0);
    m_src1.SetRow(1, m_src1_r1);
    m_src1.SetRow(2, m_src1_r2);
    m_src1.SetRow(3, m_src1_r3);

    const size_t num_it = 500;
    const size_t num_alg = 2;
    const size_t num_ops = 1000000;

    BmThreadTimer bmtt(num_it, num_alg);

    for (size_t i = 0; i < num_it; i++)
    {
        bmtt.Start(i, 0);
        for (size_t j = 0; j < num_ops; j++)
            Matrix<double>::Transpose(m_des1, m_src1);
        bmtt.Stop(i, 0);

        bmtt.Start(i, 1);
        for (size_t j = 0; j < num_ops; j++)
            AvxMat4x4TransposeF64_(m_des2.Data(), m_src1.Data());
        bmtt.Stop(i, 1);
    }

    string fn = bmtt.BuildCsvFilenameString("Ch09_05_AvxMat4x4TransposeF64_BM");
    bmtt.SaveElapsedTimes(fn, BmThreadTimer::EtUnit::MicroSec, 2);
    cout << "Benchmark times save to file " << fn << '\n';
}

void AvxMat4x4MulF64_BM(void)
{
    OS::SetThreadAffinityMask();
    cout << "\nRunning benchmark function AvxMat4x4MulF64_BM - please wait\n";

    const size_t num_rows = 4;
    const size_t num_cols = 4;
    Matrix<double> m_src1(num_rows, num_cols);
    Matrix<double> m_src2(num_rows, num_cols);
    Matrix<double> m_des1(num_rows, num_cols);
    Matrix<double> m_des2(num_rows, num_cols);

    const double m_src1_r0[] = { 10, 11, 12, 13 };
    const double m_src1_r1[] = { 14, 15, 16, 17 };
    const double m_src1_r2[] = { 18, 19, 20, 21 };
    const double m_src1_r3[] = { 22, 23, 24, 25 };
    const double m_src2_r0[] = { 0, 1, 2, 3 };
    const double m_src2_r1[] = { 4, 5, 6, 7 };
    const double m_src2_r2[] = { 8, 9, 10, 11 };
    const double m_src2_r3[] = { 12, 13, 14, 15 };

    m_src1.SetRow(0, m_src1_r0);
    m_src1.SetRow(1, m_src1_r1);
    m_src1.SetRow(2, m_src1_r2);
    m_src1.SetRow(3, m_src1_r3);
    m_src2.SetRow(0, m_src2_r0);
    m_src2.SetRow(1, m_src2_r1);
    m_src2.SetRow(2, m_src2_r2);
    m_src2.SetRow(3, m_src2_r3);

    const size_t num_it = 500;
    const size_t num_alg = 2;
    const size_t num_ops = 1000000;

    BmThreadTimer bmtt(num_it, num_alg);

    for (size_t i = 0; i < num_it; i++)
    {
        bmtt.Start(i, 0);
        for (size_t j = 0; j < num_ops; j++)
            Matrix<double>::Mul(m_des1, m_src1, m_src2);
        bmtt.Stop(i, 0);

        bmtt.Start(i, 1);
        for (size_t j = 0; j < num_ops; j++)
            AvxMat4x4MulF64_(m_des2.Data(), m_src1.Data(), m_src2.Data());
        bmtt.Stop(i, 1);
    }

    string fn = bmtt.BuildCsvFilenameString("Ch09_05_AvxMat4x4MulF64_BM");
    bmtt.SaveElapsedTimes(fn, BmThreadTimer::EtUnit::MicroSec, 6);
    cout << "Benchmark times save to file " << fn << '\n';
}
