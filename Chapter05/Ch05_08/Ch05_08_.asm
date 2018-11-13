;-------------------------------------------------
;               Ch05_08.asm
;-------------------------------------------------

; void CalcMatrixSquaresF32_(float* y, const float* x, float offset, int nrows, int ncols);
;
; Calculates:     y[i][j] = x[j][i] * x[j][i] + offset

        .code
CalcMatrixSquaresF32_ proc frame

; Function prolog
        push rsi                                ;save caller's rsi
        .pushreg rsi
        push rdi                                ;save caller's rdi
        .pushreg rdi
        .endprolog

; Make sure nrows and ncols are valid
        movsxd r9,r9d                           ;r9 = nrows
        test r9,r9
        jle InvalidCount                        ;jump if nrows <= 0

        movsxd r10,dword ptr [rsp+56]           ;r10 = ncols
        test r10,r10
        jle InvalidCount                        ;jump if ncols <= 0

; Initialize pointers to source and destination arrays
        mov rsi,rdx                             ;rsi = x
        mov rdi,rcx                             ;rdi = y
        xor rcx,rcx                             ;rcx = i

; Perform the required calculations
Loop1:  xor rdx,rdx                             ;rdx = j

Loop2:  mov rax,rdx                             ;rax = j
        imul rax,r10                            ;rax = j * ncols
        add rax,rcx                             ;rax = j * ncols + i
        vmovss xmm0,real4 ptr [rsi+rax*4]       ;xmm0 = x[j][i]
        vmulss xmm1,xmm0,xmm0                   ;xmm1 = x[j][i] * x[j][i]
        vaddss xmm3,xmm1,xmm2                   ;xmm2 = x[j][i] * x[j][i] + offset

        mov rax,rcx                             ;rax = i
        imul rax,r10                            ;rax = i * ncols
        add rax,rdx                             ;rax = i * ncols + j;
        vmovss real4 ptr [rdi+rax*4],xmm3       ;y[i][j] = x[j][i] * x[j][i] + offset

        inc rdx                                 ;j += 1
        cmp rdx,r10
        jl Loop2                                ;jump if j < ncols

        inc rcx                                 ;i += 1
        cmp rcx,r9
        jl Loop1                                ;jump if i < nrows

InvalidCount:

; Function epilog
        pop rdi                                 ;restore caller's rdi
        pop rsi                                 ;restore caller's rsi
        ret

CalcMatrixSquaresF32_ endp
        end
