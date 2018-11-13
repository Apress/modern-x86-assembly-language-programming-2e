;-------------------------------------------------
;               Ch07_06.asm
;-------------------------------------------------

        include <MacrosX86-64-AVX.asmh>
        include <cmpequ.asmh>

                    .const
                    align 16
Uint8ToFloat        real4 255.0, 255.0, 255.0, 255.0
FloatToUint8Min     real4 0.0, 0.0, 0.0, 0.0
FloatToUint8Max     real4 1.0, 1.0, 1.0, 1.0
FloatToUint8Scale   real4 255.0, 255.0, 255.0, 255.0

        extern c_NumPixelsMax:dword

; extern "C" bool ConvertImgU8ToF32_(float* des, const uint8_t* src, uint32_t num_pixels)

        .code
ConvertImgU8ToF32_ proc frame
        _CreateFrame U2F_,0,160
        _SaveXmmRegs xmm6,xmm7,xmm8,xmm9,xmm10,xmm11,xmm12,xmm13,xmm14,xmm15
        _EndProlog

; Make sure num_pixels is valid and pixel buffers are properly aligned
        xor eax,eax                         ;set error return code
        or r8d,r8d
        jz Done                             ;jump if num_pixels is zero
        cmp r8d,[c_NumPixelsMax]
        ja Done                             ;jump if num_pixels too big
        test r8d,1fh
        jnz Done                            ;jump if num_pixels % 32 != 0
        test rcx,0fh
        jnz Done                            ;jump if des not aligned
        test rdx,0fh
        jnz Done                            ;jump if src not aligned

; Initialize processing loop registers
        shr r8d,5                               ;number of pixel blocks
        vmovaps xmm6,xmmword ptr [Uint8ToFloat] ;xmm6 = packed 255.0f
        vpxor xmm7,xmm7,xmm7                    ;xmm7 = packed 0

; Load the next block of 32 pixels
@@:     vmovdqa xmm0,xmmword ptr [rdx]      ;xmm0 = 16 pixels (x[i+15]:x[i])
        vmovdqa xmm1,xmmword ptr [rdx+16]   ;xmm8 = 16 pixels (x[i+31]:x[i+16])

; Promote the pixel values in xmm0 from unsigned bytes to unsigned dwords
        vpunpcklbw xmm2,xmm0,xmm7
        vpunpckhbw xmm3,xmm0,xmm7
        vpunpcklwd xmm8,xmm2,xmm7
        vpunpckhwd xmm9,xmm2,xmm7
        vpunpcklwd xmm10,xmm3,xmm7
        vpunpckhwd xmm11,xmm3,xmm7          ;xmm11:xmm8 = 16 dword pixels

; Promote the pixel values in xmm1 from unsigned bytes to unsigned dwords
        vpunpcklbw xmm2,xmm1,xmm7
        vpunpckhbw xmm3,xmm1,xmm7
        vpunpcklwd xmm12,xmm2,xmm7
        vpunpckhwd xmm13,xmm2,xmm7
        vpunpcklwd xmm14,xmm3,xmm7
        vpunpckhwd xmm15,xmm3,xmm7          ;xmm15:xmm12 = 16 dword pixels

; Convert pixel values from dwords to SPFP
        vcvtdq2ps xmm8,xmm8
        vcvtdq2ps xmm9,xmm9
        vcvtdq2ps xmm10,xmm10
        vcvtdq2ps xmm11,xmm11               ;xmm11:xmm8 = 16 SPFP pixels

        vcvtdq2ps xmm12,xmm12
        vcvtdq2ps xmm13,xmm13
        vcvtdq2ps xmm14,xmm14
        vcvtdq2ps xmm15,xmm15               ;xmm15:xmm12 = 16 SPFP pixels

; Normalize all pixel values to [0.0, 1.0] and save the results
        vdivps xmm0,xmm8,xmm6
        vmovaps xmmword ptr [rcx],xmm0      ;save pixels 0 - 3
        vdivps xmm1,xmm9,xmm6
        vmovaps xmmword ptr [rcx+16],xmm1   ;save pixels 4 - 7
        vdivps xmm2,xmm10,xmm6
        vmovaps xmmword ptr [rcx+32],xmm2   ;save pixels 8 - 11
        vdivps xmm3,xmm11,xmm6
        vmovaps xmmword ptr [rcx+48],xmm3   ;save pixels 12 - 15

        vdivps xmm0,xmm12,xmm6
        vmovaps xmmword ptr [rcx+64],xmm0   ;save pixels 16 - 19
        vdivps xmm1,xmm13,xmm6
        vmovaps xmmword ptr [rcx+80],xmm1   ;save pixels 20 - 23
        vdivps xmm2,xmm14,xmm6
        vmovaps xmmword ptr [rcx+96],xmm2   ;save pixels 24 - 27
        vdivps xmm3,xmm15,xmm6
        vmovaps xmmword ptr [rcx+112],xmm3  ;save pixels 28 - 31

        add rdx,32                          ;update src ptr
        add rcx,128                         ;update des ptr
        sub r8d,1
        jnz @B                              ;repeat until done
        mov eax,1                           ;set success return code

Done:   _RestoreXmmRegs xmm6,xmm7,xmm8,xmm9,xmm10,xmm11,xmm12,xmm13,xmm14,xmm15
        _DeleteFrame
        ret

ConvertImgU8ToF32_ endp

; extern "C" bool ConvertImgF32ToU8_(uint8_t* des, const float* src, uint32_t num_pixels)

ConvertImgF32ToU8_ proc frame
        _CreateFrame F2U_,0,96
        _SaveXmmRegs xmm6,xmm7,xmm12,xmm13,xmm14,xmm15
        _EndProlog

; Make sure num_pixels is valid and pixel buffers are properly aligned
        xor eax,eax                         ;set error return code
        or r8d,r8d
        jz Done                             ;jump if num_pixels is zero
        cmp r8d,[c_NumPixelsMax] 
        ja Done                             ;jump if num_pixels too big
        test r8d,1fh
        jnz Done                            ;jump if num_pixels % 32 != 0
        test rcx,0fh
        jnz Done                            ;jump if des not aligned
        test rdx,0fh
        jnz Done                            ;jump if src not aligned

; Load required packed constants into registers
        vmovaps xmm13,xmmword ptr [FloatToUint8Scale] ;xmm13 = packed 255.0
        vmovaps xmm14,xmmword ptr [FloatToUint8Min]   ;xmm14 = packed 0.0
        vmovaps xmm15,xmmword ptr [FloatToUint8Max]   ;xmm15 = packed 1.0

        shr r8d,4                           ;number of pixel blocks
LP1:    mov r9d,4                           ;num pixel quartets per block

; Convert 16 float pixels to uint8_t
LP2:    vmovaps xmm0,xmmword ptr [rdx]      ;xmm0 = next pixel quartet
        vcmpps xmm1,xmm0,xmm14,CMP_LT       ;compare pixels to 0.0
        vandnps xmm2,xmm1,xmm0              ;clip pixels < 0.0 to 0.0

        vcmpps xmm3,xmm2,xmm15,CMP_GT       ;compare pixels to 1.0
        vandps xmm4,xmm3,xmm15              ;clip pixels > 1.0 to 1.0
        vandnps xmm5,xmm3,xmm2              ;xmm5 = pixels <= 1.0
        vorps xmm6,xmm5,xmm4                ;xmm6 = final clipped pixels
        vmulps xmm7,xmm6,xmm13              ;xmm7 = FP pixels [0.0, 255.0]

        vcvtps2dq xmm0,xmm7                 ;xmm0 = dword pixels [0, 255]
        vpackusdw xmm1,xmm0,xmm0            ;xmm1[63:0] = word pixels
        vpackuswb xmm2,xmm1,xmm1            ;xmm2[31:0] = bytes pixels

; Save the current byte pixel quartet
        vpextrd eax,xmm2,0                  ;eax = new pixel quartet
        vpsrldq xmm12,xmm12,4               ;adjust xmm12 for new quartet
        vpinsrd xmm12,xmm12,eax,3           ;xmm12[127:96] = new quartet

        add rdx,16                          ;update src ptr
        sub r9d,1
        jnz LP2                             ;repeat until done

; Save the current byte pixel block (16 pixels)
        vmovdqa xmmword ptr [rcx],xmm12     ;save current pixel block
        add rcx,16                          ;update des ptr
        sub r8d,1
        jnz LP1                             ;repeat until done
        mov eax,1                           ;set success return code

Done:   _RestoreXmmRegs xmm6,xmm7,xmm12,xmm13,xmm14,xmm15
        _DeleteFrame
        ret
ConvertImgF32ToU8_ endp
        end
