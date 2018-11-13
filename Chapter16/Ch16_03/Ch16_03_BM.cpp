//------------------------------------------------
//               Ch16_03_BM.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include "Ch16_03.h"
#include "BmThreadTimer.h"
#include "OS.h"

using namespace std;

void LinkedListPrefetch_BM(void)
{
    OS::SetThreadAffinityMask();
    cout << "\nRunning benchmark function LinkedListPrefetch_BM - please wait\n";

    const int num_nodes = 50000;
    LlNode* list1 = LlCreate(num_nodes);
    LlNode* list2a = LlCreate(num_nodes);
    LlNode* list2b = LlCreate(num_nodes);

    const size_t num_it = 500;
    const size_t num_alg = 3;
    BmThreadTimer bmtt(num_it, num_alg);

    for (size_t i = 0; i < num_it; i++)
    {
        size_t order = i % 3;

        // Note: Order of function execution is changed each iteration to
        // obtain more accurate measurements

        if (order == 0)
        {
            bmtt.Start(i, 0);
            LlTraverse(list1);
            bmtt.Stop(i, 0);

            bmtt.Start(i, 1);
            LlTraverseA_(list2a);
            bmtt.Stop(i, 1);

            bmtt.Start(i, 2);
            LlTraverseB_(list2b);
            bmtt.Stop(i, 2);
        }
        else if (order == 1)
        {
            bmtt.Start(i, 1);
            LlTraverseA_(list2a);
            bmtt.Stop(i, 1);

            bmtt.Start(i, 2);
            LlTraverseB_(list2b);
            bmtt.Stop(i, 2);

            bmtt.Start(i, 0);
            LlTraverse(list1);
            bmtt.Stop(i, 0);
        }
        else
        {
            bmtt.Start(i, 2);
            LlTraverseB_(list2b);
            bmtt.Stop(i, 2);

            bmtt.Start(i, 0);
            LlTraverse(list1);
            bmtt.Stop(i, 0);

            bmtt.Start(i, 1);
            LlTraverseA_(list2a);
            bmtt.Stop(i, 1);
        }
    }

    LlDelete(list1);
    LlDelete(list2a);
    LlDelete(list2b);

    string fn = bmtt.BuildCsvFilenameString("Ch16_03_LinkedListPrefetch_BM");
    bmtt.SaveElapsedTimes(fn, BmThreadTimer::EtUnit::MicroSec, 2);
    cout << "Benchmark times save to file " << fn << '\n';
}
