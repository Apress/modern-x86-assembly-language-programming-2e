;-------------------------------------------------
;               Ch16_02.asm
;-------------------------------------------------

; _CalcResult Macro
;
; The following macro contains a simple calculating loop that is used
; to compare performance of the vmovaps and vmovntps instructions.

_CalcResult macro MovInstr

; Load and validate arguments
        xor eax,eax                         ;set error code
        test r9,r9
        jz Done                             ;jump if n <= 0
        test r9,0fh
        jnz Done                            ;jump if (n % 16) != 0

        test rcx,1fh
        jnz Done                            ;jump if c is not aligned
        test rdx,1fh
        jnz Done                            ;jump if a is not aligned
        test r8,1fh
        jnz Done                            ;jump if b is not aligned

; Calculate c[i] = sqrt(a[i] * a[i] + b[i] * b[i])
        align 16
@@:     vmovaps ymm0,ymmword ptr [rdx+rax]      ;ymm0 = a[i+7]:a[i]
        vmovaps ymm1,ymmword ptr [r8+rax]       ;ymm1 = b[i+7]:b[i]
        vmulps ymm2,ymm0,ymm0                   ;ymm2 = a[i] * a[i]
        vmulps ymm3,ymm1,ymm1                   ;ymm3 = b[i] * b[i]
        vaddps ymm4,ymm2,ymm3                   ;ymm4 = sum
        vsqrtps ymm5,ymm4                       ;ymm5 = final result
        MovInstr ymmword ptr [rcx+rax],ymm5     ;save final values to c

        vmovaps ymm0,ymmword ptr [rdx+rax+32]   ;ymm0 = a[i+15]:a[i+8]
        vmovaps ymm1,ymmword ptr [r8+rax+32]    ;ymm1 = b[i+15]:b[i+8]
        vmulps ymm2,ymm0,ymm0                   ;ymm2 = a[i] * a[i]
        vmulps ymm3,ymm1,ymm1                   ;ymm3 = b[i] * b[i]
        vaddps ymm4,ymm2,ymm3                   ;ymm4 = sum
        vsqrtps ymm5,ymm4                       ;ymm5 = final result
        MovInstr ymmword ptr [rcx+rax+32],ymm5  ;save final values to c

        add rax,64                              ;update offset
        sub r9,16                               ;update counter
        jnz @B

        mov eax,1                              ;set success return code

Done:   vzeroupper
        ret
        endm

; extern bool CalcResultA_(float* c, const float* a, const float* b, size_t n)

        .code
CalcResultA_ proc
        _CalcResult vmovaps
CalcResultA_ endp

; extern bool CalcResultB_(float* c, const float* a, const float* b, int n)

CalcResultB_ proc
        _CalcResult vmovntps
CalcResultB_ endp
        end
