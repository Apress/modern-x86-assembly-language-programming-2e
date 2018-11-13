;-------------------------------------------------
;               Ch07_03.asm
;-------------------------------------------------

; extern "C" void AvxPackedMulI16_(XmmVal c[2], const XmmVal* a, const XmmVal* b)

        .code
AvxPackedMulI16_ proc
        vmovdqa xmm0,xmmword ptr [rdx]      ;xmm0 = a
        vmovdqa xmm1,xmmword ptr [r8]       ;xmm1 = b

        vpmullw xmm2,xmm0,xmm1              ;xmm2 = packed a * b low result
        vpmulhw xmm3,xmm0,xmm1              ;xmm3 = packed a * b high result

        vpunpcklwd xmm4,xmm2,xmm3           ;merge low and high results 
        vpunpckhwd xmm5,xmm2,xmm3           ;into final signed dwords

        vmovdqa xmmword ptr [rcx],xmm4      ;save final results
        vmovdqa xmmword ptr [rcx+16],xmm5
        ret
AvxPackedMulI16_ endp

; extern "C" void AvxPackedMulI32A_(XmmVal c[2], const XmmVal* a, const XmmVal* b)

AvxPackedMulI32A_ proc

; Perform packed signed dword multiplication.  Note that vpmuldq
; performs following operations:
;
; xmm2[63:0]   = xmm0[31:0]  * xmm1[31:0]
; xmm2[127:64] = xmm0[95:64] * xmm1[95:64]

        vmovdqa xmm0,xmmword ptr [rdx]      ;xmm0 = a
        vmovdqa xmm1,xmmword ptr [r8]       ;xmm1 = b
        vpmuldq xmm2,xmm0,xmm1

; Shift source operands right by 4 bytes and repeat vpmuldq
        vpsrldq xmm0,xmm0,4
        vpsrldq xmm1,xmm1,4
        vpmuldq xmm3,xmm0,xmm1

; Save results
        vpextrq qword ptr [rcx],xmm2,0      ;save xmm2[63:0]
        vpextrq qword ptr [rcx+8],xmm3,0    ;save xmm3[63:0]
        vpextrq qword ptr [rcx+16],xmm2,1   ;save xmm2[127:63]
        vpextrq qword ptr [rcx+24],xmm3,1   ;save xmm3[127:63]
        ret
AvxPackedMulI32A_ endp

; extern "C" void AvxPackedMulI32B_(XmmVal*, const XmmVal* a, const XmmVal* b)

AvxPackedMulI32B_ proc

; Perform packed signed integer multiplication and save low packed dword result
        vmovdqa xmm0,xmmword ptr [rdx]              ;xmm0 = a
        vpmulld xmm1,xmm0,xmmword ptr [r8]          ;xmm1 = packed a * b
        vmovdqa xmmword ptr [rcx],xmm1              ;save packed dword result
        ret
AvxPackedMulI32B_ endp
        end
