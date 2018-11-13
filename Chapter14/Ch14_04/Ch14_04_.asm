;-------------------------------------------------
;               Ch14_04.asm
;-------------------------------------------------

        include <cmpequ.asmh>
        include <MacrosX86-64-AVX.asmh>
        extern c_NumPixelsMax:qword

; This structure must match the structure that's defined in Ch14_04.h
ImageStats          struct
PixelBuffer         qword ?
NumPixels           qword ?
PixelValMin         dword ?
PixelValMax         dword ?
NumPixelsInRange    qword ?
PixelSum            qword ?
PixelSumOfSquares   qword ?
PixelMean           real8 ?
PixelSd             real8 ?
ImageStats          ends

_UpdateSums macro Disp
        vpmovzxbd zmm0,xmmword ptr [rcx+Disp]   ;zmm0 = 16 pixels
        vpcmpud k1,zmm0,zmm31,CMP_GE            ;k1 = mask of pixels >= pixel_val_min
        vpcmpud k2,zmm0,zmm30,CMP_LE            ;k2 = mask of pixels <= pixel_val_max
        kandw k3,k2,k1                          ;k3 = mask of in-range pixels
        vmovdqa32 zmm1{k3}{z},zmm0              ;zmm1 = in-range pixels
        vpaddd zmm16,zmm16,zmm1                 ;update packed pixel_sum
        vpmulld zmm2,zmm1,zmm1
        vpaddd zmm17,zmm17,zmm2                 ;update packed pixel_sum_of_squares
        kmovw rax,k3
        popcnt rax,rax                          ;count number of in-range pixels
        add r10,rax                             ;update num_pixels_in_range
        endm

; extern "C" bool Avx512CalcImageStats_(ImageStats& im_stats);

        .code
Avx512CalcImageStats_ proc frame
        _CreateFrame CIS_,0,0,rsi,r12,r13
        _EndProlog

; Make sure num_pixels is valid and pixel_buff is properly aligned
        xor eax,eax                         ;set error return code

        mov rsi,rcx                                    ;rsi = im_stats ptr
        mov rcx,qword ptr [rsi+ImageStats.PixelBuffer] ;rcx = pixel buffer ptr
        mov rdx,qword ptr [rsi+ImageStats.NumPixels]   ;rdx = num_pixels

        test rdx,rdx
        jz Done                             ;jump if num_pixels is zero
        cmp rdx,[c_NumPixelsMax]
        ja Done                             ;jump if num_pixels too big

        test rcx,3fh
        jnz Done                            ;jump if pixel_buff misaligned

; Perform required initializations
        mov r8d,dword ptr [rsi+ImageStats.PixelValMin]
        mov r9d,dword ptr [rsi+ImageStats.PixelValMax]

        vpbroadcastd zmm31,r8d              ;packed pixel_val_min
        vpbroadcastd zmm30,r9d              ;packed pixel_val_max

        vpxorq zmm29,zmm29,zmm29            ;packed pixel_sum
        vpxorq zmm28,zmm28,zmm28            ;packed pixel_sum_of_squares
        xor r10d,r10d                       ;num_pixels_in_range = 0

; Compute packed versions of pixel_sum and pixel_sum_of_squares
        cmp rdx,64
        jb LB1                              ;jump if there are fewer than 64 pixels

        align 16
@@:     vpxord zmm16,zmm16,zmm16            ;loop packed pixel_sum = 0
        vpxord zmm17,zmm17,zmm17            ;loop packed pixel_sum_of_squares = 0

        _UpdateSums 0                       ;process pixel_buff[i+15]:pixel_buff[i]
        _UpdateSums 16                      ;process pixel_buff[i+31]:pixel_buff[i+16]
        _UpdateSums 32                      ;process pixel_buff[i+47]:pixel_buff[i+32]
        _UpdateSums 48                      ;process pixel_buff[i+63]:pixel_buff[i+48]

        vextracti32x8 ymm0,zmm16,1          ;extract top 8 pixel_sum (dwords)
        vpaddd ymm1,ymm0,ymm16
        vpmovzxdq zmm2,ymm1
        vpaddq zmm29,zmm29,zmm2             ;update packed pixel_sum (qwords)

        vextracti32x8 ymm0,zmm17,1          ;extract top 8 pixel_sum_of_squares (dwords)
        vpaddd ymm1,ymm0,ymm17
        vpmovzxdq zmm2,ymm1
        vpaddq zmm28,zmm28,zmm2             ;update packed pixel_sum_of_squares (qwords)

        add rcx,64                          ;update pb ptr
        sub rdx,64                          ;update num_pixels
        cmp rdx,64
        jae @B                              ;repeat until done

        align 16
LB1:    test rdx,rdx
        jz LB3                              ;jump if no more pixels remain

        xor r13,r13                         ;pixel_sum = 0
        xor r12,r12                         ;pixel_sum_of_squares = 0
        mov r11,rdx                         ;number of remaining pixels

@@:     movzx rax,byte ptr [rcx]            ;load next pixel
        cmp rax,r8
        jb LB2                              ;jump if current pixel < pval_min
        cmp rax,r9
        ja LB2                              ;jump if current pixel > pval_max

        add r13,rax                         ;add to pixel_sum
        mul rax
        add r12,rax                         ;add to pixel_sum_of_squares
        add r10,1                           ;update num_pixels_in_range

LB2:    add rcx,1
        sub r11,1
        jnz @B                              ;repeat until done

; Save num_pixel_in_range
LB3:    mov qword ptr [rsi+ImageStats.NumPixelsInRange],r10

; Reduce packed pixel_sum to single qword
        vextracti64x4 ymm0,zmm29,1
        vpaddq ymm1,ymm0,ymm29
        vextracti64x2 xmm2,ymm1,1
        vpaddq xmm3,xmm2,xmm1
        vpextrq rax,xmm3,0
        vpextrq r11,xmm3,1
        add rax,r11                         ;rax = sum of qwords in zmm29
        add r13,rax                         ;add scalar pixel_sum

        mov qword ptr [rsi+ImageStats.PixelSum],r13

;Reduce packed pixel_sum_of_squares to single qword
        vextracti64x4 ymm0,zmm28,1
        vpaddq ymm1,ymm0,ymm28
        vextracti64x2 xmm2,ymm1,1
        vpaddq xmm3,xmm2,xmm1
        vpextrq rax,xmm3,0
        vpextrq r11,xmm3,1
        add rax,r11                         ;rax = sum of qwords in zmm28
        add r12,rax                         ;add scalar pixel_sum_of_squares

        mov qword ptr [rsi+ImageStats.PixelSumOfSquares],r12

; Calculate final mean and sd
        vcvtusi2sd xmm0,xmm0,r10            ;num_pixels_in_range (DPFP)
        sub r10,1
        vcvtusi2sd xmm1,xmm1,r10            ;num_pixels_in_range - 1 (DPFP)
        vcvtusi2sd xmm2,xmm2,r13            ;pixel_sum (DPFP)
        vcvtusi2sd xmm3,xmm3,r12            ;pixel_sum_of_squares (DPFP)
        vdivsd xmm4,xmm2,xmm0               ;final pixel_mean

        vmovsd real8 ptr [rsi+ImageStats.PixelMean],xmm4

        vmulsd xmm4,xmm0,xmm3               ;num_pixels_in_range * pixel_sum_of_squares
        vmulsd xmm5,xmm2,xmm2               ;pixel_sum * pixel_sum
        vsubsd xmm2,xmm4,xmm5               ;var_num
        vmulsd xmm3,xmm0,xmm1               ;var_den
        vdivsd xmm4,xmm2,xmm3               ;calc variance
        vsqrtsd xmm0,xmm0,xmm4              ;final pixel_sd

        vmovsd real8 ptr [rsi+ImageStats.PixelSd],xmm0

        mov eax,1                           ;set success return code

Done:   vzeroupper
        _DeleteFrame rsi,r12,r13
        ret
Avx512CalcImageStats_ endp
        end
