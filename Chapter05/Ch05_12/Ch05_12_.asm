;-------------------------------------------------
;               Ch05_12.asm
;-------------------------------------------------

; extern "C" bool Cc4_(const double* ht, const double* wt, int n, double* bsa1, double* bsa2, double* bsa3);

        include <MacrosX86-64-AVX.asmh>

                .const
r8_0p007184     real8 0.007184
r8_0p725        real8 0.725
r8_0p425        real8 0.425
r8_0p0235       real8 0.0235
r8_0p42246      real8 0.42246
r8_0p51456      real8 0.51456
r8_3600p0       real8 3600.0

        .code
        extern pow:proc

Cc4_ proc frame
        _CreateFrame Cc4_,16,64,rbx,rsi,r12,r13,r14,r15
        _SaveXmmRegs xmm6,xmm7,xmm8,xmm9
        _EndProlog

; Save argument registers to home area (optional). Note that the home
; area can also be used to store other transient data values.
        mov qword ptr [rbp+Cc4_OffsetHomeRCX],rcx
        mov qword ptr [rbp+Cc4_OffsetHomeRDX],rdx
        mov qword ptr [rbp+Cc4_OffsetHomeR8],r8
        mov qword ptr [rbp+Cc4_OffsetHomeR9],r9

; Initialize processing loop pointers.  Note that the pointers are
; maintained in non-volatile registers, which eliminates reloads
; after the calls to pow().
        test r8d,r8d                            ;is n > 0?
        jg @F                                   ;jump if n > 0

        xor eax,eax                             ;set error return code
        jmp Done

@@:     mov [rbp],r8d                           ;save n to local var
        mov r12,rcx                             ;r12 = ptr to ht
        mov r13,rdx                             ;r13 = ptr to wt
        mov r14,r9                              ;r14 = ptr to bsa1
        mov r15,[rbp+Cc4_OffsetStackArgs]       ;r15 = ptr to bsa2
        mov rbx,[rbp+Cc4_OffsetStackArgs+8]     ;rbx = ptr to bsa3
        xor rsi,rsi                             ;array element offset

; Allocate home space on stack for use by pow()
        sub rsp,32

; Calculate bsa1 = 0.007184 * pow(ht, 0.725) * pow(wt, 0.425);
@@:     vmovsd xmm0,real8 ptr [r12+rsi]             ;xmm0 = height
        vmovsd xmm8,xmm8,xmm0
        vmovsd xmm1,real8 ptr [r8_0p725]
        call pow                                    ;xmm0 = pow(ht, 0.725)
        vmovsd xmm6,xmm6,xmm0

        vmovsd xmm0,real8 ptr [r13+rsi]             ;xmm0 = weight
        vmovsd xmm9,xmm9,xmm0
        vmovsd xmm1,real8 ptr [r8_0p425]
        call pow                                    ;xmm0 = pow(wt, 0.425)
        vmulsd xmm6,xmm6,real8 ptr [r8_0p007184]
        vmulsd xmm6,xmm6,xmm0                       ;xmm6 = bsa1

; Calculate bsa2 = 0.0235 * pow(ht, 0.42246) * pow(wt, 0.51456);
        vmovsd xmm0,xmm0,xmm8                       ;xmm0 = height
        vmovsd xmm1,real8 ptr [r8_0p42246]
        call pow                                    ;xmm0 = pow(ht, 0.42246)
        vmovsd xmm7,xmm7,xmm0

        vmovsd xmm0,xmm0,xmm9                       ;xmm0 = weight
        vmovsd xmm1,real8 ptr [r8_0p51456]
        call pow                                    ;xmm0 = pow(wt, 0.51456)
        vmulsd xmm7,xmm7,real8 ptr [r8_0p0235]
        vmulsd xmm7,xmm7,xmm0                       ;xmm7 = bsa2

; Calculate bsa3 = sqrt(ht * wt / 60.0);
        vmulsd xmm8,xmm8,xmm9
        vdivsd xmm8,xmm8,real8 ptr [r8_3600p0]
        vsqrtsd xmm8,xmm8,xmm8                  ;xmm8 = bsa3

; Save BSA results
        vmovsd real8 ptr [r14+rsi],xmm6         ;save bsa1 result
        vmovsd real8 ptr [r15+rsi],xmm7         ;save bsa2 result
        vmovsd real8 ptr [rbx+rsi],xmm8         ;save bsa3 result

        add rsi,8                               ;update array offset
        dec dword ptr [rbp]                     ;n = n - 1
        jnz @B
        mov eax,1                               ;set success return code

Done:   _RestoreXmmRegs xmm6,xmm7,xmm8,xmm9
        _DeleteFrame rbx,rsi,r12,r13,r14,r15
        ret

Cc4_ endp
        end
