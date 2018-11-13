;-------------------------------------------------
;               Ch05_04.asm
;-------------------------------------------------

; extern "C" void CompareVCOMISS_(float a, float b, bool* results);

        .code
CompareVCOMISS_ proc

; Set result flags based on compare status
        vcomiss xmm0,xmm1
        setp byte ptr [r8]                  ;RFLAGS.PF = 1 if unordered
        jnp @F
        xor al,al
        mov byte ptr [r8+1],al              ;Use default result values
        mov byte ptr [r8+2],al
        mov byte ptr [r8+3],al
        mov byte ptr [r8+4],al
        mov byte ptr [r8+5],al
        mov byte ptr [r8+6],al
        jmp Done

@@:     setb byte ptr [r8+1]                ;set byte if a < b
        setbe byte ptr [r8+2]               ;set byte if a <= b
        sete byte ptr [r8+3]                ;set byte if a == b
        setne byte ptr [r8+4]               ;set byte if a != b
        seta byte ptr [r8+5]                ;set byte if a > b
        setae byte ptr [r8+6]               ;set byte if a >= b

Done:   ret
CompareVCOMISS_ endp

; extern "C" void CompareVCOMISD_(double a, double b, bool* results);

CompareVCOMISD_ proc

; Set result flags based on compare status
        vcomisd xmm0,xmm1
        setp byte ptr [r8]                  ;RFLAGS.PF = 1 if unordered
        jnp @F
        xor al,al
        mov byte ptr [r8+1],al              ;Use default result values
        mov byte ptr [r8+2],al
        mov byte ptr [r8+3],al
        mov byte ptr [r8+4],al
        mov byte ptr [r8+5],al
        mov byte ptr [r8+6],al
        jmp Done

@@:     setb byte ptr [r8+1]                ;set byte if a < b
        setbe byte ptr [r8+2]               ;set byte if a <= b
        sete byte ptr [r8+3]                ;set byte if a == b
        setne byte ptr [r8+4]               ;set byte if a != b
        seta byte ptr [r8+5]                ;set byte if a > b
        setae byte ptr [r8+6]               ;set byte if a >= b

Done:   ret
CompareVCOMISD_ endp
        end
