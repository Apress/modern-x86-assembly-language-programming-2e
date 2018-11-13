;-------------------------------------------------
;               Ch13_03.asm
;-------------------------------------------------

; extern "C" void Avx512CvtF32ToU32_(uint32_t val_cvt[4], float val);

        .code
Avx512CvtF32ToU32_ proc
        vcvtss2usi eax,xmm1{rn-sae}         ;Convert using round to nearest
        mov dword ptr [rcx],eax

        vcvtss2usi eax,xmm1{rd-sae}         ;Convert using round down
        mov dword ptr [rcx+4],eax

        vcvtss2usi eax,xmm1{ru-sae}         ;Convert using round up
        mov dword ptr [rcx+8],eax

        vcvtss2usi eax,xmm1{rz-sae}         ;Convert using round to zero (truncate)
        mov dword ptr [rcx+12],eax
        ret
Avx512CvtF32ToU32_ endp

; extern "C" void Avx512CvtF64ToU64_(uint64_t val_cvt[4], double val);

Avx512CvtF64ToU64_ proc
        vcvtsd2usi rax,xmm1{rn-sae}
        mov qword ptr [rcx],rax

        vcvtsd2usi rax,xmm1{rd-sae}
        mov qword ptr [rcx+8],rax

        vcvtsd2usi rax,xmm1{ru-sae}
        mov qword ptr [rcx+16],rax

        vcvtsd2usi rax,xmm1{rz-sae}
        mov qword ptr [rcx+24],rax
        ret
Avx512CvtF64ToU64_ endp

; extern "C" void Avx512CvtF64ToF32_(float val_cvt[4], double val);

Avx512CvtF64ToF32_ proc
        vcvtsd2ss xmm2,xmm2,xmm1{rn-sae}
        vmovss real4 ptr [rcx],xmm2

        vcvtsd2ss xmm2,xmm2,xmm1{rd-sae}
        vmovss real4 ptr [rcx+4],xmm2

        vcvtsd2ss xmm2,xmm2,xmm1{ru-sae}
        vmovss real4 ptr [rcx+8],xmm2

        vcvtsd2ss xmm2,xmm2,xmm1{rz-sae}
        vmovss real4 ptr [rcx+12],xmm2
        ret
Avx512CvtF64ToF32_ endp
        end
