;-------------------------------------------------
;               Ch14_05.asm
;-------------------------------------------------

        include <MacrosX86-64-AVX.asmh>
        extern c_NumPixelsMin:dword
        extern c_NumPixelsMax:dword

            .const
r4_0p5      real4 0.5
r4_255p0    real4 255.0

; extern "C" bool Avx512RgbToGs_(uint8_t* pb_gs, const uint8_t* const* pb_rgb, int num_pixels, const float coef[3]);

        .code
Avx512RgbToGs_ proc frame
        _CreateFrame RGBGS0_,0,96,r13,r14,r15
        _SaveXmmRegs xmm10,xmm11,xmm12,xmm13,xmm14,xmm15
        _EndProlog

        xor eax,eax                         ;error return code (also pixel_buffer offset)
        cmp r8d,[c_NumPixelsMin]
        jl Done                             ;jump if num_pixels < min value
        cmp r8d,[c_NumPixelsMax]
        jg Done                             ;jump if num_pixels > max value
        test r8d,3fh
        jnz Done                            ;jump if (num_pixels % 64) != 0

        test rcx,3fh
        jnz Done                            ;jump if pb_gs is not aligned

        mov r13,[rdx]
        test r13,3fh
        jnz Done                            ;jump if pb_r is not aligned
        mov r14,[rdx+8]
        test r14,3fh
        jnz Done                            ;jump if pb_g is not aligned
        mov r15,[rdx+16]
        test r15,3fh
        jnz Done                            ;jump if pb_b is not aligned

; Perform required initializations
        vbroadcastss zmm10,real4 ptr [r9]       ;zmm10 = packed coef[0]
        vbroadcastss zmm11,real4 ptr [r9+4]     ;zmm11 = packed coef[1]
        vbroadcastss zmm12,real4 ptr [r9+8]     ;zmm12 = packed coef[2]
        vbroadcastss zmm13,real4 ptr [r4_0p5]   ;zmm13 = packed 0.5
        vbroadcastss zmm14,real4 ptr [r4_255p0] ;zmm14 = packed 255.0
        vxorps zmm15,zmm15,zmm15                ;zmm15 = packed 0.0
        mov r8d,r8d                             ;r8 = num_pixels
        mov r10,16                              ;r10 - number of pixels / iteration

; Load next block of pixels
        align 16
@@:     vpmovzxbd zmm0,xmmword ptr [r13+rax]    ;zmm0 = 16 pixels (r values)
        vpmovzxbd zmm1,xmmword ptr [r14+rax]    ;zmm1 = 16 pixels (g values)
        vpmovzxbd zmm2,xmmword ptr [r15+rax]    ;zmm2 = 16 pixels (b values)

; Convert dword values to SPFP and multiply by coefficients
        vcvtdq2ps zmm0,zmm0                 ;zmm0 = 16 pixels SPFP (r values)
        vcvtdq2ps zmm1,zmm1                 ;zmm1 = 16 pixels SPFP (g values)
        vcvtdq2ps zmm2,zmm2                 ;zmm2 = 16 pixels SPFP (b values)
        vmulps zmm0,zmm0,zmm10              ;zmm0 = r values * coef[0]
        vmulps zmm1,zmm1,zmm11              ;zmm1 = g values * coef[1]
        vmulps zmm2,zmm2,zmm12              ;zmm2 = b values * coef[2]

; Sum color components & clip values to [0.0, 255.0]
        vaddps zmm3,zmm0,zmm1               ;r + g
        vaddps zmm4,zmm3,zmm2               ;r + g + b
        vaddps zmm5,zmm4,zmm13              ;r + g + b + 0.5                
        vminps zmm0,zmm5,zmm14              ;clip pixels above 255.0
        vmaxps zmm1,zmm0,zmm15              ;clip pixels below 0.0

; Convert grayscale values from SPFP to byte, save results
        vcvtps2dq zmm2,zmm1                 ;convert SPFP values to dwords

        vpmovusdb xmm3,zmm2                 ;convert to bytes
        vmovdqa xmmword ptr [rcx+rax],xmm3  ;save grayscale image pixels

        add rax,r10
        sub r8,r10
        jnz @B

        mov eax,1                           ;set success return code
Done:   vzeroupper
        _RestoreXmmRegs xmm10,xmm11,xmm12,xmm13,xmm14,xmm15
        _DeleteFrame r13,r14,r15
        ret
Avx512RgbToGs_ endp

; extern "C" bool Avx2RgbToGs_(uint8_t* pb_gs, const uint8_t* const* pb_rgb, int num_pixels, const float coef[3]);

        .code
Avx2RgbToGs_ proc frame
        _CreateFrame RGBGS1_,0,96,r13,r14,r15
        _SaveXmmRegs xmm10,xmm11,xmm12,xmm13,xmm14,xmm15
        _EndProlog

        xor eax,eax                         ;error return code (also pixel_buffer offset)
        cmp r8d,[c_NumPixelsMin]
        jl Done                             ;jump if num_pixels < min value
        cmp r8d,[c_NumPixelsMax]
        jg Done                             ;jump if num_pixels > max value
        test r8d,3fh
        jnz Done                            ;jump if (num_pixels % 64) != 0

        test rcx,3fh
        jnz Done                            ;jump if pb_gs is not aligned

        mov r13,[rdx]
        test r13,3fh
        jnz Done                            ;jump if pb_r is not aligned
        mov r14,[rdx+8]
        test r14,3fh
        jnz Done                            ;jump if pb_g is not aligned
        mov r15,[rdx+16]
        test r15,3fh
        jnz Done                            ;jump if pb_b is not aligned

; Perform required initializations
        vbroadcastss ymm10,real4 ptr [r9]       ;ymm10 = packed coef[0]
        vbroadcastss ymm11,real4 ptr [r9+4]     ;ymm11 = packed coef[1]
        vbroadcastss ymm12,real4 ptr [r9+8]     ;ymm12 = packed coef[2]
        vbroadcastss ymm13,real4 ptr [r4_0p5]   ;ymm13 = packed 0.5
        vbroadcastss ymm14,real4 ptr [r4_255p0] ;ymm14 = packed 255.0
        vxorps ymm15,ymm15,ymm15                ;ymm15 = packed 0.0
        mov r8d,r8d                             ;r8 = num_pixels
        mov r10,8                               ;r10 - number of pixels / iteration

; Load next block of pixels
        align 16
@@:     vpmovzxbd ymm0,qword ptr [r13+rax]      ;ymm0 = 8 pixels (r values)
        vpmovzxbd ymm1,qword ptr [r14+rax]      ;ymm1 = 8 pixels (g values)
        vpmovzxbd ymm2,qword ptr [r15+rax]      ;ymm2 = 8 pixels (b values)

; Convert dword values to SPFP and multiply by coefficients
        vcvtdq2ps ymm0,ymm0                 ;ymm0 = 8 pixels SPFP (r values)
        vcvtdq2ps ymm1,ymm1                 ;ymm1 = 8 pixels SPFP (g values)
        vcvtdq2ps ymm2,ymm2                 ;ymm2 = 8 pixels SPFP (b values)
        vmulps ymm0,ymm0,ymm10              ;ymm0 = r values * coef[0]
        vmulps ymm1,ymm1,ymm11              ;ymm1 = g values * coef[1]
        vmulps ymm2,ymm2,ymm12              ;ymm2 = b values * coef[2]

; Sum color components & clip values to [0.0, 255.0]
        vaddps ymm3,ymm0,ymm1               ;r + g
        vaddps ymm4,ymm3,ymm2               ;r + g + b
        vaddps ymm5,ymm4,ymm13              ;r + g + b + 0.5                
        vminps ymm0,ymm5,ymm14              ;clip pixels above 255.0
        vmaxps ymm1,ymm0,ymm15              ;clip pixels below 0.0

; Convert grayscale components from SPFP to byte, save results
        vcvtps2dq ymm2,ymm1                 ;convert SPFP values to dwords

        vpackusdw ymm3,ymm2,ymm2
        vextracti128 xmm4,ymm3,1
        vpackuswb xmm5,xmm3,xmm4            ;byte GS pixels in xmm5[31:0] and xmm5[95:64]
        vpextrd r11d,xmm5,0                 ;r11d = 4 grayscale pixels
        mov dword ptr [rcx+rax],r11d        ;save grayscale image pixels
        vpextrd r11d,xmm5,2                 ;r11d = 4 grayscale pixels
        mov dword ptr [rcx+rax+4],r11d      ;save grayscale image pixels

        add rax,r10
        sub r8,r10
        jnz @B

        mov eax,1                           ;set success return code
Done:   vzeroupper
        _RestoreXmmRegs xmm10,xmm11,xmm12,xmm13,xmm14,xmm15
        _DeleteFrame r13,r14,r15
        ret
Avx2RgbToGs_ endp
        end
