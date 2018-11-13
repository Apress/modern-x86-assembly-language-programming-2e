;-------------------------------------------------
;               Ch07_01.asm
;-------------------------------------------------

; extern "C" void AvxPackedAddI16_(const XmmVal& a, const XmmVal& b, XmmVal c[2])

        .code
AvxPackedAddI16_ proc

; Packed signed word addition
        vmovdqa xmm0,xmmword ptr [rcx]      ;xmm0 = a
        vmovdqa xmm1,xmmword ptr [rdx]      ;xmm1 = b

        vpaddw xmm2,xmm0,xmm1               ;packed add - wraparound
        vpaddsw xmm3,xmm0,xmm1              ;packed add - saturated

        vmovdqa xmmword ptr [r8],xmm2       ;save c[0]
        vmovdqa xmmword ptr [r8+16],xmm3    ;save c[1]
        ret
AvxPackedAddI16_ endp

; extern "C" void AvxPackedSubI16_(const XmmVal& a, const XmmVal& b, XmmVal c[2])

AvxPackedSubI16_ proc

; Packed signed word subtraction
        vmovdqa xmm0,xmmword ptr [rcx]      ;xmm0 = a
        vmovdqa xmm1,xmmword ptr [rdx]      ;xmm1 = b

        vpsubw xmm2,xmm0,xmm1               ;packed sub - wraparound
        vpsubsw xmm3,xmm0,xmm1              ;packed sub - saturated

        vmovdqa xmmword ptr [r8],xmm2       ;save c[0]
        vmovdqa xmmword ptr [r8+16],xmm3    ;save c[1]
        ret
AvxPackedSubI16_ endp

; extern "C" void AvxPackedAddU16_(const XmmVal& a, const XmmVal& b, XmmVal c[2])

AvxPackedAddU16_ proc

; Packed unsigned word addition
        vmovdqu xmm0,xmmword ptr [rcx]      ;xmm0 = a
        vmovdqu xmm1,xmmword ptr [rdx]      ;xmm1 = b

        vpaddw xmm2,xmm0,xmm1               ;packed add - wraparound
        vpaddusw xmm3,xmm0,xmm1             ;packed add - saturated

        vmovdqu xmmword ptr [r8],xmm2       ;save c[0]
        vmovdqu xmmword ptr [r8+16],xmm3    ;save c[1]
        ret
AvxPackedAddU16_ endp

; extern "C" void AvxPackedSubU16_(const XmmVal& a, const XmmVal& b, XmmVal c[2])

AvxPackedSubU16_ proc

; Packed unsigned word subtraction
        vmovdqu xmm0,xmmword ptr [rcx]      ;xmm0 = a
        vmovdqu xmm1,xmmword ptr [rdx]      ;xmm1 = b

        vpsubw xmm2,xmm0,xmm1               ;packed sub - wraparound
        vpsubusw xmm3,xmm0,xmm1             ;packed sub - saturated

        vmovdqu xmmword ptr [r8],xmm2       ;save c[0]
        vmovdqu xmmword ptr [r8+16],xmm3    ;save c[1]
        ret
AvxPackedSubU16_ endp
        end
