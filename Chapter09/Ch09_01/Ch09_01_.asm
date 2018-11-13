;-------------------------------------------------
;               Ch09_01.asm
;-------------------------------------------------

; Mask values used to calculate floating-point absolute values
            .const
AbsMaskF32  dword 8 dup(7fffffffh)
AbsMaskF64  qword 4 dup(7fffffffffffffffh)

; extern "C" void AvxPackedMathF32_(const YmmVal& a, const YmmVal& b, YmmVal c[8]);

            .code
AvxPackedMathF32_ proc

; Load packed SP floating-point values
        vmovaps ymm0,ymmword ptr [rcx]      ;ymm0 = *a
        vmovaps ymm1,ymmword ptr [rdx]      ;ymm1 = *b

; Packed SP floating-point addition
        vaddps ymm2,ymm0,ymm1
        vmovaps ymmword ptr [r8],ymm2

; Packed SP floating-point subtraction
        vsubps ymm2,ymm0,ymm1
        vmovaps ymmword ptr [r8+32],ymm2

; Packed SP floating-point multiplication
        vmulps ymm2,ymm0,ymm1
        vmovaps ymmword ptr [r8+64],ymm2

; Packed SP floating-point division
        vdivps ymm2,ymm0,ymm1
        vmovaps ymmword ptr [r8+96],ymm2

; Packed SP floating-point absolute value (b)
        vandps ymm2,ymm1,ymmword ptr [AbsMaskF32]
        vmovaps ymmword ptr [r8+128],ymm2

; Packed SP floating-point square root (a)
        vsqrtps ymm2,ymm0
        vmovaps ymmword ptr [r8+160],ymm2

; Packed SP floating-point minimum
        vminps ymm2,ymm0,ymm1
        vmovaps ymmword ptr [r8+192],ymm2

; Packed SP floating-point maximum
        vmaxps ymm2,ymm0,ymm1
        vmovaps ymmword ptr [r8+224],ymm2

        vzeroupper
        ret
AvxPackedMathF32_ endp

; extern "C" void AvxPackedMathF64_(const YmmVal& a, const YmmVal& b, YmmVal c[8]);

AvxPackedMathF64_ proc

; Load packed DP floating-point values
        vmovapd ymm0,ymmword ptr [rcx]       ;ymm0 = *a
        vmovapd ymm1,ymmword ptr [rdx]       ;ymm1 = *b

; Packed DP floating-point addition
        vaddpd ymm2,ymm0,ymm1
        vmovapd ymmword ptr [r8],ymm2

; Packed DP floating-point subtraction
        vsubpd ymm2,ymm0,ymm1
        vmovapd ymmword ptr [r8+32],ymm2

; Packed DP floating-point multiplication
        vmulpd ymm2,ymm0,ymm1
        vmovapd ymmword ptr [r8+64],ymm2

; Packed DP floating-point division
        vdivpd ymm2,ymm0,ymm1
        vmovapd ymmword ptr [r8+96],ymm2

; Packed DP floating-point absolute value (b)
        vandpd ymm2,ymm1,ymmword ptr [AbsMaskF64]
        vmovapd ymmword ptr [r8+128],ymm2

; Packed DP floating-point square root (a)
        vsqrtpd ymm2,ymm0
        vmovapd ymmword ptr [r8+160],ymm2

; Packed DP floating-point minimum
        vminpd ymm2,ymm0,ymm1
        vmovapd ymmword ptr [r8+192],ymm2

; Packed DP floating-point maximum
        vmaxpd ymm2,ymm0,ymm1
        vmovapd ymmword ptr [r8+224],ymm2

        vzeroupper
        ret
AvxPackedMathF64_ endp
        end
