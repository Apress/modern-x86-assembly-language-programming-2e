;-------------------------------------------------
;               Ch05_05.asm
;-------------------------------------------------

        include <cmpequ.asmh>

; extern "C" void CompareVCMPSD_(double a, double b, bool* results)

        .code
CompareVCMPSD_ proc

; Perform compare for equality
        vcmpsd xmm2,xmm0,xmm1,CMP_EQ        ;perform compare operation
        vmovq rax,xmm2                      ;rax = compare result (all 1s or 0s)
        and al,1                            ;mask out unneeded bits
        mov byte ptr [r8],al                ;save result as C++ bool

; Perform compare for inequality
        vcmpsd xmm2,xmm0,xmm1,CMP_NEQ
        vmovq rax,xmm2
        and al,1
        mov byte ptr [r8+1],al

; Perform compare for less than
        vcmpsd xmm2,xmm0,xmm1,CMP_LT
        vmovq rax,xmm2
        and al,1
        mov byte ptr [r8+2],al

; Perform compare for less than or equal
        vcmpsd xmm2,xmm0,xmm1,CMP_LE
        vmovq rax,xmm2
        and al,1
        mov byte ptr [r8+3],al

; Perform compare for greater than
        vcmpsd xmm2,xmm0,xmm1,CMP_GT
        vmovq rax,xmm2
        and al,1
        mov byte ptr [r8+4],al

; Perform compare for greater than or equal
        vcmpsd xmm2,xmm0,xmm1,CMP_GE
        vmovq rax,xmm2
        and al,1
        mov byte ptr [r8+5],al

; Perform compare for ordered
        vcmpsd xmm2,xmm0,xmm1,CMP_ORD
        vmovq rax,xmm2
        and al,1
        mov byte ptr [r8+6],al

; Perform compare for unordered
        vcmpsd xmm2,xmm0,xmm1,CMP_UNORD
        vmovq rax,xmm2
        and al,1
        mov byte ptr [r8+7],al

        ret
CompareVCMPSD_ endp
        end
