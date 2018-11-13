//------------------------------------------------
//               AlignedMem.h
//------------------------------------------------

#pragma once
#include <cstdint>
#include <malloc.h>
#include <stdexcept>

class AlignedMem
{
public:
    static void* Allocate(size_t mem_size, size_t mem_alignment)
    {
        void* p = _aligned_malloc(mem_size, mem_alignment);

        if (p == NULL)
            throw std::runtime_error("Memory allocation error: AllocateAlignedMem()");

        return p;
    }

    static void Release(void* p)
    {
        _aligned_free(p);
    }

    template <typename T> static bool IsAligned(const T* p, size_t alignment)
    {
        if (p == nullptr)
            return false;

        if (((uintptr_t)p % alignment) != 0)
            return false;

        return true;
    }
};

template <class T> class AlignedArray
{
    T* m_Data;
    size_t m_Size;

public:

    AlignedArray(void) = delete;
    AlignedArray(const AlignedArray& aa) = delete;
    AlignedArray(AlignedArray&& aa) = delete;
    AlignedArray& operator = (const AlignedArray& aa) = delete;
    AlignedArray& operator = (AlignedArray&& aa) = delete;

    AlignedArray(size_t size, size_t alignment)
    {
        m_Size = size;
        m_Data = (T*)AlignedMem::Allocate(size * sizeof(T), alignment);
    }

    ~AlignedArray()
    {
        AlignedMem::Release(m_Data);
    }

    T* Data(void)               { return m_Data; }
    size_t Size(void)           { return m_Size; }

    void Fill(T val)
    {
        for (size_t i = 0; i < m_Size; i++)
            m_Data[i] = val;
    }
};
