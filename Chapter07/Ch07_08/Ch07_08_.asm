;-------------------------------------------------
;               Ch07_08.asm
;-------------------------------------------------

        include <MacrosX86-64-AVX.asmh>

; Image threshold data structure (see Ch07_08.h)
ITD                 struct
PbSrc               qword ?
PbMask              qword ?
NumPixels           dword ?
NumMaskedPixels     dword ?
SumMaskedPixels     dword ?
Threshold           byte ?
Pad                 byte 3 dup(?)
MeanMaskedPixels    real8 ?
ITD                 ends

                .const
                align 16
PixelScale      byte 16 dup(80h)            ;uint8 to int8 scale value
CountPixelsMask byte 16 dup(01h)            ;mask to count pixels
R8_MinusOne     real8 -1.0                  ;invalid mean value

                .code
                extern IsValid:proc

; extern "C" bool AvxThresholdImage_(ITD* itd);
;
; Returns:      0 = invalid size or unaligned image buffer, 1 = success

AvxThresholdImage_ proc frame
        _CreateFrame TI_,0,0,rbx
        _EndProlog

; Verify the arguments in the ITD structure
        mov rbx,rcx                         ;copy itd ptr to non-volatile register
        mov ecx,[rbx+ITD.NumPixels]         ;ecx = num_pixels
        mov rdx,[rbx+ITD.PbSrc]             ;rdx = pb_src
        mov r8,[rbx+ITD.PbMask]             ;r8 = pb_mask
        sub rsp,32                          ;allocate home area for IsValid
        call IsValid                        ;validate args
        or al,al
        jz Done                             ;jump if invalid

; Initialize registers for processing loop
        mov ecx,[rbx+ITD.NumPixels]             ;ecx = num_pixels
        shr ecx,6                               ;ecx = number of 64b pixel blocks
        mov rdx,[rbx+ITD.PbSrc]                 ;rdx = pb_src
        mov r8,[rbx+ITD.PbMask]                 ;r8 = pb_mask

        movzx r9d,byte ptr [rbx+ITD.Threshold]  ;r9d = threshold
        vmovd xmm1,r9d                          ;xmm1[7:0] = threshold
        vpxor xmm0,xmm0,xmm0                    ;mask for vpshufb
        vpshufb xmm1,xmm1,xmm0                  ;xmm1 = packed threshold

        vmovdqa xmm4,xmmword ptr [PixelScale]   ;packed pixel scale factor
        vpsubb xmm5,xmm1,xmm4                   ;scaled threshold

; Create the mask image
@@:     vmovdqa xmm0,xmmword ptr [rdx]      ;original image pixels
        vpsubb xmm1,xmm0,xmm4               ;scaled image pixels
        vpcmpgtb xmm2,xmm1,xmm5             ;mask pixels
        vmovdqa xmmword ptr [r8],xmm2       ;save mask result

        vmovdqa xmm0,xmmword ptr [rdx+16]
        vpsubb xmm1,xmm0,xmm4
        vpcmpgtb xmm2,xmm1,xmm5
        vmovdqa xmmword ptr [r8+16],xmm2

        vmovdqa xmm0,xmmword ptr [rdx+32]
        vpsubb xmm1,xmm0,xmm4
        vpcmpgtb xmm2,xmm1,xmm5
        vmovdqa xmmword ptr [r8+32],xmm2

        vmovdqa xmm0,xmmword ptr [rdx+48]
        vpsubb xmm1,xmm0,xmm4
        vpcmpgtb xmm2,xmm1,xmm5
        vmovdqa xmmword ptr [r8+48],xmm2

        add rdx,64
        add r8,64                           ;update pointers
        sub ecx,1                           ;update counter
        jnz @B                              ;repeat until done

        mov eax,1                           ;set success return code

Done:   _DeleteFrame rbx
        ret
AvxThresholdImage_ endp

;
; Macro _UpdateBlockSums
;

_UpdateBlockSums macro disp
        vmovdqa xmm0,xmmword ptr [rdx+disp] ;xmm0 = 16 image pixels
        vmovdqa xmm1,xmmword ptr [r8+disp]  ;xmm1 = 16 mask pixels
        vpand xmm2,xmm1,xmm8                ;xmm2 = 16 mask pixels (0x00 or 0x01)
        vpaddb xmm6,xmm6,xmm2               ;update block num_masked_pixels
        vpand xmm2,xmm0,xmm1                ;zero out unmasked image pixel
        vpunpcklbw xmm3,xmm2,xmm9           ;promote image pixels from byte to word
        vpunpckhbw xmm4,xmm2,xmm9          
        vpaddw xmm4,xmm4,xmm3
        vpaddw xmm7,xmm7,xmm4               ;update block sum_mask_pixels
        endm

; extern "C" bool AvxCalcImageMean_(ITD* itd);
;
; Returns:  0 = invalid image size or unaligned image buffer, 1 = success

AvxCalcImageMean_ proc frame
        _CreateFrame CIM_,0,64,rbx
        _SaveXmmRegs xmm6,xmm7,xmm8,xmm9
        _EndProlog

; Verify the arguments in the ITD structure
        mov rbx,rcx                         ;rbx = itd ptr
        mov ecx,[rbx+ITD.NumPixels]         ;ecx = num_pixels
        mov rdx,[rbx+ITD.PbSrc]             ;rdx = pb_src
        mov r8,[rbx+ITD.PbMask]             ;r8 = pb_mask
        sub rsp,32                          ;allocate home area for IsValid
        call IsValid                        ;validate args
        or al,al
        jz Done                             ;jump if invalid

; Initialize registers for processing loop
        mov ecx,[rbx+ITD.NumPixels]         ;ecx = num_pixels
        shr ecx,6                           ;ecx = number of 64b pixel blocks
        mov rdx,[rbx+ITD.PbSrc]             ;rdx = pb_src
        mov r8,[rbx+ITD.PbMask]             ;r8 = pb_mask

        vmovdqa xmm8,xmmword ptr [CountPixelsMask]  ;mask for counting pixels
        vpxor xmm9,xmm9,xmm9                        ;xmm9 = packed zero

        xor r10d,r10d                       ;r10d = num_masked_pixels (1 dword)
        vpxor xmm5,xmm5,xmm5                ;sum_masked_pixels (4 dwords)

;Calculate num_mask_pixels and sum_mask_pixels
LP1:    vpxor xmm6,xmm6,xmm6                ;num_masked_pixels_tmp (16 byte values)
        vpxor xmm7,xmm7,xmm7                ;sum_masked_pixels_tmp (8 word values)

        _UpdateBlockSums 0
        _UpdateBlockSums 16
        _UpdateBlockSums 32
        _UpdateBlockSums 48

; Update num_masked_pixels
        vpsrldq xmm0,xmm6,8
        vpaddb xmm6,xmm6,xmm0               ;num_mask_pixels_tmp (8 byte vals)
        vpsrldq xmm0,xmm6,4
        vpaddb xmm6,xmm6,xmm0               ;num_mask_pixels_tmp (4 byte vals)
        vpsrldq xmm0,xmm6,2
        vpaddb xmm6,xmm6,xmm0               ;num_mask_pixels_tmp (2 byte vals)
        vpsrldq xmm0,xmm6,1
        vpaddb xmm6,xmm6,xmm0               ;num_mask_pixels_tmp (1 byte val)
        vpextrb eax,xmm6,0
        add r10d,eax                        ;num_mask_pixels += num_mask_pixels_tmp

; Update sum_masked_pixels
        vpunpcklwd xmm0,xmm7,xmm9           ;promote sum_mask_pixels_tmp to dwords
        vpunpckhwd xmm1,xmm7,xmm9
        vpaddd xmm5,xmm5,xmm0
        vpaddd xmm5,xmm5,xmm1               ;sum_mask_pixels += sum_masked_pixels_tmp

        add rdx,64                          ;update pb_src pointer
        add r8,64                           ;update pb_mask pointer

        sub rcx,1                           ;update loop counter
        jnz LP1                             ;repeat if not done

; Compute mean of masked pixels
        vphaddd xmm0,xmm5,xmm5
        vphaddd xmm1,xmm0,xmm0
        vmovd eax,xmm1                      ;eax = final sum_mask_pixels

        test r10d,r10d                      ;is num_mask_pixels zero?
        jz NoMean                           ;if yes, skip calc of mean
        vcvtsi2sd xmm0,xmm0,eax             ;xmm0 = sum_masked_pixels
        vcvtsi2sd xmm1,xmm1,r10d            ;xmm1 = num_masked_pixels
        vdivsd xmm2,xmm0,xmm1               ;xmm2 = mean_masked_pixels
        jmp @F

NoMean: vmovsd xmm2,[R8_MinusOne]               ;use -1.0 for no mean

@@:     mov [rbx+ITD.SumMaskedPixels],eax       ;save sum_masked_pixels
        mov [rbx+ITD.NumMaskedPixels],r10d      ;save num_masked_pixels
        vmovsd [rbx+ITD.MeanMaskedPixels],xmm2  ;save mean
        mov eax,1                               ;set success return code

Done:   _RestoreXmmRegs xmm6,xmm7,xmm8,xmm9
        _DeleteFrame rbx
        ret
AvxCalcImageMean_  endp
        end
