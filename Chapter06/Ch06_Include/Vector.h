#pragma once

#include <iostream>
#include <iomanip>
#include <string>
#include <stdexcept>
#include "AlignedMem.h"

template <typename T> class Vector
{
    static const size_t c_Alignment = 64;   // Alignment for AVX, AXV2, & AVX-512

    size_t m_NumElements;
    size_t m_DataSize;
    T* m_Data;

    int m_OstreamW;
    std::string m_OstreamDelim;

    void Allocate(size_t num_elements)
    {
        m_NumElements = num_elements;
        m_DataSize = m_NumElements * sizeof(T);

        if (m_NumElements == 0)
            m_Data = nullptr;
        else
            m_Data = (T*)AlignedMem::Allocate(m_DataSize, c_Alignment);

        SetOstream(10, "  ");
    }

    void Cleanup(void)
    {
        m_NumElements = m_DataSize = 0;
        m_Data = nullptr;
    }

    void Release(void)
    {
        if (m_Data != nullptr)
            AlignedMem::Release(m_Data);

        Cleanup();
    }

public:

    Vector(void)
    {
        Allocate(0);
    }

    Vector(size_t num_elements)
    {
        Allocate(num_elements);
        Fill(0);
    }

    Vector(const Vector<T>& vec)
    {
        Allocate(vec.m_NumElements);
        memcpy(m_Data, vec.m_Data, m_DataSize);
        SetOstream(vec.m_OstreamW, vec.m_OstreamDelim);
    }

    Vector(Vector<T>&& vec) : m_NumElements(vec.m_NumElements), m_DataSize(vec.m_DataSize),
                              m_Data(vec.m_Data), m_OstreamW(vec.m_OstreamW),
                              m_OstreamDelim(vec.m_OstreamDelim)

    {
        vec.Cleanup();
    }

    ~Vector()
    {
        Release();
    }

    Vector<T>& operator = (const Vector<T>& vec)
    {
        if (this != &vec)
        {
            if (!IsConforming(*this, vec))
            {
                Release();
                Allocate(vec.m_NumElements);
            }

            memcpy(m_Data, vec.m_Data, m_DataSize);
            SetOstream(vec.m_OstreamW, vec.m_OstreamDelim);
        }

        return *this;
    }

    Vector<T>& operator = (Vector<T>&& vec)
    {
        Release();

        m_NumElements = vec.m_NumElements;
        m_DataSize = vec.m_DataSize;
        m_Data = vec.m_Data;
        SetOstream(vec.m_OstreamW, vec.m_OstreamDelim);

        vec.Cleanup();
        return *this;
    }

    friend bool operator == (const Vector<T>& vec1, const Vector<T>& vec2)
    {
        if (!IsConforming(vec1, vec2))
            return false;

        return (memcmp(vec1.m_Data, vec.m_Data, vec.m_DataSize) == 0) ? true : false;
    }

    friend bool operator != (const Vector<T>& vec1, const Vector<T>& vec2)
    {
        if (!IsConforming(vec1, vec2))
            return false;

        return (memcmp(vec1.m_Data, vec2.m_Data, vec.m_DataSize) != 0) ? true : false;
    }

    T* Data(void)                       { return m_Data; }
    const T* Data(void) const           { return m_Data; }
    size_t GetNumElements(void) const   { return m_NumElements; }

    T& At(size_t index)
    {
        if (index >= m_NumElements)
            throw std::runtime_error("Invalid index: At()");

        return m_Data[index];
    }

    static bool IsConforming(const Vector<T>& vec1, const Vector<T>& vec2)
    {
        return vec1.m_NumElements == vec2.m_NumElements;
    }

    void Fill(T val)
    {
        for (size_t i = 0; i < m_NumElements; i++)
            m_Data[i] = val;
    }

    void SetOstream(int w, const std::string& delim)
    {
        m_OstreamW = w;
        m_OstreamDelim = delim;
    }

    friend std::ostream& operator << (std::ostream& os, const Vector<T>& vec)
    {
        for (size_t i = 0; i < vec.m_NumElements; i++)
        {
            os << std::setw(vec.m_OstreamW) << vec.m_Data[i];

            if (i + 1 < vec.m_NumElements)
                os << vec.m_OstreamDelim;
        }

        os << std::endl;
        return os;
    }
};
