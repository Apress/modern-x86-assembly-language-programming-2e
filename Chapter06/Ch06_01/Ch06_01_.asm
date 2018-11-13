;-------------------------------------------------
;               Ch06_01.asm
;-------------------------------------------------

            .const
            align 16
AbsMaskF32  dword 7fffffffh, 7fffffffh, 7fffffffh, 7fffffffh  ;Absolute value mask for SPFP
AbsMaskF64  qword 7fffffffffffffffh, 7fffffffffffffffh        ;Absolute value mask for DPFP

; extern "C" void AvxPackedMathF32_(const XmmVal& a, const XmmVal& b, XmmVal c[8]);

            .code
AvxPackedMathF32_ proc
; Load packed SPFP values
        vmovaps xmm0,xmmword ptr [rcx]       ;xmm0 = a
        vmovaps xmm1,xmmword ptr [rdx]       ;xmm1 = b

; Packed SPFP addition
        vaddps xmm2,xmm0,xmm1
        vmovaps [r8+0],xmm2

; Packed SPFP subtraction
        vsubps xmm2,xmm0,xmm1
        vmovaps [r8+16],xmm2

; Packed SPFP multiplication
        vmulps xmm2,xmm0,xmm1
        vmovaps [r8+32],xmm2

; Packed SPFP division
        vdivps xmm2,xmm0,xmm1
        vmovaps [r8+48],xmm2

; Packed SPFP absolute value (b)
        vandps xmm2,xmm1,xmmword ptr [AbsMaskF32]
        vmovaps [r8+64],xmm2

; Packed SPFP square root (a)
        vsqrtps xmm2,xmm0
        vmovaps [r8+80],xmm2

; Packed SPFP minimum
        vminps xmm2,xmm0,xmm1
        vmovaps [r8+96],xmm2

; Packed SPFP maximum
        vmaxps xmm2,xmm0,xmm1
        vmovaps [r8+112],xmm2
        ret
AvxPackedMathF32_ endp

; extern "C" void AvxPackedMathF64_(const XmmVal& a, const XmmVal& b, XmmVal c[8]);

AvxPackedMathF64_ proc
; Load packed DPFP values
        vmovapd xmm0,xmmword ptr [rcx]       ;xmm0 = a
        vmovapd xmm1,xmmword ptr [rdx]       ;xmm1 = b

; Packed DPFP addition
        vaddpd xmm2,xmm0,xmm1
        vmovapd [r8+0],xmm2

; Packed DPFP subtraction
        vsubpd xmm2,xmm0,xmm1
        vmovapd [r8+16],xmm2

; Packed DPFP multiplication
        vmulpd xmm2,xmm0,xmm1
        vmovapd [r8+32],xmm2

; Packed DPFP division
        vdivpd xmm2,xmm0,xmm1
        vmovapd [r8+48],xmm2

; Packed DPFP absolute value (b)
        vandpd xmm2,xmm1,xmmword ptr [AbsMaskF64]
        vmovapd [r8+64],xmm2

; Packed DPFP square root (a)
        vsqrtpd xmm2,xmm0
        vmovapd [r8+80],xmm2

; Packed DPFP minimum
        vminpd xmm2,xmm0,xmm1
        vmovapd [r8+96],xmm2

; Packed DPFP maximum
        vmaxpd xmm2,xmm0,xmm1
        vmovapd [r8+112],xmm2
        ret
AvxPackedMathF64_ endp
        end
