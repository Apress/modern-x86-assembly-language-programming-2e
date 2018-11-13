;-------------------------------------------------
;               Ch06_06.asm
;-------------------------------------------------

        include <MacrosX86-64-AVX.asmh>

        extern LsEpsilon:real8              ;global value defined in C++ file

; extern "C" bool AvxCalcLeastSquares_(const double* x, const double* y, int n, double* m, double* b);
;
; Returns       0 = error (invalid n or improperly aligned array), 1 = success

        .const
        align 16
AbsMaskF64  qword 7fffffffffffffffh, 7fffffffffffffffh  ;mask for DPFP absolute value

        .code
AvxCalcLeastSquares_ proc frame
        _CreateFrame LS_,0,48,rbx
        _SaveXmmRegs xmm6,xmm7,xmm8
        _EndProlog

; Validate arguments
        xor eax,eax                         ;set error return code
        cmp r8d,2
        jl Done                             ;jump if n < 2
        test rcx,0fh
        jnz Done                            ;jump if x not aligned to 16-byte boundary
        test rdx,0fh
        jnz Done                            ;jump if y not aligned to 16-byte boundary

; Perform required initializations
        vcvtsi2sd xmm3,xmm3,r8d             ;xmm3 = n
        mov eax,r8d
        and r8d,0fffffffeh                  ;rd8 = n / 2 * 2
        and eax,1                           ;eax = n % 2

        vxorpd xmm4,xmm4,xmm4               ;sum_x (both qwords)
        vxorpd xmm5,xmm5,xmm5               ;sum_y (both qwords)
        vxorpd xmm6,xmm6,xmm6               ;sum_xx (both qwords)
        vxorpd xmm7,xmm7,xmm7               ;sum_xy (both qwords)

        xor ebx,ebx                         ;rbx = array offset
        mov r10,[rbp+LS_OffsetStackArgs]    ;r10 = b

; Calculate sum variables. Note that two values are processed each iteration.
@@:     vmovapd xmm0,xmmword ptr [rcx+rbx]  ;load next two x values
        vmovapd xmm1,xmmword ptr [rdx+rbx]  ;load next two y values

        vaddpd xmm4,xmm4,xmm0               ;update sum_x
        vaddpd xmm5,xmm5,xmm1               ;update sum_y

        vmulpd xmm2,xmm0,xmm0               ;calc x * x
        vaddpd xmm6,xmm6,xmm2               ;update sum_xx

        vmulpd xmm2,xmm0,xmm1               ;calc x * y
        vaddpd xmm7,xmm7,xmm2               ;update sum_xy

        add rbx,16                          ;rbx = next offset
        sub r8d,2                           ;adjust counter
        jnz @B                              ;repeat until done

; Update sum variables with the final x, y values if 'n' is odd
        or eax,eax
        jz CalcFinalSums                    ;jump if n is even
        vmovsd xmm0,real8 ptr [rcx+rbx]     ;load final x
        vmovsd xmm1,real8 ptr [rdx+rbx]     ;load final y

        vaddsd xmm4,xmm4,xmm0               ;update sum_x
        vaddsd xmm5,xmm5,xmm1               ;update sum_y

        vmulsd xmm2,xmm0,xmm0               ;calc x * x
        vaddsd xmm6,xmm6,xmm2               ;update sum_xx

        vmulsd xmm2,xmm0,xmm1               ;calc x * y
        vaddsd xmm7,xmm7,xmm2               ;update sum_xy

; Calculate final sum_x, sum_y, sum_xx, sum_xy
CalcFinalSums:
        vhaddpd xmm4,xmm4,xmm4              ;xmm4[63:0] = final sum_x
        vhaddpd xmm5,xmm5,xmm5              ;xmm5[63:0] = final sum_y
        vhaddpd xmm6,xmm6,xmm6              ;xmm6[63:0] = final sum_xx
        vhaddpd xmm7,xmm7,xmm7              ;xmm7[63:0] = final sum_xy

; Compute denominator and make sure it's valid
; denom = n * sum_xx - sum_x * sum_x
        vmulsd xmm0,xmm3,xmm6               ;n * sum_xx
        vmulsd xmm1,xmm4,xmm4               ;sum_x * sum_x
        vsubsd xmm2,xmm0,xmm1               ;denom
        vandpd xmm8,xmm2,xmmword ptr [AbsMaskF64] ;fabs(denom)
        vcomisd xmm8,real8 ptr [LsEpsilon]
        jb BadDen                           ;jump if denom < fabs(denom)

; Compute and save slope
; slope = (n * sum_xy - sum_x * sum_y) / denom
        vmulsd xmm0,xmm3,xmm7               ;n * sum_xy
        vmulsd xmm1,xmm4,xmm5               ;sum_x * sum_y
        vsubsd xmm2,xmm0,xmm1               ;slope numerator
        vdivsd xmm3,xmm2,xmm8               ;final slope
        vmovsd real8 ptr [r9],xmm3          ;save slope

; Compute and save intercept
; intercept = (sum_xx * sum_y - sum_x * sum_xy) / denom
        vmulsd xmm0,xmm6,xmm5               ;sum_xx * sum_y
        vmulsd xmm1,xmm4,xmm7               ;sum_x * sum_xy
        vsubsd xmm2,xmm0,xmm1               ;intercept numerator
        vdivsd xmm3,xmm2,xmm8               ;final intercept
        vmovsd real8 ptr [r10],xmm3         ;save intercept

        mov eax,1                           ;success return code
        jmp Done

; Bad denominator detected, set m and b to 0.0
BadDen: vxorpd xmm0,xmm0,xmm0
        vmovsd real8 ptr [r9],xmm0          ;*m = 0.0
        vmovsd real8 ptr [r10],xmm0         ;*b = 0.0
        xor eax,eax                         ;set error code

Done:   _RestoreXmmRegs xmm6,xmm7,xmm8
        _DeleteFrame rbx
        ret
AvxCalcLeastSquares_ endp
        end
