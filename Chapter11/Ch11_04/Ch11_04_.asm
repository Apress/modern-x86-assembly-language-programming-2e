;-------------------------------------------------
;               Ch11_04_.asm
;-------------------------------------------------

; extern "C" void GprCountZeroBits_(uint32_t x, uint32_t* lzcnt, uint32_t* tzcnt);
;
; Requires:     BMI1, LZCNT

        .code
GprCountZeroBits_ proc
        lzcnt eax,ecx                       ;count leading zeros
        mov dword ptr [rdx],eax             ;save result

        tzcnt eax,ecx                       ;count trailing zeros
        mov dword ptr [r8],eax              ;save result
        ret
GprCountZeroBits_ endp

; extern "C" uint32_t GprBextr_(uint32_t x, uint8_t start, uint8_t length);
;
; Requires:     BMI1

GprBextr_ proc
        mov al,r8b
        mov ah,al                           ;ah = length
        mov al,dl                           ;al = start
        bextr eax,ecx,eax                   ;eax = extracted bit field (from x)
        ret
GprBextr_ endp

; extern "C" uint32_t GprAndNot_(uint32_t x, uint32_t y);
;
; Requires:     BMI1

GprAndNot_ proc
        andn eax,ecx,edx                    ;eax = ~x & y
        ret
GprAndNot_ endp
        end
