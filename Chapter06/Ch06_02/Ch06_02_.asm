;-------------------------------------------------
;               Ch06_02.asm
;-------------------------------------------------

        include <cmpequ.asmh>

; extern "C" void AvxPackedCompareF32_(const XmmVal& a, const XmmVal& b, XmmVal c[8]);

        .code
AvxPackedCompareF32_ proc
        vmovaps xmm0,[rcx]                   ;xmm0 = a
        vmovaps xmm1,[rdx]                   ;xmm1 = b

; Perform packed EQUAL compare
        vcmpps xmm2,xmm0,xmm1,CMP_EQ
        vmovdqa xmmword ptr [r8],xmm2

; Perform packed NOT EQUAL compare
        vcmpps xmm2,xmm0,xmm1,CMP_NEQ
        vmovdqa xmmword ptr [r8+16],xmm2

; Perform packed LESS THAN compare
        vcmpps xmm2,xmm0,xmm1,CMP_LT
        vmovdqa xmmword ptr [r8+32],xmm2

; Perform packed LESS THAN OR EQUAL compare
        vcmpps xmm2,xmm0,xmm1,CMP_LE
        vmovdqa xmmword ptr [r8+48],xmm2

 ; Perform packed GREATER THAN compare
        vcmpps xmm2,xmm0,xmm1,CMP_GT
        vmovdqa xmmword ptr [r8+64],xmm2

; Perform packed GREATER THAN OR EQUAL compare
        vcmpps xmm2,xmm0,xmm1,CMP_GE
        vmovdqa xmmword ptr [r8+80],xmm2

; Perform packed ORDERED compare
        vcmpps xmm2,xmm0,xmm1,CMP_ORD
        vmovdqa xmmword ptr [r8+96],xmm2

; Perform packed UNORDERED compare
        vcmpps xmm2,xmm0,xmm1,CMP_UNORD
        vmovdqa xmmword ptr [r8+112],xmm2
        ret
AvxPackedCompareF32_ endp

; extern "C" void AvxPackedCompareF64_(const XmmVal& a, const XmmVal& b, XmmVal c[8]);

AvxPackedCompareF64_ proc
        vmovapd xmm0,[rcx]                   ;xmm0 = a
        vmovapd xmm1,[rdx]                   ;xmm1 = b

; Perform packed EQUAL compare
        vcmppd xmm2,xmm0,xmm1,CMP_EQ
        vmovdqa xmmword ptr [r8],xmm2

; Perform packed NOT EQUAL compare
        vcmppd xmm2,xmm0,xmm1,CMP_NEQ
        vmovdqa xmmword ptr [r8+16],xmm2

; Perform packed LESS THAN compare
        vcmppd xmm2,xmm0,xmm1,CMP_LT
        vmovdqa xmmword ptr [r8+32],xmm2

; Perform packed LESS THAN OR EQUAL compare
        vcmppd xmm2,xmm0,xmm1,CMP_LE
        vmovdqa xmmword ptr [r8+48],xmm2

 ; Perform packed GREATER THAN compare
        vcmppd xmm2,xmm0,xmm1,CMP_GT
        vmovdqa xmmword ptr [r8+64],xmm2

; Perform packed GREATER THAN OR EQUAL compare
        vcmppd xmm2,xmm0,xmm1,CMP_GE
        vmovdqa xmmword ptr [r8+80],xmm2

; Perform packed ORDERED compare
        vcmppd xmm2,xmm0,xmm1,CMP_ORD
        vmovdqa xmmword ptr [r8+96],xmm2

; Perform packed UNORDERED compare
        vcmppd xmm2,xmm0,xmm1,CMP_UNORD
        vmovdqa xmmword ptr [r8+112],xmm2
        ret
AvxPackedCompareF64_ endp
        end
