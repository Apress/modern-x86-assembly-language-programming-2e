;-------------------------------------------------
;               Ch03_07.asm
;-------------------------------------------------

; extern "C" size_t ConcatStrings_(char* des, size_t des_size, const char* const* src, size_t src_n);
;
; Returns:      -1      Invalid 'des_size'
;               n >= 0  Length of concatenated string

        .code
ConcatStrings_ proc frame

; Save non-volatile registers
        push rbx
        .pushreg rbx
        push rsi
        .pushreg rsi
        push rdi
        .pushreg rdi
        .endprolog

; Make sure des_size and src_n are valid
        mov rax,-1                          ;set error code

        test rdx,rdx                        ;test des_size 
        jz InvalidArg                       ;jump if des_size is 0

        test r9,r9                          ;test src_n
        jz InvalidArg                       ;jump if src_n is 0

; Registers used processing loop below
;   rbx = des               rdx = des_size
;   r8 = src                r9 = src_n
;   r10 = des_index         r11 = i
;   rcx = string length
;   rsi, rdi = pointers for scasb & movsb instructions

; Perform required initializations
        xor r10,r10                         ;des_index = 0
        xor r11,r11                         ;i = 0
        mov rbx,rcx                         ;rbx = des
        mov byte ptr [rbx],0                ;*des = '\0'

; Repeat loop until concatenation is finished
Loop1:  mov rax,r8                          ;rax = 'src'
        mov rdi,[rax+r11*8]                 ;rdi = src[i]
        mov rsi,rdi                         ;rsi = src[i]

; Compute length of s[i]
        xor eax,eax
        mov rcx,-1
        repne scasb                         ;find '\0'
        not rcx
        dec rcx                             ;rcx = len(src[i])

; Compute des_index + src_len
        mov rax,r10                         ;rax = des_index
        add rax,rcx                         ;des_index + len(src[i])
        cmp rax,rdx                         ;is des_index + src_len >= des_size?
        jge Done                            ;jump if des is too small

; Update des_index
        mov rax,r10                         ;des_index_old = des_index
        add r10,rcx                         ;des_index += len(src[i])

; Copy src[i] to &des[des_index] (rsi already contains src[i])
        inc rcx                             ;rcx = len(src[i]) + 1
        lea rdi,[rbx+rax]                   ;rdi = &des[des_index_old]
        rep movsb                           ;perform string move

; Update i and repeat if not done
        inc r11                             ;i += 1
        cmp r11,r9
        jl Loop1                            ;jump if i < src_n

; Return length of concatenated string

Done:   mov rax,r10                        ;rax = des_index (final length)

; Restore non-volatile registers and return

InvalidArg:
        pop rdi
        pop rsi
        pop rbx
        ret
ConcatStrings_ endp
        end
