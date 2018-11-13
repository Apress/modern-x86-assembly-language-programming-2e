;-------------------------------------------------
;               Ch07_02.asm
;-------------------------------------------------

; extern "C" bool AvxPackedIntegerShift_(XmmVal& b, const XmmVal& a, ShiftOp shift_op, unsigned int count)
;
; Returns:      0 = invalid shift_op argument, 1 = success
;
; Note:         This module requires linker option /LARGEADDRESSAWARE:NO
;               to be explicitly set.

        .code
AvxPackedIntegerShift_ proc
; Make sure 'shift_op' is valid
        mov r8d,r8d                     ;zero extend shift_op
        cmp r8,ShiftOpTableCount        ;compare against table count
        jae Error                       ;jump if shift_op is invalid

; Jump to the operation specified by shift_op
        vmovdqa xmm0,xmmword ptr [rdx]  ;xmm0 = a
        vmovd xmm1,r9d                  ;xmm1[31:0] = shift count
        mov eax,1                       ;set success return code
        jmp [ShiftOpTable+r8*8]

; Packed shift left logical - word
U16_LL: vpsllw xmm2,xmm0,xmm1
        vmovdqa xmmword ptr [rcx],xmm2
        ret

; Packed shift right logical - word
U16_RL: vpsrlw xmm2,xmm0,xmm1
        vmovdqa xmmword ptr [rcx],xmm2
        ret

; Packed shift right arithmetic - word
U16_RA: vpsraw xmm2,xmm0,xmm1
        vmovdqa xmmword ptr [rcx],xmm2
        ret

; Packed shift left logical - doubleword
U32_LL: vpslld xmm2,xmm0,xmm1
        vmovdqa xmmword ptr [rcx],xmm2
        ret

; Packed shift right logical - doubleword
U32_RL: vpsrld xmm2,xmm0,xmm1
        vmovdqa xmmword ptr [rcx],xmm2
        ret

; Packed shift right arithmetic - doubleword
U32_RA: vpsrad xmm2,xmm0,xmm1
        vmovdqa xmmword ptr [rcx],xmm2
        ret

Error:  xor eax,eax                     ;set error code
        vpxor xmm0,xmm0,xmm0            
        vmovdqa xmmword ptr [rcx],xmm0  ;set result to zero
        ret

; The order of the labels in the following table must correspond
; to the enums that are defined in .cpp file.

                align 8
ShiftOpTable    qword U16_LL, U16_RL, U16_RA
                qword U32_LL, U32_RL, U32_RA
ShiftOpTableCount equ ($ - ShiftOpTable) / size qword

AvxPackedIntegerShift_ endp
        end
