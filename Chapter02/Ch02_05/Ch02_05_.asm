;-------------------------------------------------
;               Ch02_05.asm
;-------------------------------------------------

; extern "C" int64_t IntegerMul_(int8_t a, int16_t b, int32_t c, int64_t d, int8_t e, int16_t f, int32_t g, int64_t h);

        .code
IntegerMul_ proc

; Calculate a * b * c * d
        movsx rax,cl                        ;rax = sign_extend(a)
        movsx rdx,dx                        ;rdx = sign_extend(b)
        imul rax,rdx                        ;rax = a * b
        movsxd rcx,r8d                      ;rcx = sign_extend(c)
        imul rcx,r9                         ;rcx = c * d
        imul rax,rcx                        ;rax = a * b * c * d

; Calculate e * f * g * h
        movsx rcx,byte ptr [rsp+40]         ;rcx = sign_extend(e)
        movsx rdx,word ptr [rsp+48]         ;rdx = sign_extend(f)
        imul rcx,rdx                        ;rcx = e * f
        movsxd rdx,dword ptr [rsp+56]       ;rdx = sign_extend(g)
        imul rdx,qword ptr [rsp+64]         ;rdx = g * h
        imul rcx,rdx                        ;rcx = e * f * g * h

; Compute the final product
        imul rax,rcx                        ;rax = final product

        ret
IntegerMul_ endp

; extern "C" int UnsignedIntegerDiv_(uint8_t a, uint16_t b, uint32_t c, uint64_t d, uint8_t e, uint16_t f, uint32_t g, uint64_t h, uint64_t* quo, uint64_t* rem);

UnsignedIntegerDiv_ proc

; Calculate a + b + c + d
        movzx rax,cl                        ;rax = zero_extend(a)
        movzx rdx,dx                        ;rdx = zero_extend(b)
        add rax,rdx                         ;rax = a + b
        mov r8d,r8d                         ;r8 = zero_extend(c)
        add r8,r9                           ;r8 = c + d
        add rax,r8                          ;rax = a + b + c + d
        xor rdx,rdx                         ;rdx:rax = a + b + c + d

; Calculate e + f + g + h
        movzx r8,byte ptr [rsp+40]          ;r8 = zero_extend(e)
        movzx r9,word ptr [rsp+48]          ;r9 = zero_extend(f)
        add r8,r9                           ;r8 = e + f
        mov r10d,[rsp+56]                   ;r10 = zero_extend(g)
        add r10,[rsp+64]                    ;r10 = g + h;
        add r8,r10                          ;r8 = e + f + g + h
        jnz DivOK                           ;jump if divisor is not zero

        xor eax,eax                         ;set error return code
        jmp done

; Calculate (a + b + c + d) / (e + f + g + h)

DivOK:  div r8                              ;unsigned divide rdx:rax / r8
        mov rcx,[rsp+72]
        mov [rcx],rax                       ;save quotient
        mov rcx,[rsp+80]
        mov [rcx],rdx                       ;save remainder

        mov eax,1                           ;set success return code

Done:   ret
UnsignedIntegerDiv_ endp
        end
