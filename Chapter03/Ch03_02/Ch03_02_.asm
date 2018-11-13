;-------------------------------------------------
;               Ch03_02.asm
;-------------------------------------------------

; extern "C" long long CalcArrayValues_(long long* y, const int* x, int a, short b, int n);
;
; Calculation:  y[i] = x[i] * a + b
;
; Returns:      Sum of the elements in array y.

        .code
CalcArrayValues_ proc frame

; Function prolog
        push rsi                            ;save volatile register rsi
        .pushreg rsi
        push rdi                            ;save volatile register rdi
        .pushreg rdi
        .endprolog

; Initialize sum to zero and make sure 'n' is valid
        xor rax,rax                         ;sum = 0
        mov r11d,[rsp+56]                   ;r11d = n
        cmp r11d,0
        jle InvalidCount                    ;jump if n <= 0

; Initialize source and destination pointers
        mov rsi,rdx                         ;rsi = ptr to array x
        mov rdi,rcx                         ;rdi = ptr to array y

; Load expression constants and array index
        movsxd r8,r8d                       ;r8 = a (sign extended)
        movsx r9,r9w                        ;r9 = b (sign extended)
        xor edx,edx                         ;edx = array index i

; Repeat until done
@@:     movsxd rcx,dword ptr [rsi+rdx*4]    ;rcx = x[i] (sign extended)
        imul rcx,r8                         ;rcx = x[i] * a
        add rcx,r9                          ;rcx = x[i] * a + b
        mov qword ptr [rdi+rdx*8],rcx       ;y[i] = rcx

        add rax,rcx                         ;update running sum

        inc edx                             ;edx = i + i
        cmp edx,r11d                        ;is i >= n?
        jl @B                               ;jump if i < n

InvalidCount:

; Function epilog
        pop rdi                             ;restore caller's rdi
        pop rsi                             ;restore caller's rsi
        ret
CalcArrayValues_ endp
        end
