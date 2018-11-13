;-------------------------------------------------
;               Ch13_02.asm
;-------------------------------------------------

        include <cmpequ.asmh>

; extern "C" bool Avx512CalcValues_(double* c, const double* a, const double* b, size_t n);

        .code
Avx512CalcValues_ proc

; Validate n and initialize array index i
        xor eax,eax                         ;set error return code (also i = 0)
        test r9,r9                          ;is n == 0?
        jz Done                             ;jump if n is zero

        vxorpd xmm5,xmm5,xmm5               ;xmm5 = 0.0

; Load next a[i] and b[i], calculate val
@@:     vmovsd xmm0,real8 ptr [rdx+rax*8]   ;xmm0 = a[i];
        vmovsd xmm1,real8 ptr [r8+rax*8]    ;xmm1 = b[i];
        vmulsd xmm2,xmm0,xmm1               ;val = a[i] * b[i]

; Calculate c[i] = (val >= 0.0) ? sqrt(val) : val * val
        vcmpsd k1,xmm2,xmm5,CMP_GE          ;k1[0] = 1 if val >= 0.0
        vsqrtsd xmm3{k1}{z},xmm3,xmm2       ;xmm3 = (val > 0.0) ? sqrt(val) : 0.0
        knotw k2,k1                         ;k2[0] = 1 if val < 0.0
        vmulsd xmm4{k2}{z},xmm2,xmm2        ;xmm4 = (val < 0.0) ? val * val : 0.0
        vorpd xmm0,xmm4,xmm3                ;xmm0 = (val >= 0.0) ? sqrt(val) : val * val
        vmovsd real8 ptr [rcx+rax*8],xmm0   ;save result to c[i]

; Update index i and repeat until done
        inc rax                             ;i += 1
        cmp rax,r9
        jl @B
        mov eax,1                          ;set success return code

Done:   ret
Avx512CalcValues_ endp
        end
