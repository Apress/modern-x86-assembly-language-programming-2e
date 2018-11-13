//------------------------------------------------
//               Ch16_04.h
//------------------------------------------------

#pragma once
#include <vector>

struct CalcInfo
{
    double* m_X1;
    double* m_X2;
    double* m_Y1;
    double* m_Y2;
    double* m_Z1;
    double* m_Z2;
    double* m_Result;
    size_t m_Index0;
    size_t m_Index1;
    int m_Status;
};

struct CoutInfo
{
    bool m_ThreadMsgEnable;
    size_t m_Iteration;
    size_t m_NumElements;
    size_t m_ThreadId;
    size_t m_NumThreads;
};

// Ch16_04_Misc.cpp
extern size_t CompareResults(const double* a, const double* b, size_t n);
extern void DisplayThreadMsg(const CalcInfo* ci, const CoutInfo* cout_info, const char* msg);
extern void Init(double* a1, double* a2, size_t n, unsigned int seed);
std::vector<size_t> GetNumElementsVec(size_t* num_elements_max);
std::vector<size_t> GetNumThreadsVec(void);

// Ch16_04_WinApi.cpp
extern bool GetAvailableMemory(size_t* mem_size);

// Ch16_04_.asm
extern "C" void CalcResult_(CalcInfo* ci);

// Miscellaneous constants
const size_t c_ElementSize = sizeof(double);

const size_t c_NumArrays = 8;   // Total number of allocated arrays
const size_t c_Align = 32;      // Alignment boundary (update Ch16_04_.asm if changed)
const size_t c_BlockSize = 8;   // Elements per iteration (update Ch16_04_.asm if changed)
