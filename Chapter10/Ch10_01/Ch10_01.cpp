//------------------------------------------------
//               Ch10_01.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include <iomanip>
#include "Ymmval.h"

using namespace std;

extern "C" void Avx2PackedMathI16_(const YmmVal& a, const YmmVal& b, YmmVal c[6]);
extern "C" void Avx2PackedMathI32_(const YmmVal& a, const YmmVal& b, YmmVal c[5]);

void Avx2PackedMathI16(void)
{
    alignas(32) YmmVal a;
    alignas(32) YmmVal b;
    alignas(32) YmmVal c[6];

    a.m_I16[0] = 10;       b.m_I16[0] = 1000;
    a.m_I16[1] = 20;       b.m_I16[1] = 2000;
    a.m_I16[2] = 3000;     b.m_I16[2] = 30;
    a.m_I16[3] = 4000;     b.m_I16[3] = 40;

    a.m_I16[4] = 30000;    b.m_I16[4] = 3000;       // add overflow
    a.m_I16[5] = 6000;     b.m_I16[5] = 32000;      // add overflow
    a.m_I16[6] = 2000;     b.m_I16[6] = -31000;     // sub overflow
    a.m_I16[7] = 4000;     b.m_I16[7] = -30000;     // sub overflow

    a.m_I16[8] = 4000;     b.m_I16[8] = -2500;
    a.m_I16[9] = 3600;     b.m_I16[9] = -1200;
    a.m_I16[10] = 6000;    b.m_I16[10] = 9000;
    a.m_I16[11] = -20000;  b.m_I16[11] = -20000;

    a.m_I16[12] = -25000;  b.m_I16[12] = -27000;    // add overflow
    a.m_I16[13] = 8000;    b.m_I16[13] = 28700;     // add overflow
    a.m_I16[14] = 3;       b.m_I16[14] = -32766;    // sub overflow
    a.m_I16[15] = -15000;  b.m_I16[15] = 24000;     // sub overflow

    Avx2PackedMathI16_(a, b, c);

    cout <<"\nResults for Avx2PackedMathI16_\n\n";
    cout << " i        a        b   vpaddw  vpaddsw   vpsubw  vpsubsw  vpminsw  vpmaxsw\n";
    cout << "--------------------------------------------------------------------------\n";

    for (int i = 0; i < 16; i++)
    {
        cout << setw(2)  << i << ' ';
        cout << setw(8) << a.m_I16[i] << ' ';
        cout << setw(8) << b.m_I16[i] << ' ';
        cout << setw(8) << c[0].m_I16[i] << ' ';
        cout << setw(8) << c[1].m_I16[i] << ' ';
        cout << setw(8) << c[2].m_I16[i] << ' ';
        cout << setw(8) << c[3].m_I16[i] << ' ';
        cout << setw(8) << c[4].m_I16[i] << ' ';
        cout << setw(8) << c[5].m_I16[i] << '\n';
    }
}

void Avx2PackedMathI32(void)
{
    alignas(32) YmmVal a;
    alignas(32) YmmVal b;
    alignas(32) YmmVal c[6];

    a.m_I32[0] = 64;        b.m_I32[0] = 4;
    a.m_I32[1] = 1024;      b.m_I32[1] = 5;
    a.m_I32[2] = -2048;     b.m_I32[2] = 2;
    a.m_I32[3] = 8192;      b.m_I32[3] = 5;
    a.m_I32[4] = -256;      b.m_I32[4] = 8;
    a.m_I32[5] = 4096;      b.m_I32[5] = 7;
    a.m_I32[6] = 16;        b.m_I32[6] = 3;
    a.m_I32[7] = 512;       b.m_I32[7] = 6;

    Avx2PackedMathI32_(a, b, c);

    cout << "\nResults for Avx2PackedMathI32\n\n";
    cout << " i      a      b   vpaddd   vpsubd  vpmulld  vpsllvd  vpsravd   vpabsd\n";
    cout << "----------------------------------------------------------------------\n";

    for (int i = 0; i < 8; i++)
    {
        cout << setw(2) << i << ' ';
        cout << setw(6) << a.m_I32[i] << ' ';
        cout << setw(6) << b.m_I32[i] << ' ';
        cout << setw(8) << c[0].m_I32[i] << ' ';
        cout << setw(8) << c[1].m_I32[i] << ' ';
        cout << setw(8) << c[2].m_I32[i] << ' ';
        cout << setw(8) << c[3].m_I32[i] << ' ';
        cout << setw(8) << c[4].m_I32[i] << ' ';
        cout << setw(8) << c[5].m_I32[i] << '\n';
    }
}

int main()
{
    Avx2PackedMathI16();
    Avx2PackedMathI32();
    return 0;
}