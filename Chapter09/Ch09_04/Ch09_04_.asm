;-------------------------------------------------
;               Ch09_04.asm
;-------------------------------------------------

        include <MacrosX86-64-AVX.asmh>

; extern "C" bool AvxCalcCorrCoef_(const double* x, const double* y, size_t n, double sums[5], double epsilon, double* rho)
;
; Returns       0 = error, 1 = success

        .code
AvxCalcCorrCoef_ proc frame
        _CreateFrame CC_,0,32
        _SaveXmmRegs xmm6,xmm7
        _EndProlog

; Validate arguments
        or r8,r8
        jz BadArg                           ;jump if n == 0
        test rcx,1fh
        jnz BadArg                          ;jump if x is not aligned
        test rdx,1fh
        jnz BadArg                          ;jump if y is not aligned

; Initialize sum variables to zero
        vxorpd ymm3,ymm3,ymm3               ;ymm3 = packed sum_x
        vxorpd ymm4,ymm4,ymm4               ;ymm4 = packed sum_y
        vxorpd ymm5,ymm5,ymm5               ;ymm5 = packed sum_xx
        vxorpd ymm6,ymm6,ymm6               ;ymm6 = packed sum_yy
        vxorpd ymm7,ymm7,ymm7               ;ymm7 = packed sum_xy
        mov r10,r8                          ;r10 = n

        cmp r8,4
        jb LP2                              ;jump if n >= 1 && n <= 3

; Calculate intermediate packed sum variables
LP1:    vmovapd ymm0,ymmword ptr [rcx]      ;ymm0 = packed x values
        vmovapd ymm1,ymmword ptr [rdx]      ;ymm1 = packed y values

        vaddpd ymm3,ymm3,ymm0               ;update packed sum_x
        vaddpd ymm4,ymm4,ymm1               ;update packed sum_y

        vmulpd ymm2,ymm0,ymm1               ;ymm2 = packed xy values
        vaddpd ymm7,ymm7,ymm2               ;update packed sum_xy

        vmulpd ymm0,ymm0,ymm0               ;ymm0 = packed xx values
        vmulpd ymm1,ymm1,ymm1               ;ymm1 = packed yy values
        vaddpd ymm5,ymm5,ymm0               ;update packed sum_xx
        vaddpd ymm6,ymm6,ymm1               ;update packed sum_yy

        add rcx,32                          ;update x ptr
        add rdx,32                          ;update y ptr
        sub r8,4                            ;n -= 4
        cmp r8,4                            ;is n >= 4?
        jae LP1                             ;jump if yes

        or r8,r8                            ;is n == 0?
        jz FSV                              ;jump if yes

; Update sum variables with final x & y values
LP2:    vmovsd xmm0,real8 ptr [rcx]         ;xmm0[63:0] = x[i], ymm0[255:64] = 0
        vmovsd xmm1,real8 ptr [rdx]         ;xmm1[63:0] = y[i], ymm1[255:64] = 0

        vaddpd ymm3,ymm3,ymm0               ;update packed sum_x
        vaddpd ymm4,ymm4,ymm1               ;update packed sum_y

        vmulpd ymm2,ymm0,ymm1               ;ymm2 = packed xy values
        vaddpd ymm7,ymm7,ymm2               ;update packed sum_xy

        vmulpd ymm0,ymm0,ymm0               ;ymm0 = packed xx values
        vmulpd ymm1,ymm1,ymm1               ;ymm1 = packed yy values
        vaddpd ymm5,ymm5,ymm0               ;update packed sum_xx
        vaddpd ymm6,ymm6,ymm1               ;update packed sum_yy

        add rcx,8                           ;update x ptr
        add rdx,8                           ;update y ptr
        sub r8,1                            ;n -= 1
        jnz LP2                             ;repeat until done

; Calculate final sum variables
FSV:    vextractf128 xmm0,ymm3,1
        vaddpd xmm1,xmm0,xmm3
        vhaddpd xmm3,xmm1,xmm1              ;xmm3[63:0] = sum_x

        vextractf128 xmm0,ymm4,1
        vaddpd xmm1,xmm0,xmm4
        vhaddpd xmm4,xmm1,xmm1              ;xmm4[63:0] = sum_y

        vextractf128 xmm0,ymm5,1
        vaddpd xmm1,xmm0,xmm5
        vhaddpd xmm5,xmm1,xmm1              ;xmm5[63:0] = sum_xx

        vextractf128 xmm0,ymm6,1
        vaddpd xmm1,xmm0,xmm6
        vhaddpd xmm6,xmm1,xmm1              ;xmm6[63:0] = sum_yy

        vextractf128 xmm0,ymm7,1
        vaddpd xmm1,xmm0,xmm7
        vhaddpd xmm7,xmm1,xmm1              ;xmm7[63:0] = sum_xy

; Save final sum variables
        vmovsd real8 ptr [r9],xmm3          ;save sum_x
        vmovsd real8 ptr [r9+8],xmm4        ;save sum_y
        vmovsd real8 ptr [r9+16],xmm5       ;save sum_xx
        vmovsd real8 ptr [r9+24],xmm6       ;save sum_yy
        vmovsd real8 ptr [r9+32],xmm7       ;save sum_xy

; Calculate rho numerator
; rho_num = n * sum_xy - sum_x * sum_y;
        vcvtsi2sd xmm2,xmm2,r10             ;xmm2 = n
        vmulsd xmm0,xmm2,xmm7               ;xmm0 = = n * sum_xy
        vmulsd xmm1,xmm3,xmm4               ;xmm1 = sum_x * sum_y
        vsubsd xmm7,xmm0,xmm1               ;xmm7 = rho_num

; Calculate rho denominator
; t1 = sqrt(n * sum_xx - sum_x * sum_x)
; t2 = sqrt(n * sum_yy - sum_y * sum_y)
; rho_den = t1 * t2
        vmulsd xmm0,xmm2,xmm5       ;xmm0 = n * sum_xx
        vmulsd xmm3,xmm3,xmm3       ;xmm3 = sum_x * sum_x
        vsubsd xmm3,xmm0,xmm3       ;xmm3 = n * sum_xx - sum_x * sum_x
        vsqrtsd xmm3,xmm3,xmm3      ;xmm3 = t1

        vmulsd xmm0,xmm2,xmm6       ;xmm0 = n * sum_yy
        vmulsd xmm4,xmm4,xmm4       ;xmm4 = sum_y * sum_y
        vsubsd xmm4,xmm0,xmm4       ;xmm4 = n * sum_yy - sum_y * sum_y
        vsqrtsd xmm4,xmm4,xmm4      ;xmm4 = t2

        vmulsd xmm0,xmm3,xmm4       ;xmm0 = rho_den

; Calculate and save final rho
        xor eax,eax
        vcomisd xmm0,real8 ptr [rbp+CC_OffsetStackArgs] ;rho_den < epsilon?
        setae al                                ;set return code
        jb BadRho                               ;jump if rho_den < epsilon
        vdivsd xmm1,xmm7,xmm0                   ;xmm1 = rho

SavRho: mov rdx,[rbp+CC_OffsetStackArgs+8]      ;rdx = ptr to rho
        vmovsd real8 ptr [rdx],xmm1             ;save rho

Done:   vzeroupper
        _RestoreXmmRegs xmm6,xmm7
        _DeleteFrame
        ret

; Error handling code
BadRho: vxorpd xmm1,xmm1,xmm1               ;rho = 0
        jmp SavRho

BadArg: xor eax,eax                         ;eax = invalid arg ret code
        jmp Done

AvxCalcCorrCoef_ endp
        end
