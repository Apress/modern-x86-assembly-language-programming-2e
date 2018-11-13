//------------------------------------------------
//               Ch16_03.h
//------------------------------------------------

#pragma once
#include <cstdint>

// This structure must match the corresponding structure definition in Ch16_03.asmh
struct LlNode
{
    double ValA[4];
    double ValB[4];
    double ValC[4];
    double ValD[4];
    uint8_t FreeSpace[376];
    LlNode* Link;
};

// Ch16_03_Misc.cpp
extern bool LlCompare(int num_nodes, LlNode* l1, LlNode* l2, LlNode* l3, int* node_fail);
extern LlNode* LlCreate(int num_nodes);
extern void LlDelete(LlNode* p);
extern bool LlPrint(LlNode* p, const char* fn, const char* msg, bool append);
extern void LlTraverse(LlNode* p);

// Ch16_03_.asm
extern "C" void LlTraverseA_(LlNode* p);
extern "C" void LlTraverseB_(LlNode* p);

// Ch16_03_BM.cpp
extern void LinkedListPrefetch_BM(void);
