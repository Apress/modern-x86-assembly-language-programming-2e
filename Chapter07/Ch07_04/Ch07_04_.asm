;-------------------------------------------------
;               Ch07_04_.asm
;-------------------------------------------------

; extern "C" bool AvxCalcMinMaxU8_(uint8_t* x, size_t n, uint8_t* x_min, uint8_t* x_max)
;
; Returns:      0 = invalid n or unaligned array, 1 = success

            .const
            align 16
StartMinVal qword 0ffffffffffffffffh    ;Initial packed min values
            qword 0ffffffffffffffffh

StartMaxVal qword 0000000000000000h     ;Initial packed max values
            qword 0000000000000000h

            .code
AvxCalcMinMaxU8_ proc

; Make sure 'n' is valid
        xor eax,eax                         ;set error return code
        or rdx,rdx                          ;is n == 0?
        jz Done                             ;jump if yes

        test rdx,3fh                        ;is n a multiple of 64?
        jnz Done                            ;jump if no

        test rcx,0fh                        ;is x properly aligned?
        jnz Done                            ;jump if no

; Initialize packed min-max values
        vmovdqa xmm2,xmmword ptr [StartMinVal]
        vmovdqa xmm3,xmm2                       ;xmm3:xmm2 = packed min values
        vmovdqa xmm4,xmmword ptr [StartMaxVal]
        vmovdqa xmm5,xmm4                       ;xmm5:xmm4 = packed max values

; Scan array for min & max values
@@:     vmovdqa xmm0,xmmword ptr [rcx]        ;xmm0 = x[i + 15] : x[i]
        vmovdqa xmm1,xmmword ptr [rcx+16]     ;xmm1 = x[i + 31] : x[i + 16]
        vpminub xmm2,xmm2,xmm0
        vpminub xmm3,xmm3,xmm1                ;xmm3:xmm2 = updated min values
        vpmaxub xmm4,xmm4,xmm0
        vpmaxub xmm5,xmm5,xmm1                ;xmm5:xmm4 = updated max values

        vmovdqa xmm0,xmmword ptr [rcx+32]     ;xmm0 = x[i + 47] : x[i + 32]
        vmovdqa xmm1,xmmword ptr [rcx+48]     ;xmm1 = x[i + 63] : x[i + 48]
        vpminub xmm2,xmm2,xmm0
        vpminub xmm3,xmm3,xmm1                ;xmm3:xmm2 = updated min values
        vpmaxub xmm4,xmm4,xmm0
        vpmaxub xmm5,xmm5,xmm1                ;xmm5:xmm4 = updated max values

        add rcx,64
        sub rdx,64
        jnz @B

; Determine final minimum value
        vpminub xmm0,xmm2,xmm3              ;xmm0[127:0] = final 16 min vals
        vpsrldq xmm1,xmm0,8                 ;xmm1[63:0] = xmm0[127:64]
        vpminub xmm2,xmm1,xmm0              ;xmm2[63:0] = final 8 min vals
        vpsrldq xmm3,xmm2,4                 ;xmm3[31:0] = xmm2[63:32]
        vpminub xmm0,xmm3,xmm2              ;xmm0[31:0] = final 4 min vals
        vpsrldq xmm1,xmm0,2                 ;xmm1[15:0] = xmm0[31:16]
        vpminub xmm2,xmm1,xmm0              ;xmm2[15:0] = final 2 min vals
        vpextrw eax,xmm2,0                  ;ax = final 2 min vals
        cmp al,ah
        jbe @F                              ;jump if al <= ah
        mov al,ah                           ;al = final min value
@@:     mov [r8],al                         ;save final min

; Determine final maximum value
        vpmaxub xmm0,xmm4,xmm5              ;xmm0[127:0] = final 16 max vals
        vpsrldq xmm1,xmm0,8                 ;xmm1[63:0] = xmm0[127:64]
        vpmaxub xmm2,xmm1,xmm0              ;xmm2[63:0] = final 8 max vals
        vpsrldq xmm3,xmm2,4                 ;xmm3[31:0] = xmm2[63:32]
        vpmaxub xmm0,xmm3,xmm2              ;xmm0[31:0] = final 4 max vals
        vpsrldq xmm1,xmm0,2                 ;xmm1[15:0] = xmm0[31:16]
        vpmaxub xmm2,xmm1,xmm0              ;xmm2[15:0] = final 2 max vals
        vpextrw eax,xmm2,0                  ;ax = final 2 min vals
        cmp al,ah
        jae @F                              ;jump if al >= ah
        mov al,ah                           ;al = final max value
@@:     mov [r9],al                         ;save final max

        mov eax,1                           ;set success return code
Done:   ret
AvxCalcMinMaxU8_ endp
        end
