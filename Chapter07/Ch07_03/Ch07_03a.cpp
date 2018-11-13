//------------------------------------------------
//               Ch07_03a.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include "XmmVal.h"

using namespace std;

extern "C" void AvxPackedMulI16_(XmmVal c[2], const XmmVal& a, const XmmVal& b);

// Test function to generate values for Figure 7-1
void Figure7_1(void)
{
    alignas(16) XmmVal a;
    alignas(16) XmmVal b;
    alignas(16) XmmVal c[2];

    a.m_I16[0] = 10;        b.m_I16[0] = -5;
    a.m_I16[1] = 3000;      b.m_I16[1] = 100;
    a.m_I16[2] = -2000;     b.m_I16[2] = -9000;
    a.m_I16[3] = 42;        b.m_I16[3] = 1000;
    a.m_I16[4] = -5000;     b.m_I16[4] = 25000;
    a.m_I16[5] = 8;         b.m_I16[5] = 16384;
    a.m_I16[6] = 10000;     b.m_I16[6] = 3500;
    a.m_I16[7] = -60;       b.m_I16[7] = 6000;

    AvxPackedMulI16_(c, a, b);

    cout << "\n\nValues for Figure7-1\n";

    for (size_t i = 0; i < 8; i++)
    {
        cout << setfill('0') << hex;
        cout << "a[" << i << "]: " << setw(4) << a.m_I16[i] << "  ";
        cout << "b[" << i << "]: " << setw(4) << b.m_I16[i] << "  ";

        cout << setfill('0') << hex;

        if (i < 4)
        {
            cout << "c[0][" << i << "]: ";
            cout << setw(8) << c[0].m_I32[i] << '\n';
        }
        else
        {
            cout << "c[1][" << i - 4 << "]: ";
            cout << setw(8) << c[1].m_I32[i - 4] << '\n';
        }
    }
}
