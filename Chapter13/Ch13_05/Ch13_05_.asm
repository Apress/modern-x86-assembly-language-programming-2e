;-------------------------------------------------
;               Ch13_05.asm
;-------------------------------------------------

        include <cmpequ.asmh>

; extern "C" void Avx512PackedCompareF32_(const ZmmVal* a, const ZmmVal* b, ZmmVal c[8]);

        .code
Avx512PackedCompareF32_ proc
        vmovaps zmm0,[rcx]                   ;zmm0 = a
        vmovaps zmm1,[rdx]                   ;zmm1 = b

; Perform packed EQUAL compare
        vcmpps k1,zmm0,zmm1,CMP_EQ
        kmovw word ptr [r8],k1

; Perform packed NOT EQUAL compare
        vcmpps k1,zmm0,zmm1,CMP_NEQ
        kmovw word ptr [r8+2],k1

; Perform packed LESS THAN compare
        vcmpps k1,zmm0,zmm1,CMP_LT
        kmovw word ptr [r8+4],k1

; Perform packed LESS THAN OR EQUAL compare
        vcmpps k1,zmm0,zmm1,CMP_LE
        kmovw word ptr [r8+6],k1

; Perform packed GREATER THAN compare
        vcmpps k1,zmm0,zmm1,CMP_GT
        kmovw word ptr [r8+8],k1

; Perform packed GREATER THAN OR EQUAL compare
        vcmpps k1,zmm0,zmm1,CMP_GE
        kmovw word ptr [r8+10],k1

; Perform packed ORDERED compare
        vcmpps k1,zmm0,zmm1,CMP_ORD
        kmovw word ptr [r8+12],k1

; Perform packed UNORDERED compare
        vcmpps k1,zmm0,zmm1,CMP_UNORD
        kmovw word ptr [r8+14],k1

        vzeroupper
        ret
Avx512PackedCompareF32_ endp
        end
