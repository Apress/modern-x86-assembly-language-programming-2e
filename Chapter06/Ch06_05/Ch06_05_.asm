;-------------------------------------------------
;               Ch06_05.asm
;-------------------------------------------------

        extern g_MinValInit:real4
        extern g_MaxValInit:real4

; extern "C" bool CalcArrayMinMaxF32_(float* min_val, float* max_val, const float* x, size_t n)

        .code
CalcArrayMinMaxF32_ proc
; Validate arguments
        xor eax,eax                         ;set error return code

        test r8,0fh                         ;is x aligned to 16-byte boundary?
        jnz Done                            ;jump if no

        vbroadcastss xmm4,real4 ptr [g_MinValInit]     ;xmm4 = min values
        vbroadcastss xmm5,real4 ptr [g_MaxValInit]     ;xmm5 = max values

        cmp r9,4
        jb FinalVals                        ;jump if n < 4

; Main processing loop 
@@:     vmovaps xmm0,xmmword ptr [r8]       ;load next set of array values
        vminps xmm4,xmm4,xmm0               ;update packed min values
        vmaxps xmm5,xmm5,xmm0               ;update packed max values

        add r8,16
        sub r9,4
        cmp r9,4
        jae @B

; Process the final 1 - 3 values of the input array
FinalVals:
        test r9,r9
        jz SaveResults

        vminss xmm4,xmm4,real4 ptr [r8]     ;update packed min values
        vmaxss xmm5,xmm5,real4 ptr [r8]     ;update packed max values
        dec r9
        jz SaveResults

        vminss xmm4,xmm4,real4 ptr [r8+4]
        vmaxss xmm5,xmm5,real4 ptr [r8+4]
        dec r9
        jz SaveResults

        vminss xmm4,xmm4,real4 ptr [r8+8]
        vmaxss xmm5,xmm5,real4 ptr [r8+8]

; Calculate and save final min & max values
SaveResults:
        vshufps xmm0,xmm4,xmm4,00001110b    ;xmm0[63:0] = xmm4[128:64]
        vminps xmm1,xmm0,xmm4               ;xmm1[63:0] contains final 2 values
        vshufps xmm2,xmm1,xmm1,00000001b    ;xmm2[31:0] = xmm1[63:32]
        vminps xmm3,xmm2,xmm1               ;xmm3[31:0] contains final value
        vmovss real4 ptr [rcx],xmm3         ;save array min value

        vshufps xmm0,xmm5,xmm5,00001110b
        vmaxps xmm1,xmm0,xmm5
        vshufps xmm2,xmm1,xmm1,00000001b
        vmaxps xmm3,xmm2,xmm1
        vmovss real4 ptr [rdx],xmm3         ;save array max value

        mov eax,1                           ;set success return code
Done:   ret
CalcArrayMinMaxF32_ endp
        end
