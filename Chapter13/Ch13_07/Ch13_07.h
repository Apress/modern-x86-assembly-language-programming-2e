//------------------------------------------------
//               Ch13_07.h
//------------------------------------------------

#pragma once

// Simple vector structure
typedef struct
{
    double X;        // Vector X component
    double Y;        // Vector Y component
    double Z;        // Vector Z component
} Vector;

// Vector structure of arrays
typedef struct
{
    double* X;       // Pointer to X components
    double* Y;       // Pointer to Y components
    double* Z;       // Pointer to Z components
} VectorSoA;

// Ch13_07.cpp
void InitVec(Vector* a_aos, Vector* b_aos, VectorSoA& a_soa, VectorSoA& b_soa, size_t num_vec);
bool Avx512VcpAosCpp(Vector* c, const Vector* a, const Vector* b, size_t num_vec);
bool Avx512VcpSoaCpp(VectorSoA* c, const VectorSoA* a, const VectorSoA* b, size_t num_vec);

// Ch13_07_.asm
extern "C" bool Avx512VcpAos_(Vector* c, const Vector* a, const Vector* b, size_t num_vec);
extern "C" bool Avx512VcpSoa_(VectorSoA* c, const VectorSoA* a, const VectorSoA* b, size_t num_vec);

// Ch13_07_BM.cpp
extern void Avx512Vcp_BM(void);
