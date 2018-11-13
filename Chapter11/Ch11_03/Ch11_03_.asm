;-------------------------------------------------
;               Ch11_03_.asm
;-------------------------------------------------

; extern "C" uint64_t GprMulx_(uint32_t a, uint32_t b, uint64_t flags[2]);
;
; Requires      BMI2

        .code
GprMulx_ proc

; Save copy of status flags before mulx
        pushfq
        pop rax
        mov qword ptr [r8],rax              ;save original status flags

; Perform flagless multiplication. The mulx instruction below computes
; the product of explicit source operand ecx (a) and implicit source
; operand edx (b). The 64-bit result is saved to the register pair r11d:r10d.
        mulx r11d,r10d,ecx                  ;r11d:r10d = a * b

; Save copy of status flags after mulx
        pushfq
        pop rax
        mov qword ptr [r8+8],rax            ;save post mulx status flags

; Move 64-bit result to rax
        mov eax,r10d
        shl r11,32
        or rax,r11
        ret
GprMulx_ endp

; extern "C" void GprShiftx_(uint32_t x, uint32_t count, uint32_t results[3], uint64_t flags[4])
;
; Requires      BMI2

GprShiftx_ proc

; Save copy of status flags before shifts
        pushfq
        pop rax
        mov qword ptr [r9],rax              ;save original status flags

; Load argument values and perform shifts.  Note that each shift
; instruction requires three operands: DesOp, SrcOp, and CountOp.

        sarx eax,ecx,edx                    ;shift arithmetic right
        mov dword ptr [r8],eax
        pushfq
        pop rax
        mov qword ptr [r9+8],rax

        shlx eax,ecx,edx                    ;shift logical left
        mov dword ptr [r8+4],eax
        pushfq
        pop rax
        mov qword ptr [r9+16],rax

        shrx eax,ecx,edx                    ;shift logical right
        mov dword ptr [r8+8],eax
        pushfq
        pop rax
        mov qword ptr [r9+24],rax

        ret
GprShiftx_ endp
        end
