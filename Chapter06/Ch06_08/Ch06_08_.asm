;-------------------------------------------------
;               Ch06_08.asm
;-------------------------------------------------

        include <MacrosX86-64-AVX.asmh>

; _Mat4x4MulCalcRowF32 macro
;
; Description:  This macro is used to compute one row of a 4x4 matrix
;               multiply.
;
; Registers:    xmm0 = m_src2.row0
;               xmm1 = m_src2.row1
;               xmm2 = m_src2.row2
;               xmm3 = m_src2.row3
;               rcx = m_des ptr
;               rdx = m_src1 ptr
;               xmm4 - xmm7 = scratch registers

_Mat4x4MulCalcRowF32 macro disp
        vbroadcastss xmm4,real4 ptr [rdx+disp]      ;broadcast m_src1[i][0]
        vbroadcastss xmm5,real4 ptr [rdx+disp+4]    ;broadcast m_src1[i][1]
        vbroadcastss xmm6,real4 ptr [rdx+disp+8]    ;broadcast m_src1[i][2]
        vbroadcastss xmm7,real4 ptr [rdx+disp+12]   ;broadcast m_src1[i][3]

        vmulps xmm4,xmm4,xmm0                       ;m_src1[i][0] * m_src2.row_0
        vmulps xmm5,xmm5,xmm1                       ;m_src1[i][1] * m_src2.row_1
        vmulps xmm6,xmm6,xmm2                       ;m_src1[i][2] * m_src2.row_2 
        vmulps xmm7,xmm7,xmm3                       ;m_src1[i][3] * m_src2.row_3

        vaddps xmm4,xmm4,xmm5                       ;calc m_des.row_i
        vaddps xmm6,xmm6,xmm7
        vaddps xmm4,xmm4,xmm6

        vmovaps[rcx+disp],xmm4                      ;save m_des.row_i
        endm

; extern "C" void AvxMat4x4MulF32_(float* m_des, const float* m_src1, const float* m_src2)
;
; Description:  The following function computes the product of two
;               single-precision floating-point 4x4 matrices.

        .code
AvxMat4x4MulF32_ proc frame
        _CreateFrame MM_,0,32
        _SaveXmmRegs xmm6,xmm7
        _EndProlog

; Compute matrix product m_des = m_src1 * m_src2
        vmovaps xmm0,[r8]                   ;xmm0 = m_src2.row_0
        vmovaps xmm1,[r8+16]                ;xmm1 = m_src2.row_1
        vmovaps xmm2,[r8+32]                ;xmm2 = m_src2.row_2
        vmovaps xmm3,[r8+48]                ;xmm3 = m_src2.row_3

        _Mat4x4MulCalcRowF32 0              ;calculate m_des.row_0
        _Mat4x4MulCalcRowF32 16             ;calculate m_des.row_1
        _Mat4x4MulCalcRowF32 32             ;calculate m_des.row_2
        _Mat4x4MulCalcRowF32 48             ;calculate m_des.row_3

Done:   _RestoreXmmRegs xmm6,xmm7
        _DeleteFrame
        ret
AvxMat4x4MulF32_ endp
        end
