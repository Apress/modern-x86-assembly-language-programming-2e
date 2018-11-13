//------------------------------------------------
//               Ch09_06_Test.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include <stdexcept>
#include "Ch09_06.h"
#include "Matrix.h"

using namespace std;

void Avx2Mat4x4TestF64(const Matrix<double>& m1, const Matrix<double>& m2)
{
    if (!Matrix<double>::IsConforming(m1, m2))
        throw runtime_error("Non-conforming operands - Avx2Mat4x4TestF64");

    const size_t nrows = m1.GetNumRows();
    const size_t ncols = m1.GetNumCols();

    if (nrows != 4 || ncols != 4)
        throw runtime_error("Invalid size - Avx2Mat4x4TestF64");

    Matrix<double> m3_a(nrows, ncols);
    Matrix<double> m3_b(nrows, ncols);

    Matrix<double>::Mul(m3_a, m1, m2);
    Avx2Mat4x4MulF64_(m3_b.Data(), m1.Data(), m2.Data());

    cout << "\nResults for Avx2Mat4x4TestF64\n";

    cout << "\nMatrix m3_a\n";
    cout << m3_a << endl;

    cout << "\nMatrix m3_b\n";
    cout << m3_b << endl;

    double tr_a = m1.Trace();
    double tr_b = Avx2Mat4x4TraceF64_(m1.Data());
    cout << "tr_a = " << tr_a << '\n';
    cout << "tr_b = " << tr_b << '\n';
}

void TestTrace(void)
{
    Matrix<double> m1(4, 4);
    const double m1_row0[] = { 7, 2, 19, 3 };
    const double m1_row1[] = { 8, 6, 5, 10 };
    const double m1_row2[] = { 22, 3, 1, 12 };
    const double m1_row3[] = { 13, 25, 9, 4 };
    m1.SetRow(0, m1_row0);
    m1.SetRow(1, m1_row1);
    m1.SetRow(2, m1_row2);
    m1.SetRow(3, m1_row3);

    double tr_a = m1.Trace();
    double tr_b = Avx2Mat4x4TraceF64_(m1.Data());
    cout << "tr_a = " << tr_a << '\n';
    cout << "tr_b = " << tr_b << '\n';
}
