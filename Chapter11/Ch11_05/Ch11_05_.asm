;-------------------------------------------------
;               Ch11_05_.asm
;-------------------------------------------------

; extern "C" void SingleToHalfPrecision_(uint16_t x_hp[8], float x_sp[8], int rc);

        .code
SingleToHalfPrecision_ proc

; Convert packed single-precision to packed half-precision
        vmovups ymm0,ymmword ptr [rdx]          ;ymm0 = 8 SPFP values

        cmp r8d,0
        jne @F
        vcvtps2ph xmm1,ymm0,0                   ;round to nearest
        jmp SaveResult

@@:     cmp r8d,1
        jne @F
        vcvtps2ph xmm1,ymm0,1                   ;round down
        jmp SaveResult

@@:     cmp r8d,2
        jne @F
        vcvtps2ph xmm1,ymm0,2                   ;round up
        jmp SaveResult

@@:     cmp r8d,3
        jne @F
        vcvtps2ph xmm1,ymm0,3                   ;truncate
        jmp SaveResult

@@:     vcvtps2ph xmm1,ymm0,4                   ;use MXCSR.RC

SaveResult:
        vmovdqu xmmword ptr [rcx],xmm1          ;save 8 HPFP values
        vzeroupper
        ret

SingleToHalfPrecision_ endp

; extern "C" void HalfToSinglePrecision_(float x_sp[8], uint16_t x_hp[8]);

HalfToSinglePrecision_ proc

; Convert packed half-precision to packed single-precision
        vcvtph2ps ymm0,xmmword ptr [rdx]
        vmovups ymmword ptr [rcx],ymm0          ;save 8 SPFP values

        vzeroupper
        ret

HalfToSinglePrecision_ endp
        end
