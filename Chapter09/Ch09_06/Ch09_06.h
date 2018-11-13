#pragma once
#include "Matrix.h"

// Functions defined in Ch09_06.cpp
extern bool Avx2Mat4x4InvF64Cpp(Matrix<double>& m_inv, const Matrix<double>& m, double epsilon, bool* is_singular);

// Functions defined in Ch09_06_.asm
extern "C" double Avx2Mat4x4TraceF64_(const double* m_src1);
extern "C" void Avx2Mat4x4MulF64_(double* m_des, const double* m_src1, const double* m_src2);
extern "C" bool Avx2Mat4x4InvF64_(double* m_inv, const double* m, double epsilon, bool* is_singular);

// Functions defined in Ch09_06_Test.cpp
extern void Avx2Mat4x4TestF64(const Matrix<double>& m1, const Matrix<double>& m2);

// Functions defined in Ch09_06_BM.cpp
extern void Avx2Mat4x4InvF64_BM(const Matrix<double>& m);
