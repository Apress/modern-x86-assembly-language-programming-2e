;-------------------------------------------------
;               Ch09_08.asm
;-------------------------------------------------

; For each of the following functions, the contents of y are loaded
; into ymm0 prior to execution of the vgatherXXX instruction in order to
; demonstrate the effects of conditional merging.

        .code
; extern "C" void Avx2Gather8xF32_I32_(float* y, const float* x, const int32_t* indices, const int32_t* merge)

Avx2Gather8xF32_I32_ proc
        vmovups ymm0,ymmword ptr [rcx]      ;ymm0 = y[7]:y[0]
        vmovdqu ymm1,ymmword ptr [r8]       ;ymm1 = indices[7]:indices[0]
        vmovdqu ymm2,ymmword ptr [r9]       ;ymm2 = merge[7]:merge[0]
        vpslld ymm2,ymm2,31                 ;shift merge vals to high-order bits
        vgatherdps ymm0,[rdx+ymm1*4],ymm2   ;ymm0 = gathered elements
        vmovups ymmword ptr [rcx],ymm0      ;save gathered elements

        vzeroupper
        ret
Avx2Gather8xF32_I32_ endp

; extern "C" void Avx2Gather8xF32_I64_(float* y, const float* x, const int64_t* indices, const int32_t* merge)

Avx2Gather8xF32_I64_ proc
        vmovups xmm0,xmmword ptr [rcx]      ;xmm0 = y[3]:y[0]
        vmovdqu ymm1,ymmword ptr [r8]       ;ymm1 = indices[3]:indices[0]
        vmovdqu xmm2,xmmword ptr [r9]       ;xmm2 = merge[3]:merge[0]
        vpslld xmm2,xmm2,31                 ;shift merge vals to high-order bits
        vgatherqps xmm0,[rdx+ymm1*4],xmm2   ;xmm0 = gathered elements
        vmovups xmmword ptr [rcx],xmm0      ;save gathered elements

        vmovups xmm3,xmmword ptr [rcx+16]   ;xmm0 = des[7]:des[4]
        vmovdqu ymm1,ymmword ptr [r8+32]    ;ymm1 = indices[7]:indices[4]
        vmovdqu xmm2,xmmword ptr [r9+16]    ;xmm2 = merge[7]:merge[4]
        vpslld xmm2,xmm2,31                 ;shift merge vals to high-order bits
        vgatherqps xmm3,[rdx+ymm1*4],xmm2   ;xmm0 = gathered elements
        vmovups xmmword ptr [rcx+16],xmm3   ;save gathered elements

        vzeroupper
        ret
Avx2Gather8xF32_I64_ endp

; extern "C" void Avx2Gather8xF64_I32_(double* y, const double* x, const int32_t* indices, const int64_t* merge)

Avx2Gather8xF64_I32_ proc
        vmovupd ymm0,ymmword ptr [rcx]      ;ymm0 = y[3]:y[0]
        vmovdqu xmm1,xmmword ptr [r8]       ;xmm1 = indices[3]:indices[0]
        vmovdqu ymm2,ymmword ptr [r9]       ;ymm2 = merge[3]:merge[0]
        vpsllq ymm2,ymm2,63                 ;shift merge vals to high-order bits
        vgatherdpd ymm0,[rdx+xmm1*8],ymm2   ;ymm0 = gathered elements
        vmovupd ymmword ptr [rcx],ymm0      ;save gathered elements

        vmovupd ymm0,ymmword ptr [rcx+32]   ;ymm0 = y[7]:y[4]
        vmovdqu xmm1,xmmword ptr [r8+16]    ;xmm1 = indices[7]:indices[4]
        vmovdqu ymm2,ymmword ptr [r9+32]    ;ymm2 = merge[7]:merge[4]
        vpsllq ymm2,ymm2,63                 ;shift merge vals to high-order bits
        vgatherdpd ymm0,[rdx+xmm1*8],ymm2   ;ymm0 = gathered elements
        vmovupd ymmword ptr [rcx+32],ymm0   ;save gathered elements

        vzeroupper
        ret
Avx2Gather8xF64_I32_ endp

; extern "C" void Avx2Gather8xF64_I64_(double* y, const double* x, const int64_t* indices, const int64_t* merge)

Avx2Gather8xF64_I64_ proc
        vmovupd ymm0,ymmword ptr [rcx]      ;ymm0 = y[3]:y[0]
        vmovdqu ymm1,ymmword ptr [r8]       ;ymm1 = indices[3]:indices[0]
        vmovdqu ymm2,ymmword ptr [r9]       ;ymm2 = merge[3]:merge[0]
        vpsllq ymm2,ymm2,63                 ;shift merge vals to high-order bits
        vgatherqpd ymm0,[rdx+ymm1*8],ymm2   ;ymm0 = gathered elements
        vmovupd ymmword ptr [rcx],ymm0      ;save gathered elements

        vmovupd ymm0,ymmword ptr [rcx+32]   ;ymm0 = y[7]:y[4]
        vmovdqu ymm1,ymmword ptr [r8+32]    ;ymm1 = indices[7]:indices[4]
        vmovdqu ymm2,ymmword ptr [r9+32]    ;ymm2 = merge[7]:merge[4]
        vpsllq ymm2,ymm2,63                 ;shift merge vals to high-order bits
        vgatherqpd ymm0,[rdx+ymm1*8],ymm2   ;ymm0 = gathered elements
        vmovupd ymmword ptr [rcx+32],ymm0   ;save gathered elements

        vzeroupper
        ret
Avx2Gather8xF64_I64_ endp
        end
