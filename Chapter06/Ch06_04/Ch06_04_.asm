;-------------------------------------------------
;               Ch06_04.asm
;-------------------------------------------------

; extern "C" bool AvxCalcSqrts_(float* y, const float* x, size_t n);

        .code
AvxCalcSqrts_ proc
        xor eax,eax                         ;set error return code (also array offset)

        test r8,r8
        jz Done                             ;jump if n is zero

        test rcx,0fh
        jnz Done                            ;jump if 'y' is not aligned

        test rdx,0fh
        jnz Done                            ;jump if 'x' is not aligned

; Calculate packed square roots
        cmp r8,4
        jb FinalVals                        ;jump if n < 4
@@:     vsqrtps xmm0,xmmword ptr [rdx+rax]  ;calculate 4 square roots x[i+3:i]
        vmovaps xmmword ptr [rcx+rax],xmm0  ;save results to y[i+3:i]

        add rax,16                          ;update offset to next set of values
        sub r8,4
        cmp r8,4                            ;are there 4 or more elements remaining?
        jae @B                              ;jump if yes

; Calculate square roots of final 1 - 3 values, note switch to scalar instructions
FinalVals:
        test r8,r8                          ;more elements to process?
        jz SetRC                            ;jump if no more elements

        vsqrtss xmm0,xmm0,real4 ptr [rdx+rax]   ;calculate sqrt(x[i])
        vmovss real4 ptr [rcx+rax],xmm0         ;save result to y[i]
        add rax,4
        dec r8
        jz SetRC

        vsqrtss xmm0,xmm0,real4 ptr [rdx+rax]
        vmovss real4 ptr [rcx+rax],xmm0
        add rax,4
        dec r8
        jz SetRC

        vsqrtss xmm0,xmm0,real4 ptr [rdx+rax]
        vmovss real4 ptr [rcx+rax],xmm0

SetRC:  mov eax,1                           ;set success return code

Done:   ret
AvxCalcSqrts_ endp
        end
