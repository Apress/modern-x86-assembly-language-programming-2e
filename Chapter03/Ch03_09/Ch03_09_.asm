;-------------------------------------------------
;               Ch03_09.asm
;-------------------------------------------------

; extern "C" int ReverseArray_(int* y, const int* x, int n);
;
; Returns       0 = invalid n, 1 = success

        .code
ReverseArray_ proc frame

; Save non-volatile registers
        push rsi
        .pushreg rsi
        push rdi
        .pushreg rdi
        .endprolog

; Make sure n is valid
        xor eax,eax                         ;error return code
        test r8d,r8d                        ;is n <= 0?
        jle InvalidArg                      ;jump if n <= 0

; Initialize registers for reversal operation
        mov rsi,rdx                         ;rsi = x
        mov rdi,rcx                         ;rdi = y
        mov ecx,r8d                         ;rcx = n
        lea rsi,[rsi+rcx*4-4]               ;rsi = &x[n - 1]

; Save caller's RFLAGS.DF, then set RFLAGS.DF to 1
        pushfq                              ;save caller's RFLAGS.DF
        std                                 ;RFLAGS.DF = 1

; Repeat loop until array reversal is complete
@@:     lodsd                               ;eax = *x--
        mov [rdi],eax                       ;*y = eax
        add rdi,4                           ;y++
        dec rcx                             ;n--
        jnz @B

; Restore caller's RFLAGS.DF and set return code
        popfq                               ;restore caller's RFLAGS.DF
        mov eax,1                           ;set success return code

; Restore non-volatile registers and return
InvalidArg:
        pop rdi
        pop rsi
        ret
ReverseArray_ endp
        end
