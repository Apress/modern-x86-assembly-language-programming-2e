;-------------------------------------------------
;               Ch10_01.asm
;-------------------------------------------------

; extern "C" void Avx2PackedMathI16_(const YmmVal& a, const YmmVal& b, YmmVal c[6])

        .code
Avx2PackedMathI16_ proc
; Load values a and b, which must be properly aligned
        vmovdqa ymm0,ymmword ptr [rcx]      ;ymm0 = a
        vmovdqa ymm1,ymmword ptr [rdx]      ;ymm1 = b

; Perform packed arithmetic operations
        vpaddw ymm2,ymm0,ymm1               ;add
        vmovdqa ymmword ptr [r8],ymm2       ;save vpaddw result

        vpaddsw ymm2,ymm0,ymm1              ;add with signed saturation
        vmovdqa ymmword ptr [r8+32],ymm2    ;save vpaddsw result

        vpsubw ymm2,ymm0,ymm1               ;sub
        vmovdqa ymmword ptr [r8+64],ymm2    ;save vpsubw result

        vpsubsw ymm2,ymm0,ymm1              ;sub with signed saturation
        vmovdqa ymmword ptr [r8+96],ymm2    ;save vpsubsw result

        vpminsw ymm2,ymm0,ymm1              ;signed minimums
        vmovdqa ymmword ptr [r8+128],ymm2   ;save vpminsw result

        vpmaxsw ymm2,ymm0,ymm1              ;signed maximums
        vmovdqa ymmword ptr [r8+160],ymm2   ;save vpmaxsw result

        vzeroupper
        ret
Avx2PackedMathI16_ endp

; extern "C" void Avx2PackedMathI32_(const YmmVal& a, const YmmVal& b, YmmVal c[6])

Avx2PackedMathI32_ proc
; Load values a and b, which must be properly aligned
        vmovdqa ymm0,ymmword ptr [rcx]      ;ymm0 = a
        vmovdqa ymm1,ymmword ptr [rdx]      ;ymm1 = b

; Perform packed arithmetic operations
        vpaddd ymm2,ymm0,ymm1               ;add
        vmovdqa ymmword ptr [r8],ymm2       ;save vpaddd result

        vpsubd ymm2,ymm0,ymm1               ;sub
        vmovdqa ymmword ptr [r8+32],ymm2    ;save vpsubd result

        vpmulld ymm2,ymm0,ymm1              ;signed mul (low 32 bits)
        vmovdqa ymmword ptr [r8+64],ymm2    ;save vpmulld result

        vpsllvd ymm2,ymm0,ymm1              ;shift left logical
        vmovdqa ymmword ptr [r8+96],ymm2    ;save vpsllvd result

        vpsravd ymm2,ymm0,ymm1              ;shift right arithmetic
        vmovdqa ymmword ptr [r8+128],ymm2   ;save vpsravd result

        vpabsd ymm2,ymm0                    ;absolute value
        vmovdqa ymmword ptr [r8+160],ymm2   ;save vpabsd result

        vzeroupper
        ret
Avx2PackedMathI32_ endp
        end