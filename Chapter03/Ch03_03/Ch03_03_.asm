;-------------------------------------------------
;               Ch03_03.asm
;-------------------------------------------------

; void CalcMatrixSquares_(int* y, const int* x, int nrows, int ncols);
;
; Calculates:     y[i][j] = x[j][i] * x[j][i]

        .code
CalcMatrixSquares_ proc frame

; Function prolog
        push rsi                                ;save caller's rsi
        .pushreg rsi
        push rdi                                ;save caller's rdi
        .pushreg rdi
        .endprolog

; Make sure nrows and ncols are valid
        cmp r8d,0
        jle InvalidCount                        ;jump if nrows <= 0
        cmp r9d,0
        jle InvalidCount                        ;jump if ncols <= 0

; Initialize pointers to source and destination arrays
        mov rsi,rdx                             ;rsi = x
        mov rdi,rcx                             ;rdi = y
        xor rcx,rcx                             ;rcx = i
        movsxd r8,r8d                           ;r8 = nrows sign extended
        movsxd r9,r9d                           ;r9 = ncols sign extended

; Perform the required calculations
Loop1:
        xor rdx,rdx                             ;rdx = j
Loop2:
        mov rax,rdx                             ;rax = j
        imul rax,r9                             ;rax = j * ncols
        add rax,rcx                             ;rax = j * ncols + i
        mov r10d,dword ptr [rsi+rax*4]          ;r10d = x[j][i]
        imul r10d,r10d                          ;r10d = x[j][i] * x[j][i]

        mov rax,rcx                             ;rax = i
        imul rax,r9                             ;rax = i * ncols
        add rax,rdx                             ;rax = i * ncols + j;
        mov dword ptr [rdi+rax*4],r10d          ;y[i][j] = r10d

        inc rdx                                 ;j += 1
        cmp rdx,r9
        jl Loop2                                ;jump if j < ncols

        inc rcx                                 ;i += 1
        cmp rcx,r8
        jl Loop1                                ;jump if i < nrows

InvalidCount:

; Function epilog
        pop rdi                                 ;restore caller's rdi
        pop rsi                                 ;restore caller's rsi
        ret

CalcMatrixSquares_ endp
        end
