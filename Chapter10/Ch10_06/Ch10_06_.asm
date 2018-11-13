;-------------------------------------------------
;               Ch10_06.asm
;-------------------------------------------------

        include <MacrosX86-64-AVX.asmh>

                .const
GsMask          dword 0ffffffffh, 0, 0, 0, 0ffffffffh, 0, 0, 0
r4_0p5          real4 0.5
r4_255p0        real4 255.0

                extern c_NumPixelsMin:dword
                extern c_NumPixelsMax:dword

; extern "C" bool Avx2ConvertRgbToGs_(uint8_t* pb_gs, const RGB32* pb_rgb, int num_pixels, const float coef[4])
;
; Note: Memory pointed to by pb_rgb is ordered as follows:
;       R(0,0), G(0,0), B(0,0), A(0,0), R(0,1), G(0,1), B(0,1), A(0,1), ...

        .code
Avx2ConvertRgbToGs_ proc frame
        _CreateFrame RGBGS_,0,112
        _SaveXmmRegs xmm6,xmm7,xmm11,xmm12,xmm13,xmm14,xmm15
        _EndProlog

; Validate argument values
        xor eax,eax                         ;set error return code
        cmp r8d,[c_NumPixelsMin]
        jl Done                             ;jump if num_pixels < min value
        cmp r8d,[c_NumPixelsMax]
        jg Done                             ;jump if num_pixels > max value
        test r8d,7
        jnz Done                            ;jump if (num_pixels % 8) != 0

        test rcx,1fh
        jnz Done                            ;jump if pb_gs is not aligned
        test rdx,1fh
        jnz Done                            ;jump if pb_rgb is not aligned

; Perform required initializations
        vbroadcastss ymm11,real4 ptr [r4_255p0]     ;ymm11 = packed 255.0
        vbroadcastss ymm12,real4 ptr [r4_0p5]       ;ymm12 = packed 0.5
        vpxor ymm13,ymm13,ymm13                     ;ymm13 = packed zero

        vmovups xmm0,xmmword ptr [r9]
        vperm2f128 ymm14,ymm0,ymm0,00000000b        ;ymm14 = packed coef

        vmovups ymm15,ymmword ptr [GsMask]          ;ymm15 = GsMask (SPFP)

; Load next 8 RGB32 pixel values (P0 - P7)
        align 16
@@:     vmovdqa ymm0,ymmword ptr [rdx]      ;ymm0 = 8 rgb32 pixels (P7 - P0)

; Size-promote RGB32 color components from bytes to dwords
        vpunpcklbw ymm1,ymm0,ymm13
        vpunpckhbw ymm2,ymm0,ymm13
        vpunpcklwd ymm3,ymm1,ymm13          ;ymm3 = P1, P0 (dword)
        vpunpckhwd ymm4,ymm1,ymm13          ;ymm4 = P3, P2 (dword)
        vpunpcklwd ymm5,ymm2,ymm13          ;ymm5 = P5, P4 (dword)
        vpunpckhwd ymm6,ymm2,ymm13          ;ymm6 = P7, P6 (dword)

; Convert color component values to single-precision floating-point
        vcvtdq2ps ymm0,ymm3                 ;ymm0 = P1, P0 (SPFP)
        vcvtdq2ps ymm1,ymm4                 ;ymm1 = P3, P2 (SPFP)
        vcvtdq2ps ymm2,ymm5                 ;ymm2 = P5, P4 (SPFP)
        vcvtdq2ps ymm3,ymm6                 ;ymm3 = P7, P6 (SPFP)

; Multiply color component values by color conversion coefficients
        vmulps ymm0,ymm0,ymm14
        vmulps ymm1,ymm1,ymm14
        vmulps ymm2,ymm2,ymm14
        vmulps ymm3,ymm3,ymm14

; Sum weighted color components for final grayscale values
        vhaddps ymm4,ymm0,ymm0
        vhaddps ymm4,ymm4,ymm4              ;ymm4[159:128] = P1, ymm4[31:0] = P0
        vhaddps ymm5,ymm1,ymm1
        vhaddps ymm5,ymm5,ymm5              ;ymm5[159:128] = P3, ymm4[31:0] = P2
        vhaddps ymm6,ymm2,ymm2
        vhaddps ymm6,ymm6,ymm6              ;ymm6[159:128] = P5, ymm4[31:0] = P4
        vhaddps ymm7,ymm3,ymm3
        vhaddps ymm7,ymm7,ymm7              ;ymm7[159:128] = P7, ymm4[31:0] = P6

; Merge SPFP grayscale values into a single YMM register
        vandps ymm4,ymm4,ymm15              ;mask out unneeded SPFP values
        vandps ymm5,ymm5,ymm15
        vandps ymm6,ymm6,ymm15
        vandps ymm7,ymm7,ymm15
        vpslldq ymm5,ymm5,4
        vpslldq ymm6,ymm6,8
        vpslldq ymm7,ymm7,12
        vorps ymm0,ymm4,ymm5                ;merge values
        vorps ymm1,ymm6,ymm7
        vorps ymm2,ymm0,ymm1                ;ymm2 = 8 GS pixel values (SPFP)

; Add 0.5 rounding factor and clip to 0.0 - 255.0
        vaddps ymm2,ymm2,ymm12              ;add 0.5f rounding factor
        vminps ymm3,ymm2,ymm11              ;clip pixels above 255.0
        vmaxps ymm4,ymm3,ymm13              ;clip pixels below 0.0

; Convert SPFP values to bytes and save
        vcvtps2dq ymm3,ymm2                 ;convert GS SPFP to dwords
        vpackusdw ymm4,ymm3,ymm13           ;convert GS dwords to words
        vpackuswb ymm5,ymm4,ymm13           ;convert GS words to bytes

        vperm2i128 ymm6,ymm13,ymm5,3        ;xmm5 = GS P3:P0, xmm6 = GS P7:P4

        vmovd dword ptr [rcx],xmm5          ;save P3 - P0
        vmovd dword ptr [rcx+4],xmm6        ;save P7 - P4

        add rdx,32                          ;update pb_rgb to next block
        add rcx,8                           ;update pb_gs to next block
        sub r8d,8                           ;num_pixels -= 8
        jnz @B                              ;repeat until done

        mov eax,1                           ;set success return code

Done:  vzeroupper
        _RestoreXmmRegs xmm6,xmm7,xmm11,xmm12,xmm13,xmm14,xmm15
        _DeleteFrame
        ret
Avx2ConvertRgbToGs_ endp
        end
