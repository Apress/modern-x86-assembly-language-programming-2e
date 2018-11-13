#pragma once
#include <iostream>
#include <iomanip>
#include <string>
#include <stdexcept>
#include "AlignedMem.h"
#include "Vector.h"

template <typename T> class Matrix
{
    static const size_t c_Alignment = 64;   // Alignment for AVX, AXV2, & AVX-512

    size_t m_NumRows;
    size_t m_NumCols;
    size_t m_NumElements;
    size_t m_DataSize;
    T* m_Data;

    int m_OstreamW;
    std::string m_OstreamDelim;

    bool IsConforming(size_t num_rows, size_t num_cols) const
    {
        return m_NumRows == num_rows && m_NumCols == num_cols;
    }

    void Allocate(size_t num_rows, size_t num_cols)
    {
        m_NumRows = num_rows;
        m_NumCols = num_cols;
        m_NumElements = m_NumRows * m_NumCols;
        m_DataSize = m_NumElements * sizeof(T);

        if (m_NumElements == 0)
            m_Data = nullptr;
        else
            m_Data = (T*)AlignedMem::Allocate(m_DataSize, c_Alignment);

        SetOstream(10, "  ");
    }

    void Cleanup(void)
    {
        m_NumRows = m_NumCols = m_NumElements = m_DataSize = 0;
        m_Data = nullptr;
    }

    void Release(void)
    {
        if (m_Data != nullptr)
            AlignedMem::Release(m_Data);

        Cleanup();
    }

 public:
    Matrix(void)
    {
        Allocate(0, 0);
    }

    Matrix(size_t num_rows, size_t num_cols)
    {
        Allocate(num_rows, num_cols);
        Fill(0);
    }

    Matrix(size_t num_rows, size_t num_cols, bool set_identity)
    {
        Allocate(num_rows, num_cols);
        Fill(0);

        if (set_identity && m_NumRows == m_NumCols)
        {
            for (size_t i = 0; i < num_rows; i++)
                m_Data[i * m_NumCols + i] = (T)1;
        }
    }

    Matrix(const Matrix<T>& mat)
    {
        Allocate(mat.m_NumRows, mat.m_NumCols);
        memcpy(m_Data, mat.m_Data, m_DataSize);
        SetOstream(mat.m_OstreamW, mat.m_OstreamDelim);
    }

    Matrix(Matrix<T>&& mat) : m_NumRows(mat.m_NumRows), m_NumCols(mat.m_NumCols), m_NumElements(mat.m_NumElements),
                              m_DataSize(mat.m_DataSize), m_Data(mat.m_Data), m_OstreamW(mat.m_OstreamW),
                              m_OstreamDelim(m_OstreamDelim)

    {
        mat.Cleanup();
    }

    ~Matrix()
    {
        Release();
    }

    Matrix<T>& operator = (const Matrix<T>& mat)
    {
        if (this != &mat)
        {
            if (!IsConforming(*this, mat))
            {
                Release();
                Allocate(mat.m_NumRows, mat.m_NumCols);
            }

            memcpy(m_Data, mat.m_Data, m_DataSize);
            SetOstream(mat.m_OstreamW, mat.m_OstreamDelim);
        }

        return *this;
    }

    Matrix<T>& operator = (Matrix<T>&& mat)
    {
        Release();

        m_NumRows = mat.m_NumRows;
        m_NumCols = mat.m_NumCols;
        m_NumElements = mat.m_NumElements;
        m_DataSize = mat.m_DataSize;
        m_Data = mat.m_Data;
        SetOstream(mat.m_OstreamW, mat.m_OstreamDelim);

        mat.Cleanup();
        return *this;
    }

    friend bool operator == (const Matrix<T>& mat1, const Matrix<T>& mat2)
    {
        if (!IsConforming(mat1, mat2))
            return false;

        return (memcmp(mat1.m_Data, mat2.m_Data, mat1.m_DataSize) == 0) ? true : false;
    }

    friend bool operator != (const Matrix<T>& mat1, const Matrix<T>& mat2)
    {
        if (!IsConforming(mat1, mat2))
            return false;

        return (memcmp(mat1.m_Data, mat2.m_Data, mat1.m_DataSize) != 0) ? true : false;
    }

    T* Data(void)                       { return m_Data; }
    const T* Data(void) const           { return m_Data; }
    size_t GetNumRows(void) const       { return m_NumRows; }
    size_t GetNumCols(void) const       { return m_NumCols; }
    size_t GetNumElements(void) const   { return m_NumElements; }
    bool IsSquare(void) const           { return m_NumRows == m_NumCols; }

    friend Matrix<T> operator + (const Matrix<T>& mat1, const Matrix<T>& mat2)
    {
        if (!IsConforming(mat1, mat2))
            throw std::runtime_error("Non-conforming operands: operator +");

        Matrix<T> result(mat1.m_NumRows, mat1.m_NumCols);

        for (size_t i = 0; i < result.m_NumElements; i++)
            result.m_Data[i] = mat1.m_Data[i] + mat2.m_Data[i];

        return result;
    }

    friend Matrix<T> operator * (const Matrix<T>& mat1, const Matrix<T>& mat2)
    {
        if (mat1.m_NumCols != mat2.m_NumRows)
            throw std::runtime_error("Non-conforming operands: operator *");

        size_t m = mat1.m_NumCols;
        Matrix<T> result(mat1.m_NumRows, mat2.m_NumCols);

        for (size_t i = 0; i < result.m_NumRows; i++)
        {
            for (size_t j = 0; j < result.m_NumCols; j++)
            {
                T sum = 0;

                for (size_t k = 0; k < m; k++)
                {
                    T val = mat1.m_Data[i * mat1.m_NumCols + k] * mat2.m_Data[k * mat2.m_NumCols + j];
                    sum += val;
                }

                result.m_Data[i * result.m_NumCols + j] = sum;
            }
        }

        return result;
    }

    //
    // For some operations, static functions are used instead of overloaded
    // operators in order to avoid inaccurate benchmark performance comparisons.
    //

    static void Add(Matrix<T>& result, const Matrix<T>& mat1, const Matrix<T>& mat2)
    {
        if (!IsConforming(result, mat1) || !IsConforming(mat1, mat2))
            throw std::runtime_error("Non-conforming operands: Add");

        for (size_t i = 0; i < result.m_NumElements; i++)
            result.m_Data[i] = mat1.m_Data[i] + mat2.m_Data[i];
    }

    static void Mul(Matrix<T>& result, const Matrix<T>& mat1, const Matrix<T>& mat2)
    {
        if (mat1.m_NumCols != mat2.m_NumRows)
            throw std::runtime_error("Non-conforming operands: Mul");

        if (result.m_NumRows != mat1.m_NumRows || result.m_NumCols != mat2.m_NumCols)
            throw std::runtime_error("Invalid matrix size: Mul");

        size_t m = mat1.m_NumCols;

        for (size_t i = 0; i < result.m_NumRows; i++)
        {
            for (size_t j = 0; j < result.m_NumCols; j++)
            {
                T sum = 0;

                for (size_t k = 0; k < m; k++)
                {
                    T val = mat1.m_Data[i * mat1.m_NumCols + k] * mat2.m_Data[k * mat2.m_NumCols + j];
                    sum += val;
                }

                result.m_Data[i * result.m_NumCols + j] = sum;
            }
        }
    }

    static void MulScalar(Matrix<T>& result, const Matrix<T>& mat, T val)
    {
        if (!IsConforming(result, mat))
            throw std::runtime_error("Non-conforming operands: MulScalar");

        for (size_t i = 0; i < result.m_NumElements; i++)
            result.m_Data[i] = mat.m_Data[i] * val;
    }

    static void MulVector(Vector<T>& vec2, const Matrix<T>& mat, const Vector<T>& vec1)
    {
        if (mat.m_NumCols != vec1.GetNumElements())
            throw std::runtime_error("Non-conforming operands: MulVector");

        const T* data1 = vec1.Data();
        T* data2 = vec2.Data();

        for (size_t i = 0; i < mat.m_NumRows; i++)
        {
            T sum = 0;

            for (size_t j = 0; j < mat.m_NumCols; j++)
                sum += mat.m_Data[i * mat.m_NumCols + j] * data1[j];

             data2[i] = sum;
        }
    }

    static void Transpose(Matrix<T>& result, const Matrix<T>& mat1)
    {
        if (result.m_NumRows != mat1.m_NumCols || result.m_NumCols != mat1.m_NumRows)
            throw std::runtime_error("Non-conforming operands: Transpose");

        for (size_t i = 0; i < result.m_NumRows; i++)
        {
            for (size_t j = 0; j < result.m_NumCols; j++)
                result.m_Data[i * result.m_NumCols + j] = mat1.m_Data[j * mat1.m_NumCols + i];
        }
    }

    T& At(size_t row, size_t col)
    {
        if (row >= m_NumRows || col >= m_NumCols)
            throw std::runtime_error("Invalid row/col index: At()");

        return m_Data[row * m_NumCols + col];
    }

    static bool IsConforming(const Matrix<T>& mat1, const Matrix<T>& mat2)
    {
        return mat1.m_NumRows == mat2.m_NumRows && mat1.m_NumCols == mat2.m_NumCols;
    }

    void Fill(T val)
    {
        for (size_t i = 0; i < m_NumElements; i++)
            m_Data[i] = val;
    }

    void RoundToZero(T epsilon)
    {
        for (size_t i = 0; i < m_NumElements; i++)
        {
            if (fabs(m_Data[i]) < epsilon)
                m_Data[i] = 0;
        }
    }

    void SetCol(size_t col, const T* vals)
    {
        if (col >= m_NumCols)
            throw std::runtime_error("Invalid column index: SetCol()");

        for (size_t i = 0; i < m_NumRows; i++)
            m_Data[i * m_NumCols + col] = vals[i];
    }

    void SetRow(size_t row, const T* vals)
    {
        if (row >= m_NumRows)
            throw std::runtime_error("Invalid row index: SetRow()");

        for (size_t j = 0; j < m_NumCols; j++)
            m_Data[row * m_NumCols + j] = vals[j];
    }

    void SetI(void)
    {
        if (!IsSquare())
            throw std::runtime_error("Square matrix required: SetI()");

        for (size_t i = 0; i < m_NumRows; i++)
        {
            for (size_t j = 0; j < m_NumCols; j++)
                m_Data[i * m_NumCols + j] = (i == j) ? (T)1 : 0;
        }
    }

    void SetOstream(int w, const std::string& delim)
    {
        m_OstreamW = w;
        m_OstreamDelim = delim;
    }

    T Trace(void) const
    {
        if (!IsSquare())
            throw std::runtime_error("Square matrix required: Trace()");

        T sum = 0;

        for (size_t i = 0; i < m_NumRows; i++)
            sum += m_Data[i * m_NumCols + i];

        return sum;
    }

    friend std::ostream& operator << (std::ostream& os, const Matrix<T>& mat)
    {
        for (size_t i = 0; i < mat.m_NumRows; i++)
        {
            for (size_t j = 0; j < mat.m_NumCols; j++)
            {
                os << std::setw(mat.m_OstreamW) << mat.m_Data[i * mat.m_NumCols + j];

                if (j + 1 < mat.m_NumCols)
                    os << mat.m_OstreamDelim;
            }

             os << std::endl;
        }

        return os;
    }
};
