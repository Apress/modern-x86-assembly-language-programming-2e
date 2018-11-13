;-------------------------------------------------
;               Ch02_02.asm
;-------------------------------------------------

; extern "C" unsigned int IntegerLogical_(unsigned int a, unsigned int b, unsigned int c,  unsigned int d);

        extern g_Val1:dword                 ;external doubleword (32-bit) value

        .code
IntegerLogical_ proc

; Calculate (((a & b) | c ) ^ d) + g_Val1
        and ecx,edx                         ;ecx = a & b
        or ecx,r8d                          ;ecx = (a & b) | c
        xor ecx,r9d                         ;ecx = ((a & b) | c) ^ d
        add ecx,[g_Val1]                    ;ecx = (((a & b) | c) ^ d) + g_Val1

        mov eax,ecx                         ;eax = final result
        ret                                 ;return to caller
IntegerLogical_ endp
        end
