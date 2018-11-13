;-------------------------------------------------
;               Ch03_04.asm
;-------------------------------------------------

; extern "C" int CalcMatrixRowColSums_(int* row_sums, int* col_sums, const int* x, int nrows, int ncols)
;
; Returns:      0 = nrows <= 0 or ncols <= 0, 1 = success

        .code
CalcMatrixRowColSums_ proc frame

; Function prolog
        push rbx                            ;save caller's rbx
        .pushreg rbx
        push rsi                            ;save caller's rsi
        .pushreg rsi
        push rdi                            ;save caller's rdi
        .pushreg rdi
        .endprolog

; Make sure nrows and ncols are valid
        xor eax,eax                         ;set error return code

        cmp r9d,0
        jle InvalidArg                      ;jump if nrows <= 0

        mov r10d,[rsp+64]                   ;r10d = ncols
        cmp r10d,0

        jle InvalidArg                      ;jump if ncols <= 0

; Initialize elements of col_sums array to zero
        mov rbx,rcx                         ;temp save of row_sums
        mov rdi,rdx                         ;rdi = col_sums
        mov ecx,r10d                        ;rcx = ncols
        xor eax,eax                         ;eax = fill value
        rep stosd                           ;fill array with zeros

; The code below uses the following registers:
;   rcx = row_sums          rdx = col_sums
;   r9d = nrows             r10d = ncols
;   eax = i                 ebx = j
;   edi = i * ncols         esi = i * ncols + j
;   r8 = x                  r11d = x[i][j]

; Initialize outer loop variables.
        mov rcx,rbx                         ;rcx = row_sums
        xor eax,eax                         ;i = 0

Lp1:    mov dword ptr [rcx+rax*4],0         ;row_sums[i] = 0
        xor ebx,ebx                         ;j = 0
        mov edi,eax                         ;edi = i
        imul edi,r10d                       ;edi = i * ncols

; Inner loop
Lp2:    mov esi,edi                         ;esi = i * ncols
        add esi,ebx                         ;esi = i * ncols + j
        mov r11d,[r8+rsi*4]                 ;r11d = x[i * ncols + j]
        add [rcx+rax*4],r11d                ;row_sums[i] += x[i * ncols + j]
        add [rdx+rbx*4],r11d                ;col_sums[j] += x[i * ncols + j]

; Is the inner loop finished?
        inc ebx                             ;j += 1
        cmp ebx,r10d
        jl Lp2                              ;jump if j < ncols

; Is the outer loop finished?
        inc eax                             ;i += 1
        cmp eax,r9d
        jl Lp1                              ;jump if i < nrows

        mov eax,1                           ;set success return code

; Function epilog
InvalidArg:
        pop rdi                             ;restore NV registers and return
        pop rsi
        pop rbx
        ret
CalcMatrixRowColSums_ endp
        end
