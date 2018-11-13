#pragma once
#include <cstdint>

#define NOMINMAX
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

class OS
{
public:
    static bool GetProcessAffinityMask(uint64_t* process_mask, uint64_t* system_mask)
    {
        DWORD_PTR process_mask2;
        DWORD_PTR system_mask2;
        BOOL status;
        HANDLE h_process = GetCurrentProcess();

        status = ::GetProcessAffinityMask(h_process, &process_mask2, &system_mask2);
        *process_mask = process_mask2;
        *system_mask = system_mask2;
        return (status != 0) ? true : false;
    }

    static bool SetProcessAffinityMask(uint64_t* process_mask)
    {
        BOOL status;
        HANDLE h_process = GetCurrentProcess();

        status = ::SetProcessAffinityMask(h_process, (DWORD_PTR)process_mask);
        return (status != 0) ? true : false;
    }

    static bool SetThreadAffinityMask(void)
    {
        // Note: Code below may not work on computers with more than 64 processors.

        const int n = sizeof(DWORD_PTR) * 8;
        DWORD_PTR system_mask;
        DWORD_PTR process_mask;
        DWORD_PTR thread_mask = (DWORD_PTR)0x1 << (n - 1);
        HANDLE h_process = GetCurrentProcess();

        if (::GetProcessAffinityMask(h_process, &process_mask, &system_mask) == 0)
            return false;

        // Assign thread to highest available processor

        for (int i = 0; i < n; i++)
        {
            if (((system_mask & thread_mask) != 0)  && ((process_mask & thread_mask) != 0))
            {
                HANDLE h_thread = GetCurrentThread();
                DWORD_PTR status = ::SetThreadAffinityMask(h_thread, thread_mask);

                return (status != 0) ? true : false;
            }

            thread_mask >>= 1;
        }

        return false;
    }

    static bool SetThreadAffinityMask(uint64_t* thread_mask)
    {
        DWORD_PTR status;
        HANDLE h_thread = GetCurrentThread();

        status = ::SetThreadAffinityMask(h_thread, (DWORD_PTR)thread_mask);
        return (status != 0) ? true : false;
    }
};
