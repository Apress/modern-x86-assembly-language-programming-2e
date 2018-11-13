;-------------------------------------------------
;               Ch09_05.asm
;-------------------------------------------------

        include <MacrosX86-64-AVX.asmh>

; _Mat4x4TransposeF64 macro
;
; Description:  This macro computes the transpose of a 4x4
;               double-precision floating-point matrix.
;
;  Input Matrix                    Output Matrtix
;  ---------------------------------------------------
;  ymm0    a3 a2 a1 a0             ymm0    d0 c0 b0 a0
;  ymm1    b3 b2 b1 b0             ymm1    d1 c1 b1 a1
;  ymm2    c3 c2 c1 c0             ymm2    d2 c2 b2 a2
;  ymm3    d3 d2 d1 d0             ymm3    d3 c3 b3 a3
;

_Mat4x4TransposeF64 macro
        vunpcklpd ymm4,ymm0,ymm1            ;ymm4 = b2 a2 b0 a0
        vunpckhpd ymm5,ymm0,ymm1            ;ymm5 = b3 a3 b1 a1
        vunpcklpd ymm6,ymm2,ymm3            ;ymm6 = d2 c2 d0 c0
        vunpckhpd ymm7,ymm2,ymm3            ;ymm7 = d3 c3 d1 c1

        vperm2f128 ymm0,ymm4,ymm6,20h       ;ymm0 = d0 c0 b0 a0
        vperm2f128 ymm1,ymm5,ymm7,20h       ;ymm1 = d1 c1 b1 a1
        vperm2f128 ymm2,ymm4,ymm6,31h       ;ymm2 = d2 c2 b2 a2
        vperm2f128 ymm3,ymm5,ymm7,31h       ;ymm3 = d3 c3 b3 a3
        endm

; extern "C" void AvxMat4x4TransposeF64_(double* m_des, const double* m_src1)

        .code
AvxMat4x4TransposeF64_ proc frame
        _CreateFrame MT_,0,32
        _SaveXmmRegs xmm6,xmm7
        _EndProlog

; Transpose matrix m_src1
        vmovaps ymm0,[rdx]                  ;ymm0 = m_src1.row_0
        vmovaps ymm1,[rdx+32]               ;ymm1 = m_src2.row_1
        vmovaps ymm2,[rdx+64]               ;ymm2 = m_src3.row_2
        vmovaps ymm3,[rdx+96]               ;ymm3 = m_src4.row_3

        _Mat4x4TransposeF64

        vmovaps [rcx],ymm0                  ;save m_des.row_0
        vmovaps [rcx+32],ymm1               ;save m_des.row_1
        vmovaps [rcx+64],ymm2               ;save m_des.row_2
        vmovaps [rcx+96],ymm3               ;save m_des.row_3

        vzeroupper
Done:   _RestoreXmmRegs xmm6,xmm7
        _DeleteFrame
        ret
AvxMat4x4TransposeF64_ endp

; _Mat4x4MulCalcRowF64 macro
;
; Description:  This macro computes one row of a 4x4 matrix multiplication.
;
; Registers:    ymm0 = m_src2.row0
;               ymm1 = m_src2.row1
;               ymm2 = m_src2.row2
;               ymm3 = m_src2.row3
;               rcx = m_des ptr
;               rdx = m_src1 ptr
;               ymm4 - ymm4 = scratch registers

_Mat4x4MulCalcRowF64 macro disp
        vbroadcastsd ymm4,real8 ptr [rdx+disp]      ;broadcast m_src1[i][0]
        vbroadcastsd ymm5,real8 ptr [rdx+disp+8]    ;broadcast m_src1[i][1]
        vbroadcastsd ymm6,real8 ptr [rdx+disp+16]   ;broadcast m_src1[i][2]
        vbroadcastsd ymm7,real8 ptr [rdx+disp+24]   ;broadcast m_src1[i][3]

        vmulpd ymm4,ymm4,ymm0                       ;m_src1[i][0] * m_src2.row_0
        vmulpd ymm5,ymm5,ymm1                       ;m_src1[i][1] * m_src2.row_1
        vmulpd ymm6,ymm6,ymm2                       ;m_src1[i][2] * m_src2.row_2 
        vmulpd ymm7,ymm7,ymm3                       ;m_src1[i][3] * m_src2.row_3

        vaddpd ymm4,ymm4,ymm5                       ;calc m_des.row_i
        vaddpd ymm6,ymm6,ymm7
        vaddpd ymm4,ymm4,ymm6

        vmovapd [rcx+disp],ymm4                     ;save m_des.row_i
        endm

; extern "C" void AvxMat4x4MulF64_(double* m_des, const double* m_src1, const double* m_src2)

AvxMat4x4MulF64_ proc frame
        _CreateFrame MM_,0,32
        _SaveXmmRegs xmm6,xmm7
        _EndProlog

; Load m_src2 into YMM3:YMM0
        vmovapd ymm0,[r8]                   ;ymm0 = m_src2.row_0
        vmovapd ymm1,[r8+32]                ;ymm1 = m_src2.row_1
        vmovapd ymm2,[r8+64]                ;ymm2 = m_src2.row_2
        vmovapd ymm3,[r8+96]                ;ymm3 = m_src2.row_3

; Compute matrix product
        _Mat4x4MulCalcRowF64 0              ;calculate m_des.row_0
        _Mat4x4MulCalcRowF64 32             ;calculate m_des.row_1
        _Mat4x4MulCalcRowF64 64             ;calculate m_des.row_2
        _Mat4x4MulCalcRowF64 96             ;calculate m_des.row_3

        vzeroupper
Done:   _RestoreXmmRegs xmm6,xmm7
        _DeleteFrame
        ret
AvxMat4x4MulF64_ endp
        end
