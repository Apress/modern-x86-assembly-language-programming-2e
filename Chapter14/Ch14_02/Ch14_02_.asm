;-------------------------------------------------
;               Ch14_02.asm
;-------------------------------------------------

        include <cmpequ.asmh>
        extern c_NumPixelsMax:dword

            .const
r4_1p0      real4 1.0
r4_255p0    real4 255.0

; extern "C" bool Avx512ConvertImgU8ToF32_(float* des, const uint8_t* src, uint32_t num_pixels)

        .code
Avx512ConvertImgU8ToF32_ proc

; Make sure num_pixels is valid and pixel buffers are properly aligned
        xor eax,eax                         ;set error return code
        or r8d,r8d
        jz Done                             ;jump if num_pixels is zero
        cmp r8d,[c_NumPixelsMax]
        ja Done                             ;jump if num_pixels too big
        test r8d,3fh
        jnz Done                            ;jump if num_pixels % 64 != 0
        test rcx,3fh
        jnz Done                            ;jump if des not aligned
        test rdx,3fh
        jnz Done                            ;jump if src not aligned

; Perform required initializations
        shr r8d,6                               ;number of blocks (64 pixels/block)
        vmovss xmm0,real4 ptr [r4_1p0]
        vdivss xmm1,xmm0,real4 ptr [r4_255p0]
        vbroadcastss zmm5,xmm1                  ;packed scale factor (1.0 / 255.0)

        align 16
@@:     vpmovzxbd zmm0,xmmword ptr [rdx]
        vpmovzxbd zmm1,xmmword ptr [rdx+16]
        vpmovzxbd zmm2,xmmword ptr [rdx+32]
        vpmovzxbd zmm3,xmmword ptr [rdx+48] ;zmm3:zmm0 = 64 U32 pixels

; Convert pixels from uint8_t to float [0.0, 255.0]
        vcvtudq2ps zmm16,zmm0
        vcvtudq2ps zmm17,zmm1
        vcvtudq2ps zmm18,zmm2
        vcvtudq2ps zmm19,zmm3               ;zmm19:zmm16 = 64 F32 pixels

; Normalize pixels to [0.0, 1.0]
        vmulps zmm20,zmm16,zmm5
        vmulps zmm21,zmm17,zmm5
        vmulps zmm22,zmm18,zmm5
        vmulps zmm23,zmm19,zmm5             ;zmm23:zmm20 = 64 F32 pixels (normalized)

; Save F32 pixels to des
        vmovaps zmmword ptr [rcx],zmm20
        vmovaps zmmword ptr [rcx+64],zmm21
        vmovaps zmmword ptr [rcx+128],zmm22
        vmovaps zmmword ptr [rcx+192],zmm23

; Update pointers and counters
        add rdx,64
        add rcx,256
        sub r8d,1
        jnz @B

        mov eax,1                       ;set success return code

Done:   vzeroupper
        ret
Avx512ConvertImgU8ToF32_ endp

; extern "C" bool Avx512ConvertImgF32ToU8_(uint8_t* des, const float* src, uint32_t num_pixels)

Avx512ConvertImgF32ToU8_ proc
; Make sure num_pixels is valid and pixel buffers are properly aligned
        xor eax,eax                         ;set error return code
        or r8d,r8d
        jz Done                             ;jump if num_pixels is zero
        cmp r8d,[c_NumPixelsMax]
        ja Done                             ;jump if num_pixels too big
        test r8d,3fh
        jnz Done                            ;jump if num_pixels % 64 != 0
        test rcx,3fh
        jnz Done                            ;jump if des not aligned
        test rdx,3fh
        jnz Done                            ;jump if src not aligned

; Perform required initializations
        shr r8d,4                           ;number of pixel blocks (16 pixels / block)
        vxorps zmm29,zmm29,zmm29            ;packed 0.0
        vbroadcastss zmm30,[r4_1p0]         ;packed 1.0
        vbroadcastss zmm31,[r4_255p0]       ;packed 255.0

        align 16
@@:     vmovaps zmm0,zmmword ptr [rdx]      ;zmm0 = block of 16 pixels

; Clip pixels in current block to [0,0. 1.0]
        vcmpps k1,zmm0,zmm29,CMP_GE         ;k1 = mask of pixels >= 0.0
        vmovaps zmm1{k1}{z},zmm0            ;all pixels >= 0.0

        vcmpps k2,zmm1,zmm30,CMP_GT         ;k2 = mask of pixels > 1.0
        vmovaps zmm1{k2},zmm30              ;all pixels clipped to [0.0, 1.0]

; Convert pixels to uint8_t and save to des
        vmulps zmm2,zmm1,zmm31              ;all pixels [0.0, 255.0]
        vcvtps2udq zmm3,zmm2{ru-sae}        ;all pixels [0, 255]
        vpmovusdb xmmword ptr [rcx],zmm3    ;save pixels as unsigned bytes

; Update pointers and counters
        add rdx,64
        add rcx,16
        sub r8d,1
        jnz @B

        mov eax,1                           ;set success return code

Done:   vzeroupper
        ret
Avx512ConvertImgF32ToU8_ endp
        end
