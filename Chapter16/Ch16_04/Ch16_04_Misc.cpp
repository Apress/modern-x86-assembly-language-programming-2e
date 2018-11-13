//------------------------------------------------
//               Ch16_04_Misc.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include <random>
#include <memory.h>
#include <cmath>
#include <mutex>
#include <vector>
#include <algorithm>
#include "Ch16_04.h"

using namespace std;

void Init(double* a1, double* a2, size_t n, unsigned int seed)
{
    uniform_int_distribution<> ui_dist {1, 2000};
    default_random_engine rng {seed};

    for (size_t i = 0; i < n; i++)
    {
        a1[i] = (double)ui_dist(rng);
        a2[i] = (double)ui_dist(rng);
    }
}

size_t CompareResults(const double* a, const double* b, size_t n)
{
    if (memcmp(a, b, n * sizeof(double)) == 0)
        return n;

    const double epsilon = 1.0e-15;

    for (size_t i = 0; i < n; i++)
    {
        if (fabs(a[i] - b[i]) > epsilon)
            return i;
    }

    return n;
}

void DisplayThreadMsg(const CalcInfo* ci, const CoutInfo* cout_info, const char* msg)
{
    static mutex mutex_cout;
    static const char nl = '\n';

    mutex_cout.lock();
    cout << nl << msg << nl;
    cout << "  m_Iteration:   " << cout_info->m_Iteration << nl;
    cout << "  m_NumElements: " << cout_info->m_NumElements << nl;
    cout << "  m_ThreadId:    " << cout_info->m_ThreadId << nl;
    cout << "  m_NumThreads:  " << cout_info->m_NumThreads << nl;
    cout << "  m_Index0:      " << ci->m_Index0 << nl;
    cout << "  m_Index1:      " << ci->m_Index1 << nl;
    mutex_cout.unlock();
}

vector<size_t> GetNumElementsVec(size_t* num_elements_max)
{
//    vector<size_t> ne_vec {64, 192, 384, 512};      // Requires 32GB + extra
    vector<size_t> ne_vec {64, 128, 192, 256};      // Requires 16GB + extra
//    vector<size_t> ne_vec {64, 96, 128, 160};       // Requires 10GB + extra

    size_t mem_size_extra_gb = 2;       // Used to avoid allocating all available mem

    size_t ne_max = *std::max_element(ne_vec.begin(), ne_vec.end());

    if ((ne_max % c_BlockSize) != 0)
        throw runtime_error("ne_max must be an integer multiple of c_BlockSize");

    size_t mem_size;

    if (!GetAvailableMemory(&mem_size))
        throw runtime_error ("GetAvailableMemory failed");

    size_t mem_size_gb = mem_size / (1024 * 1024 * 1024);
    size_t mem_size_min = ne_max * 1024 * 1024 * c_ElementSize * c_NumArrays;
    size_t mem_size_min_gb = mem_size_min / (1024 * 1024 * 1024);

    if (mem_size_gb < mem_size_min_gb + mem_size_extra_gb)
        throw runtime_error ("Not enough available memory");

    *num_elements_max = ne_max * 1024 * 1024;
    return ne_vec;
}

vector<size_t> GetNumThreadsVec(void)
{
    vector<size_t> num_threads_vec {1, 2, 4, 6, 8};

    return num_threads_vec;
}
