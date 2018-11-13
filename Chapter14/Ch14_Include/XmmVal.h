//------------------------------------------------
//               XmmVal.h
//------------------------------------------------

#pragma once
#include <string>
#include <cstdint>
#include <sstream>
#include <iomanip>

struct XmmVal
{
public:
    union
    {
        int8_t m_I8[16];
        int16_t m_I16[8];
        int32_t m_I32[4];
        int64_t m_I64[2];
        uint8_t m_U8[16];
        uint16_t m_U16[8];
        uint32_t m_U32[4];
        uint64_t m_U64[2];
        float m_F32[4];
        double m_F64[2];
    };

private:
    template <typename T> std::string ToStringInt(const T* x, int n, int w)
    {
        std::ostringstream oss;

        for (int i = 0; i < n; i++)
        {
            oss << std::setw(w) << (int64_t)x[i];

            if (i + 1 == n / 2)
                oss << "   |";
        }

        return oss.str();
    }

    template <typename T> std::string ToStringUint(const T* x, int n, int w)
    {
        std::ostringstream oss;

        for (int i = 0; i < n; i++)
        {
            oss << std::setw(w) << (uint64_t)x[i];

            if (i + 1 == n / 2)
                oss << "   |";
        }

        return oss.str();
    }

    template <typename T> std::string ToStringHex(const T* x, int n, int w)
    {
        std::ostringstream oss;

        for (int i = 0; i < n; i++)
        {
            const int w_temp = 16;
            std::ostringstream oss_temp;

            oss_temp << std::uppercase << std::hex << std::setfill('0');
            oss_temp << std::setw(w_temp) << (uint64_t)x[i];
            std::string s1 = oss_temp.str();
            std::string s2 = s1.substr(w_temp - sizeof(T) * 2);

            oss << std::setw(w) << s2;

            if (i + 1 == n / 2)
                oss << "   |";
        }

        return oss.str();
    }

    template <typename T> std::string ToStringFP(const T* x, int n, int w, int p)
    {
        std::ostringstream oss;

        oss << std::fixed << std::setprecision(p);

        for (int i = 0; i < n; i++)
        {
            oss << std::setw(w) << x[i];

            if (i + 1 == n / 2)
                oss << "   |";
        }

        return oss.str();
    }

public:

    //
    // Signed integer
    //
      
    std::string ToStringI8(void)
    {
        return ToStringInt(m_I8, sizeof(m_I8) / sizeof(int8_t), 4);
    }

    std::string ToStringI16(void)
    {
        return ToStringInt(m_I16, sizeof(m_I16) / sizeof(int16_t), 8);
    }

    std::string ToStringI32(void)
    {
        return ToStringInt(m_I32, sizeof(m_I32) / sizeof(int32_t), 16);
    }

    std::string ToStringI64(void)
    {
        return ToStringInt(m_I64, sizeof(m_I64) / sizeof(int64_t), 32);
    }

    //
    // Unsigned integer
    //

    std::string ToStringU8(void)
    {
        return ToStringUint(m_U8, sizeof(m_U8) / sizeof(uint8_t), 4);
    }

    std::string ToStringU16(void)
    {
        return ToStringUint(m_U16, sizeof(m_U16) / sizeof(uint16_t), 8);
    }

    std::string ToStringU32(void)
    {
        return ToStringUint(m_U32, sizeof(m_U32) / sizeof(uint32_t), 16);
    }

    std::string ToStringU64(void)
    {
        return ToStringUint(m_U64, sizeof(m_U64) / sizeof(uint64_t), 32);
    }

    //
    // Hexadecimal
    //

    std::string ToStringX8(void)
    {
        return ToStringHex(m_U8, sizeof(m_U8) / sizeof(uint8_t), 4);
    }

    std::string ToStringX16(void)
    {
        return ToStringHex(m_U16, sizeof(m_U16) / sizeof(uint16_t), 8);
    }

    std::string ToStringX32(void)
    {
        return ToStringHex(m_U32, sizeof(m_U32) / sizeof(uint32_t), 16);
    }

    std::string ToStringX64(void)
    {
        return ToStringHex(m_U64, sizeof(m_U64) / sizeof(uint64_t), 32);
    }

    //
    // Floating point
    //

    std::string ToStringF32(void)
    {
        return ToStringFP(m_F32, sizeof(m_F32) / sizeof(float), 16, 6);
    }

    std::string ToStringF64(void)
    {
        return ToStringFP(m_F64, sizeof(m_F64) / sizeof(double), 32, 12);
    }
};
