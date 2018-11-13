;-------------------------------------------------
;               Ch09_02.asm
;-------------------------------------------------

        include <cmpequ.asmh>
        include <MacrosX86-64-AVX.asmh>

        .const
r4_3p0  real4 3.0
r4_4p0  real4 4.0

        extern c_PI_F32:real4
        extern c_QNaN_F32:real4

; extern "C" void AvxCalcSphereAreaVolume_(float* sa, float* vol, const float* r, size_t n);

        .code
AvxCalcSphereAreaVolume_ proc frame
        _CreateFrame CC_,0,64
        _SaveXmmRegs xmm6,xmm7,xmm8,xmm9
        _EndProlog
                                    
; Initialize
        vbroadcastss ymm0,real4 ptr [r4_4p0]        ;packed 4.0
        vbroadcastss ymm1,real4 ptr [c_PI_F32]      ;packed PI
        vmulps ymm6,ymm0,ymm1                       ;packed 4.0 * PI
        vbroadcastss ymm7,real4 ptr [r4_3p0]        ;packed 3.0
        vbroadcastss ymm8,real4 ptr [c_QNaN_F32]    ;packed QNaN
        vxorps ymm9,ymm9,ymm9                       ;packed 0.0

        xor eax,eax                             ;common offset for arrays

        cmp r9,8
        jb FinalR                               ;skip main loop if n < 8

; Calculate surface area and volume values using packed arithmetic
@@:     vmovdqa ymm0,ymmword ptr [r8+rax]       ;load next 8 radii
        vmulps ymm2,ymm6,ymm0                   ;4.0 * PI * r
        vmulps ymm3,ymm2,ymm0                   ;4.0 * PI * r * r

        vcmpps ymm1,ymm0,ymm9,CMP_LT            ;ymm1 = mask of radii < 0.0

        vandps ymm4,ymm1,ymm8                   ;set surface area to QNaN for radii < 0.0
        vandnps ymm5,ymm1,ymm3                  ;keep surface area for radii >= 0.0
        vorps ymm5,ymm4,ymm5                    ;final packed surface area
        vmovaps ymmword ptr[rcx+rax],ymm5       ;save packed surface area

        vmulps ymm2,ymm3,ymm0                   ;4.0 * PI * r * r * r
        vdivps ymm3,ymm2,ymm7                   ;4.0 * PI * r * r * r / 3.0
        vandps ymm4,ymm1,ymm8                   ;set volume to QNaN for radii < 0.0
        vandnps ymm5,ymm1,ymm3                  ;keep volume for radii >= 0.0
        vorps ymm5,ymm4,ymm5                    ;final packed volume
        vmovaps ymmword ptr[rdx+rax],ymm5       ;save packed volume

        add rax,32                              ;rax = offset to next set of radii
        sub r9,8
        cmp r9,8
        jae @B                                  ;repeat until n < 8

; Perform final calculations using scalar arithmetic
FinalR: test r9,r9
        jz Done                                 ;skip loop of no more elements

@@:     vmovss xmm0,real4 ptr [r8+rax]
        vmulss xmm2,xmm6,xmm0                   ;4.0 * PI * r
        vmulss xmm3,xmm2,xmm0                   ;4.0 * PI * r * r

        vcmpss xmm1,xmm0,xmm9,CMP_LT

        vandps xmm4,xmm1,xmm8
        vandnps xmm5,xmm1,xmm3
        vorps xmm5,xmm4,xmm5
        vmovss real4 ptr[rcx+rax],xmm5          ;save surface area

        vmulss xmm2,xmm3,xmm0                   ;4.0 * PI * r * r * r
        vdivss xmm3,xmm2,xmm7                   ;4.0 * PI * r * r * r / 3.0
        vandps xmm4,xmm1,xmm8
        vandnps xmm5,xmm1,xmm3
        vorps xmm5,xmm4,xmm5
        vmovss real4 ptr[rdx+rax],xmm5          ;save volume

        add rax,4
        dec r9
        jnz @B                                  ;repeat until done

Done:   vzeroupper

        _RestoreXmmRegs xmm6,xmm7,xmm8,xmm9
        _DeleteFrame
        ret
AvxCalcSphereAreaVolume_ endp
        end
