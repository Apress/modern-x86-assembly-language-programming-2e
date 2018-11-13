;-------------------------------------------------
;               Ch06_07.asm
;-------------------------------------------------

        include <MacrosX86-64-AVX.asmh>

; _Mat4x4TransposeF32 macro
;
; Description:  This macro transposes a 4x4 matrix of single-precision
;               floating-point values.
;
;  Input Matrix                    Output Matrix
;  ---------------------------------------------------
;  xmm0    a3 a2 a1 a0             xmm4    d0 c0 b0 a0
;  xmm1    b3 b2 b1 b0             xmm5    d1 c1 b1 a1
;  xmm2    c3 c2 c1 c0             xmm6    d2 c2 b2 a2
;  xmm3    d3 d2 d1 d0             xmm7    d3 c3 b3 a3

_Mat4x4TransposeF32 macro
        vunpcklps xmm6,xmm0,xmm1            ;xmm6 = b1 a1 b0 a0
        vunpckhps xmm0,xmm0,xmm1            ;xmm0 = b3 a3 b2 a2
        vunpcklps xmm7,xmm2,xmm3            ;xmm7 = d1 c1 d0 c0
        vunpckhps xmm1,xmm2,xmm3            ;xmm1 = d3 c3 d2 c2

        vmovlhps xmm4,xmm6,xmm7             ;xmm4 = d0 c0 b0 a0
        vmovhlps xmm5,xmm7,xmm6             ;xmm5 = d1 c1 b1 a1
        vmovlhps xmm6,xmm0,xmm1             ;xmm6 = d2 c2 b2 a2
        vmovhlps xmm7,xmm1,xmm0             ;xmm7 = d3 c3 b2 a3
        endm

; extern "C" void AvxMat4x4TransposeF32_(float* m_des, const float* m_src)

        .code
AvxMat4x4TransposeF32_ proc frame
        _CreateFrame MT_,0,32
        _SaveXmmRegs xmm6,xmm7
        _EndProlog

; Transpose matrix m_src1
        vmovaps xmm0,[rdx]                  ;xmm0 = m_src.row_0
        vmovaps xmm1,[rdx+16]               ;xmm1 = m_src.row_1
        vmovaps xmm2,[rdx+32]               ;xmm2 = m_src.row_2
        vmovaps xmm3,[rdx+48]               ;xmm3 = m_src.row_3

        _Mat4x4TransposeF32

        vmovaps [rcx],xmm4                  ;save m_des.row_0
        vmovaps [rcx+16],xmm5               ;save m_des.row_1
        vmovaps [rcx+32],xmm6               ;save m_des.row_2
        vmovaps [rcx+48],xmm7               ;save m_des.row_3

Done:   _RestoreXmmRegs xmm6,xmm7
        _DeleteFrame
        ret
AvxMat4x4TransposeF32_ endp
        end
