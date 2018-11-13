;-------------------------------------------------
;               Ch03_06.asm
;-------------------------------------------------

; extern "C" unsigned long long CountChars_(const char* s, char c);
;
; Description:  This function counts the number of occurrences
;               of a character in a string.
;
; Returns:      Number of occurrences found.

        .code
CountChars_ proc frame

; Save non-volatile registers
        push rsi                            ;save caller's rsi
        .pushreg rsi
        .endprolog

; Load parameters and initialize count registers
        mov rsi,rcx                         ;rsi = s
        mov cl,dl                           ;cl = c
        xor edx,edx                         ;rdx = Number of occurrences
        xor r8d,r8d                         ;r8 = 0 (required for add below)

; Repeat loop until the entire string has been scanned
@@:     lodsb                               ;load next char into register al
        or al,al                            ;test for end-of-string
        jz @F                               ;jump if end-of-string found
        cmp al,cl                           ;test current char
        sete r8b                            ;r8b = 1 if match, 0 otherwise
        add rdx,r8                          ;update occurrence count
        jmp @B

@@:     mov rax,rdx                        ;rax = number of occurrences

; Restore non-volatile registers and return
        pop rsi
        ret
CountChars_ endp
        end
