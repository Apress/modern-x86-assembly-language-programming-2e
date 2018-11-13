//------------------------------------------------
//               CacheInfo.cpp
//------------------------------------------------

#include "stdafx.h"
#include <string>
#include "CpuidInfo.h"

using namespace std;

CpuidInfo::CacheInfo::CacheInfo(uint32_t level, uint32_t type, uint32_t size)
{
    m_Level = level;
    m_Size = size;

    switch (type)
    {
        case 1:
            m_Type = Type::Data;
            break;

        case 2:
            m_Type = Type::Instruction;
            break;

        case 3:
            m_Type = Type::Unified;
            break;

        default:
            m_Type = Type::Unknown;
            break;
    }
}

string CpuidInfo::CacheInfo::GetTypeString(void) const
{
    const char* s = "";

    switch (m_Type)
    {
        case Type::Data:
            s = "Data";
            break;

        case Type::Instruction:
            s = "Instruction";
            break;

        case Type::Unified:
            s = "Unified";
            break;

        default:
            s = "Unknown";
            break;
    }

    return string(s);
}
