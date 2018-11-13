;-------------------------------------------------
;               Ch02_07.asm
;-------------------------------------------------

; extern "C" int SignedMinA_(int a, int b, int c);
;
; Returns:      min(a, b, c)

        .code
SignedMinA_ proc
        mov eax,ecx
        cmp eax,edx                         ;compare a and b
        jle @F                              ;jump if a <= b
        mov eax,edx                         ;eax = b

@@:     cmp eax,r8d                         ;compare min(a, b) and c
        jle @F
        mov eax,r8d                         ;eax = min(a, b, c)

@@:     ret
SignedMinA_ endp

; extern "C" int SignedMaxA_(int a, int b, int c);
;
; Returns:      max(a, b, c)

SignedMaxA_ proc
        mov eax,ecx
        cmp eax,edx                         ;compare a and b
        jge @F                              ;jump if a >= b
        mov eax,edx                         ;eax = b

@@:     cmp eax,r8d                         ;compare max(a, b) and c
        jge @F
        mov eax,r8d                         ;eax = max(a, b, c)

@@:     ret
SignedMaxA_ endp

; extern "C" int SignedMinB_(int a, int b, int c);
;
; Returns:      min(a, b, c)

SignedMinB_ proc
        cmp ecx,edx
        cmovg ecx,edx                       ;ecx = min(a, b)
        cmp ecx,r8d
        cmovg ecx,r8d                       ;ecx = min(a, b, c)
        mov eax,ecx
        ret
SignedMinB_ endp

; extern "C" int SignedMaxB_(int a, int b, int c);
;
; Returns:      max(a, b, c)

SignedMaxB_ proc
        cmp ecx,edx
        cmovl ecx,edx                       ;ecx = max(a, b)
        cmp ecx,r8d
        cmovl ecx,r8d                       ;ecx = max(a, b, c)
        mov eax,ecx
        ret
SignedMaxB_ endp
        end
