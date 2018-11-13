//------------------------------------------------
//               CpuidInfo.h
//------------------------------------------------

#pragma once
#include <cstdint>
#include <vector>
#include <string>

struct CpuidRegs
{
    uint32_t EAX;
    uint32_t EBX;
    uint32_t ECX;
    uint32_t EDX;
};

class CpuidInfo
{
public:
    class CacheInfo
    {
    public:
        enum class Type
        {
            Unknown, Data, Instruction, Unified
        };

    private:
        uint32_t m_Level = 0;
        Type m_Type = Type::Unknown;
        uint32_t m_Size = 0;

    public:
        uint32_t GetLevel(void) const             { return m_Level; }
        uint32_t GetSize(void) const              { return m_Size; }
        Type GetType(void) const                  { return m_Type; }

        // These are defined in CacheInfo.cpp
        CacheInfo(uint32_t level, uint32_t type, uint32_t size);
        std::string GetTypeString(void) const;
    };

private:
    uint32_t m_MaxEax;                              // Max EAX for basic CPUID
    uint32_t m_MaxEaxExt;                           // Max EAX for extended CPUID
    uint64_t m_FeatureFlags;                        // Processor feature flags
    std::vector<CpuidInfo::CacheInfo> m_CacheInfo;  // Processor cache information
    char m_VendorId[13];                            // Processor vendor ID string
    char m_ProcessorBrand[49];                      // Processor brand string
    bool m_OsXsave;                                 // XSAVE is enabled for app use
    bool m_OsAvxState;                              // AVX state is enabled by OS
    bool m_OsAvx512State;                           // AVX-512 state is enabled by OS

    void Init(void);
    void InitProcessorBrand(void);
    void LoadInfo0(void);
    void LoadInfo1(void);
    void LoadInfo2(void);
    void LoadInfo3(void);
    void LoadInfo4(void);
    void LoadInfo5(void);

public:
    enum class FF : uint64_t
    {
        FXSR                = (uint64_t)1 << 0,
        MMX                 = (uint64_t)1 << 1,
        MOVBE               = (uint64_t)1 << 2,
        SSE                 = (uint64_t)1 << 3,
        SSE2                = (uint64_t)1 << 4,
        SSE3                = (uint64_t)1 << 5,
        SSSE3               = (uint64_t)1 << 6,
        SSE4_1              = (uint64_t)1 << 7,
        SSE4_2              = (uint64_t)1 << 8,
        PCLMULQDQ           = (uint64_t)1 << 9,
        POPCNT              = (uint64_t)1 << 10,
        PREFETCHW           = (uint64_t)1 << 11,
        PREFETCHWT1         = (uint64_t)1 << 12,
        RDRAND              = (uint64_t)1 << 13,
        RDSEED              = (uint64_t)1 << 14,
        ERMSB               = (uint64_t)1 << 15,
        AVX                 = (uint64_t)1 << 16,
        AVX2                = (uint64_t)1 << 17,
        F16C                = (uint64_t)1 << 18,
        FMA                 = (uint64_t)1 << 19,
        BMI1                = (uint64_t)1 << 20,
        BMI2                = (uint64_t)1 << 21,
        LZCNT               = (uint64_t)1 << 22,
        ADX                 = (uint64_t)1 << 23,
        AVX512F             = (uint64_t)1 << 24,
        AVX512ER            = (uint64_t)1 << 25,
        AVX512PF            = (uint64_t)1 << 26,
        AVX512DQ            = (uint64_t)1 << 27,
        AVX512CD            = (uint64_t)1 << 28,
        AVX512BW            = (uint64_t)1 << 29,
        AVX512VL            = (uint64_t)1 << 30,
        AVX512_IFMA         = (uint64_t)1 << 31,
        AVX512_VBMI         = (uint64_t)1 << 32,
        AVX512_4FMAPS       = (uint64_t)1 << 33,
        AVX512_4VNNIW       = (uint64_t)1 << 34,
        AVX512_VPOPCNTDQ    = (uint64_t)1 << 35,
        AVX512_VNNI         = (uint64_t)1 << 36,
        AVX512_VBMI2        = (uint64_t)1 << 37,
        AVX512_BITALG       = (uint64_t)1 << 38,
        CLWB                = (uint64_t)1 << 39,
    };

    CpuidInfo(void) { Init(); };
    ~CpuidInfo() {};

    const std::vector<CpuidInfo::CacheInfo>& GetCacheInfo(void) const
    {
        return m_CacheInfo;
    }

    bool GetFF(FF flag) const
    {
        return ((m_FeatureFlags & (uint64_t)flag) != 0) ? true : false;
    }

    std::string GetProcessorBrand(void) const   { return std::string(m_ProcessorBrand); }
    std::string GetVendorId(void) const         { return std::string(m_VendorId); }

    void LoadInfo(void);
};

// Cpuinfo_.asm
extern "C" void Xgetbv_(uint32_t r_ecx, uint32_t* r_eax, uint32_t* r_edx);
extern "C" uint32_t Cpuid_(uint32_t r_eax, uint32_t r_ecx, CpuidRegs* r_out);
