;-------------------------------------------------
;               Ch03_08.asm
;-------------------------------------------------

; extern "C" long long CompareArrays_(const int* x, const int* y, long long n)
;
; Returns       -1          Value of 'n' is invalid
;               0 <= i < n  Index of first non-matching element
;               n           All elements match

        .code
CompareArrays_ proc frame

; Save non-volatile registers
        push rsi
        .pushreg rsi
        push rdi
        .pushreg rdi
        .endprolog

; Load arguments and validate 'n'
        mov rax,-1                          ;rax = return code for invalid n
        test r8,r8
        jle @F                              ;jump if n <= 0

; Compare the arrays for equality
        mov rsi,rcx                         ;rsi = x
        mov rdi,rdx                         ;rdi = y
        mov rcx,r8                          ;rcx = n
        mov rax,r8                          ;rax = n
        repe cmpsd
        je @F                               ;arrays are equal

; Calculate index of first non-match
        sub rax,rcx                         ;rax = index of mismatch + 1
        dec rax                             ;rax = index of mismatch

; Restore non-volatile registers and return
@@:     pop rdi
        pop rsi
        ret
CompareArrays_ endp
        end
