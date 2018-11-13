;-------------------------------------------------
;               Ch07_05.asm
;-------------------------------------------------

        include <MacrosX86-64-AVX.asmh>
        extern g_NumElementsMax:qword

; extern "C" bool AvxCalcMeanU8_(const Uint8* x, size_t n, int64_t* sum_x, double* mean);
;
; Returns       0 = invalid n or unaligned array, 1 = success

        .code
AvxCalcMeanU8_ proc frame
        _CreateFrame CM_,0,64
        _SaveXmmRegs xmm6,xmm7,xmm8,xmm9
        _EndProlog

; Verify function arguments
        xor eax,eax                         ;set error return code
        or rdx,rdx
        jz Done                             ;jump if n == 0

        cmp rdx,[g_NumElementsMax]
        jae Done                            ;jump if n > NumElementsMax

        test rdx,3fh
        jnz Done                            ;jump if (n % 64) != 0

        test rcx,0fh
        jnz Done                            ;jump if x is not properly aligned

; Perform required initializations
        mov r10,rdx                         ;save n for later use
        add rdx,rcx                         ;rdx = end of array 
        vpxor xmm8,xmm8,xmm8                ;xmm8 = packed intermediate sums (4 dwords)
        vpxor xmm9,xmm9,xmm9                ;xmm9 = packed zero for promotions

; Promote 32 pixel values from bytes to words, then sum the words
@@:     vmovdqa xmm0,xmmword ptr [rcx]
        vmovdqa xmm1,xmmword ptr [rcx+16]   ;xmm1:xmm0 = 32 pixels
        vpunpcklbw xmm2,xmm0,xmm9           ;xmm2 = 8 words
        vpunpckhbw xmm3,xmm0,xmm9           ;xmm3 = 8 words
        vpunpcklbw xmm4,xmm1,xmm9           ;xmm4 = 8 words
        vpunpckhbw xmm5,xmm1,xmm9           ;xmm5 = 8 words
        vpaddw xmm0,xmm2,xmm3
        vpaddw xmm1,xmm4,xmm5
        vpaddw xmm6,xmm0,xmm1               ;xmm6 = packed sums (8 words)

; Promote another 32 pixel values from bytes to words, then sum the words
        vmovdqa xmm0,xmmword ptr [rcx+32]
        vmovdqa xmm1,xmmword ptr [rcx+48]   ;xmm1:xmm0 = 32 pixels
        vpunpcklbw xmm2,xmm0,xmm9           ;xmm2 = 8 words
        vpunpckhbw xmm3,xmm0,xmm9           ;xmm3 = 8 words
        vpunpcklbw xmm4,xmm1,xmm9           ;xmm4 = 8 words
        vpunpckhbw xmm5,xmm1,xmm9           ;xmm5 = 8 words
        vpaddw xmm0,xmm2,xmm3
        vpaddw xmm1,xmm4,xmm5
        vpaddw xmm7,xmm0,xmm1               ;xmm7 = packed sums (8 words)

; Promote packed sums to dwords, then update dword sums
        vpaddw xmm0,xmm6,xmm7               ;xmm0 = packed sums (8 words)
        vpunpcklwd xmm1,xmm0,xmm9           ;xmm1 = packed sums (4 dwords)
        vpunpckhwd xmm2,xmm0,xmm9           ;xmm2 = packed sums (4 dwords)
        vpaddd xmm8,xmm8,xmm1
        vpaddd xmm8,xmm8,xmm2

        add rcx,64                          ;rcx = next 64 byte block
        cmp rcx,rdx
        jne @B                              ;repeat loop if not done

; Compute final sum_x (note vpextrd zero extends extracted dword to 64 bits)
        vpextrd eax,xmm8,0                  ;rax = partial sum 0
        vpextrd edx,xmm8,1                  ;rdx = partial sum 1
        add rax,rdx
        vpextrd ecx,xmm8,2                  ;rcx = partial sum 2
        vpextrd edx,xmm8,3                  ;rdx = partial sum 3
        add rax,rcx
        add rax,rdx
        mov [r8],rax                        ;save sum_x

; Compute mean value
        vcvtsi2sd xmm0,xmm0,rax             ;xmm0 = sum_x (DPFP)
        vcvtsi2sd xmm1,xmm1,r10             ;xmm1 = n (DPFP)
        vdivsd xmm2,xmm0,xmm1               ;calc mean = sum_x / n
        vmovsd real8 ptr [r9],xmm2          ;save mean

        mov eax,1                           ;set success return code

Done:   _RestoreXmmRegs xmm6,xmm7,xmm8,xmm9
        _DeleteFrame
        ret
AvxCalcMeanU8_ endp
        end
