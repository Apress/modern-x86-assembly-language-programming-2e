;-------------------------------------------------
;               Ch10_04.asm
;-------------------------------------------------

; The following structure must match the structure that's declared in the file .h file
ClipData            struct
Src                 qword ?             ;source buffer pointer
Des                 qword ?             ;destination buffer pointer
NumPixels           qword ?             ;number of pixels
NumClippedPixels    qword ?             ;number of clipped pixels
ThreshLo            byte ?              ;low threshold
ThreshHi            byte ?              ;high threshold
ClipData            ends

; extern "C" bool Avx2ClipPixels_(ClipData* cd)

            .code
Avx2ClipPixels_ proc

; Load and validate arguments
        xor eax,eax                         ;set error return code
        xor r8d,r8d                         ;r8 = number of clipped pixels

        mov rdx,[rcx+ClipData.NumPixels]    ;rdx = num_pixels
        or rdx,rdx
        jz Done                             ;jump of num_pixels is zero
        test rdx,1fh
        jnz Done                            ;jump if num_pixels % 32 != 0

        mov r10,[rcx+ClipData.Src]          ;r10 = Src
        test r10,1fh
        jnz Done                            ;jump if Src is misaligned

        mov r11,[rcx+ClipData.Des]          ;r11 = Des
        test r11,1fh
        jnz Done                            ;jump if Des is misaligned

; Create packed thresh_lo and thresh_hi data values
        vpbroadcastb ymm4,[rcx+ClipData.ThreshLo]   ;ymm4 = packed thresh_lo
        vpbroadcastb ymm5,[rcx+ClipData.ThreshHi]   ;ymm5 = packed thresh_hi

; Clip pixels to threshold values
@@:     vmovdqa ymm0,ymmword ptr [r10]      ;ymm0 = 32 pixels
        vpmaxub ymm1,ymm0,ymm4              ;clip to thresh_lo
        vpminub ymm2,ymm1,ymm5              ;clip to thresh_hi
        vmovdqa ymmword ptr [r11],ymm2      ;save clipped pixels

; Count number of clipped pixels
        vpcmpeqb ymm3,ymm2,ymm0             ;compare clipped pixels to original
        vpmovmskb eax,ymm3                  ;eax = mask of non-clipped pixels
        not eax                             ;eax = mask of clipped pixels
        popcnt eax,eax                      ;eax = number of clipped pixels
        add r8,rax                          ;update clipped pixel count

; Update pointers and loop counter
        add r10,32                          ;update Src ptr
        add r11,32                          ;update Des ptr
        sub rdx,32                          ;update loop counter
        jnz @B                              ;repeat if not done

        mov eax,1                           ;set success return code

; Save num_clipped_pixels

Done:   mov [rcx+ClipData.NumClippedPixels],r8  ;save num_clipped_pixels
        vzeroupper
        ret

Avx2ClipPixels_ endp
        end
