//------------------------------------------------
//               YmmVal.h
//------------------------------------------------

#pragma once
#include <string>
#include <cstdint>
#include <sstream>
#include <iomanip>

struct YmmVal
{
public:
    union
    {
        int8_t m_I8[32];
        int16_t m_I16[16];
        int32_t m_I32[8];
        int64_t m_I64[4];
        uint8_t m_U8[32];
        uint16_t m_U16[16];
        uint32_t m_U32[8];
        uint64_t m_U64[4];
        float m_F32[8];
        double m_F64[4];
    };

private:
    template <typename T> std::string ToStringInt(const T* x, int n, int w, unsigned int select)
    {
        std::ostringstream oss;

        int n2 = n / 2;
        int offset = (select % 2) ? n / 2 : 0;

        for (int i = 0; i < n2; i++)
        {
            oss << std::setw(w) << (int64_t)x[i + offset];

            if (i + 1 == n2 / 2)
                oss << "   |";
        }

        return oss.str();
    }

    template <typename T> std::string ToStringUint(const T* x, int n, int w, unsigned int select)
    {
        std::ostringstream oss;

        int n2 = n / 2;
        int offset = (select % 2) ? n / 2 : 0;

        for (int i = 0; i < n2; i++)
        {
            oss << std::setw(w) << (uint64_t)x[i + offset];

            if (i + 1 == n2 / 2)
                oss << "   |";
        }

        return oss.str();
    }

    template <typename T> std::string ToStringHex(const T* x, int n, int w, unsigned int select)
    {
        std::ostringstream oss;

        int n2 = n / 2;
        int offset = (select % 2) ? n / 2 : 0;

        for (int i = 0; i < n2; i++)
        {
            const int w_temp = 16;
            std::ostringstream oss_temp;

            oss_temp << std::uppercase << std::hex << std::setfill('0');
            oss_temp << std::setw(w_temp) << (uint64_t)x[i + offset];
            std::string s1 = oss_temp.str();
            std::string s2 = s1.substr(w_temp - sizeof(T) * 2);

            oss << std::setw(w) << s2;

            if (i + 1 == n2 / 2)
                oss << "   |";
        }

        return oss.str();
    }

    template <typename T> std::string ToStringFP(const T* x, int n, int w, int p, unsigned int select)
    {
        std::ostringstream oss;

        int n2 = n / 2;
        int offset = (select % 2) ? n / 2 : 0;

        oss << std::fixed << std::setprecision(p);

        for (int i = 0; i < n2; i++)
        {
            oss << std::setw(w) << x[i + offset];

            if (i + 1 == n2 / 2)
                oss << "   |";
        }

        return oss.str();
    }

public:

    //
    // Signed integer
    //

    std::string ToStringI8(unsigned int select)
    {
        return ToStringInt(m_I8, sizeof(m_I8) / sizeof(int8_t), 4, select);
    }

    std::string ToStringI16(unsigned int select)
    {
        return ToStringInt(m_I16, sizeof(m_I16) / sizeof(int16_t), 8, select);
    }

    std::string ToStringI32(unsigned int select)
    {
        return ToStringInt(m_I32, sizeof(m_I32) / sizeof(int32_t), 16, select);
    }

    std::string ToStringI64(unsigned int select)
    {
        return ToStringInt(m_I64, sizeof(m_I64) / sizeof(int64_t), 32, select);
    }

    //
    // Unsigned integer
    //

    std::string ToStringU8(unsigned int select)
    {
        return ToStringUint(m_U8, sizeof(m_U8) / sizeof(uint8_t), 4, select);
    }

    std::string ToStringU16(unsigned int select)
    {
        return ToStringUint(m_U16, sizeof(m_U16) / sizeof(uint16_t), 8, select);
    }

    std::string ToStringU32(unsigned int select)
    {
        return ToStringUint(m_U32, sizeof(m_U32) / sizeof(uint32_t), 16, select);
    }

    std::string ToStringU64(unsigned int select)
    {
        return ToStringUint(m_U64, sizeof(m_U64) / sizeof(uint64_t), 32, select);
    }

    //
    // Hexadecimal
    //

    std::string ToStringX8(unsigned int select)
    {
        return ToStringHex(m_U8, sizeof(m_U8) / sizeof(uint8_t), 4, select);
    }

    std::string ToStringX16(unsigned int select)
    {
        return ToStringHex(m_U16, sizeof(m_U16) / sizeof(uint16_t), 8, select);
    }

    std::string ToStringX32(unsigned int select)
    {
        return ToStringHex(m_U32, sizeof(m_U32) / sizeof(uint32_t), 16, select);
    }

    std::string ToStringX64(unsigned int select)
    {
        return ToStringHex(m_U64, sizeof(m_U64) / sizeof(uint64_t), 32, select);
    }

    //
    // Floating point
    //

    std::string ToStringF32(unsigned int select)
    {
        return ToStringFP(m_F32, sizeof(m_F32) / sizeof(float), 16, 6, select);
    }

    std::string ToStringF64(unsigned int select)
    {
        return ToStringFP(m_F64, sizeof(m_F64) / sizeof(double), 32, 12, select);
    }
};
