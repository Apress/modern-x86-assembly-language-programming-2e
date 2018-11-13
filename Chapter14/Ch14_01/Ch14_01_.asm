;-------------------------------------------------
;               Ch14_01.asm
;-------------------------------------------------

; extern "C" void Avx512PackedMathI16_(const ZmmVal* a, const ZmmVal* b, ZmmVal c[6])

        .code
Avx512PackedMathI16_ proc
        vmovdqu16 zmm0,zmmword ptr [rcx]        ;zmm0 = a
        vmovdqu16 zmm1,zmmword ptr [rdx]        ;zmm1 = b

; Perform packed word operations
        vpaddw zmm2,zmm0,zmm1                   ;add
        vmovdqa64 zmmword ptr [r8],zmm2         ;save vpaddw result

        vpaddsw zmm2,zmm0,zmm1                  ;add with signed saturation
        vmovdqa64 zmmword ptr [r8+64],zmm2      ;save vpaddsw result

        vpsubw zmm2,zmm0,zmm1                   ;sub
        vmovdqa64 zmmword ptr [r8+128],zmm2     ;save vpsubw result

        vpsubsw zmm2,zmm0,zmm1                  ;sub with signed saturation
        vmovdqa64 zmmword ptr [r8+192],zmm2     ;save vpsubsw result

        vpminsw zmm2,zmm0,zmm1                  ;signed minimums
        vmovdqa64 zmmword ptr [r8+256],zmm2     ;save vpminsw result

        vpmaxsw zmm2,zmm0,zmm1                  ;signed maximums
        vmovdqa64 zmmword ptr [r8+320],zmm2     ;save vpmaxsw result

        vzeroupper
        ret
Avx512PackedMathI16_ endp

; extern "C" void Avx512PackedMathI64_(const ZmmVal* a, const ZmmVal* b, ZmmVal c[5], unsigned int opmask)

Avx512PackedMathI64_ proc
        vmovdqa64 zmm0,zmmword ptr [rcx]        ;zmm0 = a
        vmovdqa64 zmm1,zmmword ptr [rdx]        ;zmm1 = b

        and r9d,0ffh                            ;r9d = opmask value
        kmovb k1,r9d                            ;k1 = opmask

; Perform packed quadword operations
        vpaddq zmm2{k1}{z},zmm0,zmm1            ;add
        vmovdqa64 zmmword ptr [r8],zmm2         ;save vpaddq result

        vpsubq zmm2{k1}{z},zmm0,zmm1            ;sub
        vmovdqa64 zmmword ptr [r8+64],zmm2      ;save vpsubq result

        vpmullq zmm2{k1}{z},zmm0,zmm1           ;signed mul (low 64 bits)
        vmovdqa64 zmmword ptr [r8+128],zmm2     ;save vpmullq result

        vpsllvq zmm2{k1}{z},zmm0,zmm1           ;shift left logical
        vmovdqa64 zmmword ptr [r8+192],zmm2     ;save vpsllvq result

        vpsravq zmm2{k1}{z},zmm0,zmm1           ;shift right arithmetic
        vmovdqa64 zmmword ptr [r8+256],zmm2     ;save vpsravq result

        vpabsq zmm2{k1}{z},zmm0                 ;absolute value
        vmovdqa64 zmmword ptr [r8+320],zmm2     ;save vpabsq result

        vzeroupper
        ret
Avx512PackedMathI64_ endp
        end
