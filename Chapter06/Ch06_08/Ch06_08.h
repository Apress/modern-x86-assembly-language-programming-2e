//------------------------------------------------
//               Ch06_08.h
//------------------------------------------------

#pragma once

// Ch06_08_.asm
extern "C" void AvxMat4x4MulF32_(float* m_des, const float* m_src1, const float* m_src2);

// Ch06_08_BM.cpp
extern void AvxMat4x4MulF32_BM(void);
