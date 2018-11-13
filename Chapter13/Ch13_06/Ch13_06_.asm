;-------------------------------------------------
;               Ch13_06.asm
;-------------------------------------------------

        include <cmpequ.asmh>
        include <MacrosX86-64-AVX.asmh>

        extern c_NumRowsMax:qword
        extern c_NumColsMax:qword

; extern "C" bool Avx512CalcColumnMeans_(const double* x, size_t nrows, size_t ncols, double* col_means, size_t* col_counts, double x_min);

        .code
Avx512CalcColumnMeans_ proc frame
        _CreateFrame CCM_,0,0,rbx,r12,r13
        _EndProlog

; Validate nrows and ncols
        xor eax,eax                         ;set error return code
        test rdx,rdx
        jz Done                             ;jump if nrows is zero
        cmp rdx,[c_NumRowsMax]
        ja Done                             ;jump if nrows is too large
        test r8,r8
        jz Done                             ;jump if ncols is zero
        cmp r8,[c_NumColsMax]
        ja Done                             ;jump if ncols is too large

; Load argument values col_counts and x_min
        mov ebx,1
        vpbroadcastq zmm4,rbx               ;zmm4 = 8 qwords of 1
        mov rbx,[rbp+CCM_OffsetStackArgs]   ;rbx = col_counts ptr
        lea r13,[rbp+CCM_OffsetStackArgs+8] ;r13 = ptr to x_min
       
; Set initial col_means and col_counts to zero
        xor r10,r10
        vxorpd xmm0,xmm0,xmm0
@@:     vmovsd real8 ptr[r9+rax*8],xmm0         ;col_means[i] = 0.0
        mov [rbx+rax*8],r10                     ;col_counts[i] = 0
        inc rax
        cmp rax,r8
        jne @B                                  ;repeat until done

; Compute the sum of each column in x
LP1:    xor r10,r10                             ;r10 = col_index
        mov r11,r9                              ;r11 = ptr to col_means
        mov r12,rbx                             ;r12 = ptr to col_counts

LP2:    mov rax,r10                             ;rax = col_index
        add rax,8
        cmp rax,r8                              ;8 or more columns remaining?
        ja @F                                   ;jump if col_index + 8 > ncols

; Update col_means and col_counts using next eight columns
        vmovupd zmm0,zmmword ptr [rcx]          ;load next 8 cols of cur row
        vcmppd k1,zmm0,real8 bcst [r13],CMP_GE  ;k1 = mask of values >= x_min
        vmovupd zmm1{k1}{z},zmm0                ;values >= x_min or 0.0
        vaddpd zmm2,zmm1,zmmword ptr [r11]      ;add values to col_means
        vmovupd zmmword ptr [r11],zmm2          ;save updated col_means

        vpmovm2q zmm0,k1                        ;convert mask to vector
        vpandq zmm1,zmm0,zmm4                   ;qword values for add
        vpaddq zmm2,zmm1,zmmword ptr [r12]      ;update col_counts
        vmovdqu64 zmmword ptr [r12],zmm2        ;save updated col_counts

        add r10,8                               ;col_index += 8
        add rcx,64                              ;x += 8
        add r11,64                              ;col_means += 8
        add r12,64                              ;col_counts += 8
        jmp NextColSet

; Update col_means and col_counts using next four columns
@@:     sub rax,4
        cmp rax,r8                              ;4 or more columns remaining?
        ja @F                                   ;jump if col_index + 4 > ncols

        vmovupd ymm0,ymmword ptr [rcx]          ;load next 4 cols of cur row
        vcmppd k1,ymm0,real8 bcst [r13],CMP_GE  ;k1 = mask of values >= x_min
        vmovupd ymm1{k1}{z},ymm0                ;values >= x_min or 0.0
        vaddpd ymm2,ymm1,ymmword ptr [r11]      ;add values to col_means
        vmovupd ymmword ptr [r11],ymm2          ;save updated col_means

        vpmovm2q ymm0,k1                        ;convert mask to vector
        vpandq ymm1,ymm0,ymm4                   ;qword values for add
        vpaddq ymm2,ymm1,ymmword ptr [r12]      ;update col_counts
        vmovdqu64 ymmword ptr [r12],ymm2        ;save updated col_counts

        add r10,4                               ;col_index += 4
        add rcx,32                              ;x += 4
        add r11,32                              ;col_means += 4
        add r12,32                              ;col_counts += 4
        jmp NextColSet

; Update col_means and col_counts using next two columns
@@:     sub rax,2
        cmp rax,r8                              ;2 or more columns remaining?
        ja @F                                   ;jump if col_index + 2 > ncols

        vmovupd xmm0,xmmword ptr [rcx]          ;load next 2 cols of cur row
        vcmppd k1,xmm0,real8 bcst [r13],CMP_GE  ;k1 = mask of values >= x_min
        vmovupd xmm1{k1}{z},xmm0                ;values >= x_min or 0.0
        vaddpd xmm2,xmm1,xmmword ptr [r11]      ;add values to col_means
        vmovupd xmmword ptr [r11],xmm2          ;save updated col_means

        vpmovm2q xmm0,k1                        ;convert mask to vector
        vpandq xmm1,xmm0,xmm4                   ;qword values for add
        vpaddq xmm2,xmm1,xmmword ptr [r12]      ;update col_counts
        vmovdqu64 xmmword ptr [r12],xmm2        ;save updated col_counts

        add r10,2                               ;col_index += 2
        add rcx,16                              ;x += 2
        add r11,16                              ;col_means += 2
        add r12,16                              ;col_counts += 2
        jmp NextColSet

; Update col_means using last column of current row
@@:     vmovsd xmm0,real8 ptr [rcx]             ;load x from last column
        vcmpsd k1,xmm0,real8 ptr [r13],CMP_GE   ;k1 = mask of values >= x_min
        vmovsd xmm1{k1}{z},xmm1,xmm0            ;value or 0.0
        vaddsd xmm2,xmm1,real8 ptr [r11]        ;add to col_means
        vmovsd real8 ptr [r11],xmm2             ;save updated col_means
        kmovb eax,k1                            ;eax = 0 or 1
        add qword ptr [r12],rax                 ;update col_counts

        add r10,1                               ;col_index += 1
        add rcx,8                               ;update x ptr

NextColSet:
        cmp r10,r8                          ;more columns in current row?
        jb LP2                              ;jump if yes
        dec rdx                             ;nrows -= 1
        jnz LP1                             ;jump if more rows

; Compute the final col_means
@@:     vmovsd xmm0,real8 ptr [r9]          ;xmm0 = col_means[i]
        vcvtsi2sd xmm1,xmm1,qword ptr [rbx] ;xmm1 = col_counts[i]
        vdivsd xmm2,xmm0,xmm1               ;compute final mean
        vmovsd real8 ptr [r9],xmm2          ;save col_mean[i]
        add r9,8                            ;update col_means ptr
        add rbx,8                           ;update col_counts ptr
        sub r8,1                            ;ncols -= 1
        jnz @B                              ;repeat until done

        mov eax,1                           ;set success return code

Done:   _DeleteFrame rbx,r12,r13
        vzeroupper
        ret

Avx512CalcColumnMeans_ endp
        end
