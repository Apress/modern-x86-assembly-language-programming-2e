;-------------------------------------------------
;               Ch09_03.asm
;-------------------------------------------------

; extern "C" bool AvxCalcColMeans_(const double* x, size_t nrows, size_t ncols, double* col_means)

        extern c_NumRowsMax:qword
        extern c_NumColsMax:qword

        .code
AvxCalcColumnMeans_ proc

; Validate nrows and ncols
        xor eax,eax                         ;error return code (also col_mean index)
        test rdx,rdx
        jz Done                             ;jump if nrows is zero
        cmp rdx,[c_NumRowsMax]
        ja Done                             ;jump if nrows is too large
        test r8,r8
        jz Done                             ;jump if ncols is zero
        cmp r8,[c_NumColsMax]
        ja Done                             ;jump if ncols is too large
        
; Initialize elements of col_means to zero
        vxorpd xmm0,xmm0,xmm0               ;xmm0[63:0] = 0.0
@@:     vmovsd real8 ptr[r9+rax*8],xmm0     ;col_means[i] = 0.0
        inc rax
        cmp rax,r8
        jb @B                               ;repeat until done

        vcvtsi2sd xmm2,xmm2,rdx             ;convert nrows for later use

; Compute the sum of each column in x
LP1:    mov r11,r9                          ;r11 = ptr to col_means
        xor r10,r10                         ;r10 = col_index

LP2:    mov rax,r10                         ;rax = col_index
        add rax,4
        cmp rax,r8                          ;4 or more columns remaining?
        ja @F                               ;jump if no (col_index + 4 > ncols)

; Update col_means using next four columns
        vmovupd ymm0,ymmword ptr [rcx]      ;load next 4 columns of current row
        vaddpd ymm1,ymm0,ymmword ptr [r11]  ;add to col_means
        vmovupd ymmword ptr [r11],ymm1      ;save updated col_means
        add r10,4                           ;col_index += 4
        add rcx,32                          ;update x ptr
        add r11,32                          ;update col_means ptr
        jmp NextColSet

@@:     sub rax,2
        cmp rax,r8                          ;2 or more columns remaining?
        ja @F                               ;jump if no (col_index + 2 > ncols)

; Update col_means using next two columns
        vmovupd xmm0,xmmword ptr [rcx]      ;load next 2 columns of current row
        vaddpd xmm1,xmm0,xmmword ptr [r11]  ;add to col_means
        vmovupd xmmword ptr [r11],xmm1      ;save updated col_means
        add r10,2                           ;col_index += 2
        add rcx,16                          ;update x ptr
        add r11,16                          ;update col_means ptr
        jmp NextColSet

; Update col_means using next column (or last column in the current row)
@@:     vmovsd xmm0,real8 ptr [rcx]         ;load x from last column
        vaddsd xmm1,xmm0,real8 ptr [r11]    ;add to col_means
        vmovsd real8 ptr [r11],xmm1         ;save updated col_means
        inc r10                             ;col_index += 1
        add rcx,8                           ;update x ptr

NextColSet:
        cmp r10,r8                          ;more columns in current row?
        jb LP2                              ;jump if yes
        dec rdx                             ;nrows -= 1
        jnz LP1                             ;jump if more rows

; Compute the final col_means
@@:     vmovsd xmm0,real8 ptr [r9]          ;xmm0 = col_means[i]
        vdivsd xmm1,xmm0,xmm2               ;compute final mean
        vmovsd real8 ptr [r9],xmm1          ;save col_mean[i]
        add r9,8                            ;update col_means ptr
        dec r8                              ;ncols -= 1
        jnz @B                              ;repeat until done

        mov eax,1                           ;set success return code

Done:   vzeroupper
        ret

AvxCalcColumnMeans_ endp
        end
