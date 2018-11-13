#pragma once

// Functions defined in Ch09_05_BM.cpp
extern void AvxMat4x4MulF64_BM(void);
extern void AvxMat4x4TransposeF64_BM(void);

// Functions defined in Ch09_05_.asm
extern "C" void AvxMat4x4MulF64_(double* m_des, const double* m_src1, const double* m_src2);
extern "C" void AvxMat4x4TransposeF64_(double* m_des, const double* m_src1);
