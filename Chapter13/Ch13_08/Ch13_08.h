//------------------------------------------------
//               Ch13_08.h
//------------------------------------------------

#pragma once

// Simple 4x1 vector structure
struct Vec4x1_F32
{
    float W, X, Y, Z;
};

// Ch13_08.cpp
extern void InitVecArray(Vec4x1_F32* va, size_t num_vec);
extern bool Avx512MatVecMulF32Cpp(Vec4x1_F32* vec_b, float mat[4][4], Vec4x1_F32* vec_a, size_t num_vec);

// Ch13_08_.asm
extern "C" bool Avx512MatVecMulF32_(Vec4x1_F32* vec_b, float mat[4][4], Vec4x1_F32* vec_a, size_t num_vec);

// Ch13_08_BM.cpp
extern void Avx512MatVecMulF32_BM(void);
