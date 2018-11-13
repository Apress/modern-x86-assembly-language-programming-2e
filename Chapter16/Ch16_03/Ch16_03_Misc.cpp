//------------------------------------------------
//               Ch16_03_Misc.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include <cmath>
#include <random>
#include "Ch16_03.h"
#include "AlignedMem.h"

using namespace std;

bool LlCompare(int num_nodes, LlNode* l1, LlNode* l2, LlNode* l3, int* node_fail)
{
    const double epsilon = 1.0e-9;

    for (int i = 0; i < num_nodes; i++)
    {
        *node_fail = i;

        if ((l1 == nullptr) || (l2 == nullptr) || (l3 == nullptr))
            return false;

        for (int j = 0; j < 4; j++)
        {
            bool b12_c = fabs(l1->ValC[j] - l2->ValC[j]) > epsilon;
            bool b13_c = fabs(l1->ValC[j] - l3->ValC[j]) > epsilon;
            if (b12_c || b13_c)
                return false;

            bool b12_d = fabs(l1->ValD[j] - l2->ValD[j]) > epsilon;
            bool b13_d = fabs(l1->ValD[j] - l3->ValD[j]) > epsilon;
            if (b12_d || b13_d)
                return false;
        }

        l1 = l1->Link;
        l2 = l2->Link;
        l3 = l3->Link;
    }

    *node_fail = -2;
    if ((l1 != nullptr) || (l2 != nullptr) || (l3 != nullptr))
        return false;

    *node_fail = -1;
    return true;
}

LlNode* LlCreate(int num_nodes)
{
    const size_t align = 64;
    const unsigned int seed = 83;
    LlNode* first = nullptr;
    LlNode* last = nullptr;
    uniform_int_distribution<> ui_dist {1, 500};
    default_random_engine rng {seed};

    for (int i = 0; i < num_nodes; i++)
    {
        LlNode* p = (LlNode*)AlignedMem::Allocate(sizeof(LlNode), align);
        p->Link = nullptr;

        if (i == 0)
            first = last = p;
        else
        {
            last->Link = p;
            last = p;
        }

        for (int j = 0; j < 4; j++)
        {
            p->ValA[j] = (double)ui_dist(rng);
            p->ValB[j] = (double)ui_dist(rng);
            p->ValC[j] = 0;
            p->ValD[j] = 0;
        }
    }

    return first;
}

void LlDelete(LlNode* p)
{
    while (p != nullptr)
    {
        LlNode* q = p->Link;

        AlignedMem::Release(p);
        p = q;
    }
}

bool LlPrint(LlNode* p, const char* fn, const char* msg, bool append)
{
    FILE* fp;
    const char* mode = (append) ? "at" : "wt";

    if (fopen_s(&fp, fn, mode) != 0)
        return false;

    int i = 0;
    const char* fs = "%14.4lf %14.4lf %14.4lf %14.4lf\n";

    if (msg != nullptr)
        fprintf(fp, "\n%s\n", msg);

    while (p != nullptr)
    {
        fprintf(fp, "\nLlNode %d [0x%p]\n", i, p);
        fprintf(fp, "  ValA: ");
        fprintf(fp, fs, p->ValA[0], p->ValA[1], p->ValA[2], p->ValA[3]);

        fprintf(fp, "  ValB: ");
        fprintf(fp, fs, p->ValB[0], p->ValB[1], p->ValB[2], p->ValB[3]);

        fprintf(fp, "  ValC: ");
        fprintf(fp, fs, p->ValC[0], p->ValC[1], p->ValC[2], p->ValC[3]);

        fprintf(fp, "  ValD: ");
        fprintf(fp, fs, p->ValD[0], p->ValD[1], p->ValD[2], p->ValD[3]);

        i++;
        p = p->Link;
    }

    fclose(fp);
    return true;
}

void LlTraverse(LlNode* p)
{
    while (p != nullptr)
    {
        for (int i = 0; i < 4; i++)
        {
            p->ValC[i] = sqrt(p->ValA[i] * p->ValA[i] + p->ValB[i] * p->ValB[i]);
            p->ValD[i] = sqrt(p->ValA[i] / p->ValB[i] + p->ValB[i] / p->ValA[i]);
        }
        p = p->Link;
    }
}
