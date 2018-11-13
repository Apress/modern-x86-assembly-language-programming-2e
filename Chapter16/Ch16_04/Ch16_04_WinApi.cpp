//------------------------------------------------
//               Ch16_04_WinApi.cpp
//------------------------------------------------

#include "stdafx.h"
#include <windows.h>
#include "Ch16_04.h"

bool GetAvailableMemory(size_t* mem_size)
{
    MEMORYSTATUSEX ms;

    ms.dwLength = sizeof(ms);
    bool rc = GlobalMemoryStatusEx(&ms);
    *mem_size = (rc) ? ms.ullAvailPhys : 0;
    return rc;
}