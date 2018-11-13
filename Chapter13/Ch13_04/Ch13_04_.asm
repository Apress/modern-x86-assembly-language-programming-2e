;-------------------------------------------------
;               Ch13_04.asm
;-------------------------------------------------

; Mask values used to calculate floating-point absolute values
ConstVals   segment readonly align(64) 'const'
AbsMaskF32  dword 16 dup(7fffffffh)
AbsMaskF64  qword 8 dup(7fffffffffffffffh)
ConstVals   ends

; extern "C" void Avx512PackedMathF32_(const ZmmVal* a, const ZmmVal* b, ZmmVal c[8]);

            .code
Avx512PackedMathF32_ proc

; Load packed SP floating-point values
        vmovaps zmm0,zmmword ptr [rcx]      ;zmm0 = *a
        vmovaps zmm1,zmmword ptr [rdx]      ;zmm1 = *b

; Packed SP floating-point addition
        vaddps zmm2,zmm0,zmm1
        vmovaps zmmword ptr [r8+0],zmm2

; Packed SP floating-point subtraction
        vsubps zmm2,zmm0,zmm1
        vmovaps zmmword ptr [r8+64],zmm2

; Packed SP floating-point multiplication
        vmulps zmm2,zmm0,zmm1
        vmovaps zmmword ptr [r8+128],zmm2

; Packed SP floating-point division
        vdivps zmm2,zmm0,zmm1
        vmovaps zmmword ptr [r8+192],zmm2

; Packed SP floating-point absolute value (b)
        vandps zmm2,zmm1,zmmword ptr [AbsMaskF32]
        vmovaps zmmword ptr [r8+256],zmm2

; Packed SP floating-point square root (a)
        vsqrtps zmm2,zmm0
        vmovaps zmmword ptr [r8+320],zmm2

; Packed SP floating-point minimum
        vminps zmm2,zmm0,zmm1
        vmovaps zmmword ptr [r8+384],zmm2

; Packed SP floating-point maximum
        vmaxps zmm2,zmm0,zmm1
        vmovaps zmmword ptr [r8+448],zmm2

        vzeroupper
        ret
Avx512PackedMathF32_ endp

; extern "C" void Avx512PackedMathF64_(const ZmmVal* a, const ZmmVal* b, ZmmVal c[8]);

Avx512PackedMathF64_ proc

; Load packed DP floating-point values
        vmovapd zmm0,zmmword ptr [rcx]       ;zmm0 = *a
        vmovapd zmm1,zmmword ptr [rdx]       ;zmm1 = *b

; Packed DP floating-point addition
        vaddpd zmm2,zmm0,zmm1
        vmovapd zmmword ptr [r8+0],zmm2

; Packed DP floating-point subtraction
        vsubpd zmm2,zmm0,zmm1
        vmovapd zmmword ptr [r8+64],zmm2

; Packed DP floating-point multiplication
        vmulpd zmm2,zmm0,zmm1
        vmovapd zmmword ptr [r8+128],zmm2

; Packed DP floating-point division
        vdivpd zmm2,zmm0,zmm1
        vmovapd zmmword ptr [r8+192],zmm2

; Packed DP floating-point absolute value (b)
        vandpd zmm2,zmm1,zmmword ptr [AbsMaskF64]
        vmovapd zmmword ptr [r8+256],zmm2

; Packed DP floating-point square root (a)
        vsqrtpd zmm2,zmm0
        vmovapd zmmword ptr [r8+320],zmm2

; Packed DP floating-point minimum
        vminpd zmm2,zmm0,zmm1
        vmovapd zmmword ptr [r8+384],zmm2

; Packed DP floating-point maximum
        vmaxpd zmm2,zmm0,zmm1
        vmovapd zmmword ptr [r8+448],zmm2

        vzeroupper
        ret
Avx512PackedMathF64_ endp
        end