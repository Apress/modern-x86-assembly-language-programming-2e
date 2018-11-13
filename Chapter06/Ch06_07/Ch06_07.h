//------------------------------------------------
//               Ch06_07.h
//------------------------------------------------

#pragma once

// Ch06_07_.asm
extern "C" void AvxMat4x4TransposeF32_(float* m_des, const float* m_src);

// Ch06_07_BM.cpp
extern void AvxMat4x4TransposeF32_BM(void);
