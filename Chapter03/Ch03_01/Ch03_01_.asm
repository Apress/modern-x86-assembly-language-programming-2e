;-------------------------------------------------
;               Ch03_01.asm
;-------------------------------------------------

; extern "C" int CalcArraySum_(const int* x, int n)
;
; Returns:      Sum of elements in array x

        .code
CalcArraySum_ proc

; Initialize sum to zero
        xor eax,eax                         ;sum = 0

; Make sure 'n' is greater than zero
        cmp edx,0
        jle InvalidCount                    ;jump if n <= 0

; Sum the elements of the array
@@:     add eax,[rcx]                       ;add next element to total (sum += *x)
        add rcx,4                           ;set pointer to next element (x++)
        dec edx                             ;adjust counter (n -= 1)
        jnz @B                              ;repeat if not done

InvalidCount:
        ret

CalcArraySum_ endp
        end
