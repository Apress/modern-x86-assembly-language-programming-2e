//------------------------------------------------
//               Ch13_09_Misc.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include <random>
#define _USE_MATH_DEFINES
#include <math.h>
#include "Ch13_09.h"

using namespace std;

void CreateSignal(float* x, int n, int kernel_size, unsigned int seed)
{
    const float degtorad = (float)(M_PI / 180.0);
    const float t_start = 0;
    const float t_step = 0.002f;
    const int m = 3;
    const float amp[m] {1.0f, 0.80f, 1.20f};
    const float freq[m] {5.0f, 10.0f, 15.0f};
    const float phase[m] {0.0f, 45.0f, 90.0f};
    const int ks2 = kernel_size / 2;

    uniform_int_distribution<> ui_dist {0, 500};
    default_random_engine rng {seed};
    float t = t_start;

    for (int i = 0; i < n; i++, t += t_step)
    {
        float x_val = 0;

        for (int j = 0; j < m; j++)
        {
            float omega = 2.0f * (float)M_PI * freq[j];
            float x_temp1 = amp[j] * sin(omega * t + phase[j] * degtorad);
            int rand_val = ui_dist(rng);
            float noise = (float)((rand_val) - 250) / 10.0f;
            float x_temp2 = x_temp1 + x_temp1 * noise / 100.0f;

            x_val += x_temp2;
        }

        x[i] = x_val;
    }
}

extern void PadSignal(float* x2, int n2, const float* x1, int n1, int ks2)
{
    if (n2 != n1 + ks2 * 2)
        throw runtime_error("InitPad - invalid size argument");

    for (int i = 0; i < n1; i++)
        x2[i + ks2] = x1[i];

    for (int i = 0; i < ks2; i++)
    {
        x2[i] = x1[ks2 - i - 1];
        x2[n1 + ks2 + i] = x1[n1 - i - 1];
    }
}
