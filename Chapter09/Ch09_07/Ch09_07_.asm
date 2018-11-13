;-------------------------------------------------
;               Ch09_07.asm
;-------------------------------------------------

; extern "C" void AvxBlendF32_(YmmVal* des1, YmmVal* src1, YmmVal* src2, YmmVal* idx1)

        .code
AvxBlendF32_ proc
        vmovaps ymm0,ymmword ptr [rdx]  ;ymm0 = src1
        vmovaps ymm1,ymmword ptr [r8]   ;ymm1 = src2
        vmovdqa ymm2,ymmword ptr [r9]   ;ymm2 = idx1
        vblendvps ymm3,ymm0,ymm1,ymm2   ;blend ymm0 & ymm1, ymm2 "indices"
        vmovaps ymmword ptr [rcx],ymm3  ;Save result to des1

        vzeroupper
        ret
AvxBlendF32_ endp

; extern "C" void Avx2PermuteF32_(YmmVal* des1, YmmVal* src1, YmmVal* idx1, YmmVal* des2, YmmVal* src2, YmmVal* idx2)

Avx2PermuteF32_ proc

; Perform vpermps permutation
        vmovaps ymm0,ymmword ptr [rdx]      ;ymm0 = src1
        vmovdqa ymm1,ymmword ptr [r8]       ;ymm1 = idx1
        vpermps ymm2,ymm1,ymm0              ;permute ymm0 using ymm1 indices
        vmovaps ymmword ptr [rcx],ymm2      ;save result to des1

; Perform vpermilps permutation
        mov rdx,[rsp+40]                    ;rdx = src2 ptr
        mov r8,[rsp+48]                     ;r8 = idx2 ptr
        vmovaps ymm3,ymmword ptr [rdx]      ;ymm3 = src2
        vmovdqa ymm4,ymmword ptr [r8]       ;ymm4 = idx1
        vpermilps ymm5,ymm3,ymm4            ;permute ymm3 using ymm4 indices
        vmovaps ymmword ptr [r9],ymm5       ;save result to des2

        vzeroupper
        ret
Avx2PermuteF32_ endp
        end
