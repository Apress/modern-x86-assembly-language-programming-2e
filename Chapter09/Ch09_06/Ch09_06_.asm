;-------------------------------------------------
;               Ch09_06.asm
;-------------------------------------------------

        include <MacrosX86-64-AVX.asmh>

; Custom segment for constants
ConstVals segment readonly align(32) 'const'
Mat4x4I real8 1.0, 0.0, 0.0, 0.0
        real8 0.0, 1.0, 0.0, 0.0
        real8 0.0, 0.0, 1.0, 0.0
        real8 0.0, 0.0, 0.0, 1.0

r8_SignBitMask  qword 4 dup (8000000000000000h)
r8_AbsMask      qword 4 dup (7fffffffffffffffh)

r8_1p0          real8 1.0
r8_N1p0         real8 -1.0
r8_N0p5         real8 -0.5
r8_N0p3333      real8 -0.33333333333333
r8_N0p25        real8 -0.25
ConstVals ends
        .code

; _Mat4x4TraceF64 macro
;
; Description:  This macro contains instructions that compute the trace
;               of the 4x4 double-precision floating-point matrix in ymm3:ymm0.

_Max4x4TraceF64 macro
        vblendpd ymm0,ymm0,ymm1,00000010b       ;ymm0[127:0] = row 1,0 diag vals
        vblendpd ymm1,ymm2,ymm3,00001000b       ;ymm1[255:128] = row 3,2 diag vals
        vperm2f128 ymm2,ymm1,ymm1,00000001b     ;ymm2[127:0] = row 3,2 diag vals
        vaddpd ymm3,ymm0,ymm2
        vhaddpd ymm0,ymm3,ymm3                  ;xmm0[63:0] = trace
        endm

; extern "C" double Avx2Mat4x4TraceF64_(const double* m_src1)
;
; Description:  The following function computes the trace of a
;               4x4 double-precision floating-point array.

Avx2Mat4x4TraceF64_ proc
            vmovapd ymm0,[rcx]              ;ymm0 = m_src1.row_0
            vmovapd ymm1,[rcx+32]           ;ymm1 = m_src1.row_1
            vmovapd ymm2,[rcx+64]           ;ymm2 = m_src1.row_2
            vmovapd ymm3,[rcx+96]           ;ymm3 = m_src1.row_3

            _Max4x4TraceF64                 ;xmm0[63:0] = m_src1.trace()
            vzeroupper
            ret
Avx2Mat4x4TraceF64_ endp

; _Mat4x4MulCalcRowF64 macro
;
; Description:  This macro is used to compute one row of a 4x4 matrix
;               multiply.
;
; Registers:    ymm0 = m_src2.row0
;               ymm1 = m_src2.row1
;               ymm2 = m_src2.row2
;               ymm3 = m_src2.row3
;               ymm4 - ymm7 = scratch registers

_Mat4x4MulCalcRowF64 macro dreg,sreg,disp
        vbroadcastsd ymm4,real8 ptr [sreg+disp]     ;broadcast m_src1[i][0]
        vbroadcastsd ymm5,real8 ptr [sreg+disp+8]   ;broadcast m_src1[i][1]
        vbroadcastsd ymm6,real8 ptr [sreg+disp+16]  ;broadcast m_src1[i][2]
        vbroadcastsd ymm7,real8 ptr [sreg+disp+24]  ;broadcast m_src1[i][3]

        vmulpd ymm4,ymm4,ymm0                       ;m_src1[i][0] * m_src2.row_0
        vmulpd ymm5,ymm5,ymm1                       ;m_src1[i][1] * m_src2.row_1
        vmulpd ymm6,ymm6,ymm2                       ;m_src1[i][2] * m_src2.row_2 
        vmulpd ymm7,ymm7,ymm3                       ;m_src1[i][3] * m_src2.row_3

        vaddpd ymm4,ymm4,ymm5                       ;calc m_des.row_i
        vaddpd ymm6,ymm6,ymm7
        vaddpd ymm4,ymm4,ymm6
        vmovapd[dreg+disp],ymm4                     ;save m_des.row_i
        endm

; extern "C" void Avx2Mat4x4MulF64_(double* m_des, const double* m_src1, const double* m_src2)

Avx2Mat4x4MulF64_ proc frame
        _CreateFrame MM_,0,32
        _SaveXmmRegs xmm6,xmm7
        _EndProlog

        vmovapd ymm0,[r8]                   ;ymm0 = m_src2.row_0
        vmovapd ymm1,[r8+32]                ;ymm1 = m_src2.row_1
        vmovapd ymm2,[r8+64]                ;ymm2 = m_src2.row_2
        vmovapd ymm3,[r8+96]                ;ymm3 = m_src2.row_3

        _Mat4x4MulCalcRowF64 rcx,rdx,0      ;calculate m_des.row_0
        _Mat4x4MulCalcRowF64 rcx,rdx,32     ;calculate m_des.row_1
        _Mat4x4MulCalcRowF64 rcx,rdx,64     ;calculate m_des.row_2
        _Mat4x4MulCalcRowF64 rcx,rdx,96     ;calculate m_des.row_3

        vzeroupper
        _RestoreXmmRegs xmm6,xmm7
        _DeleteFrame
        ret
Avx2Mat4x4MulF64_ endp

; extern "C" bool Avx2Mat4x4InvF64_(double* m_inv, const double* m, double epsilon, bool* is_singular);

; Offsets of intermediate matrices on stack relative to rsp
OffsetM2 equ 32
OffsetM3 equ 160
OffsetM4 equ 288

Avx2Mat4x4InvF64_ proc frame
        _CreateFrame MI_,0,160
        _SaveXmmRegs xmm6,xmm7,xmm8,xmm9,xmm10,xmm11,xmm12,xmm13,xmm14,xmm15
        _EndProlog

; Save args to home area for later use
        mov qword ptr [rbp+MI_OffsetHomeRCX],rcx        ;save m_inv ptr
        mov qword ptr [rbp+MI_OffsetHomeRDX],rdx        ;save m ptr
        vmovsd real8 ptr [rbp+MI_OffsetHomeR8],xmm2     ;save epsilon
        mov qword ptr [rbp+MI_OffsetHomeR9],r9          ;save is_singular ptr

; Allocate 384 bytes of stack space for temp matrices + 32 bytes for function calls
        and rsp,0ffffffe0h                  ;align rsp to 32-byte boundary
        sub rsp,416                         ;alloc stack space

; Calculate m2
        lea rcx,[rsp+OffsetM2]              ;rcx = m2 ptr
        mov r8,rdx                          ;rdx, r8 = m ptr
        call Avx2Mat4x4MulF64_              ;calculate and save m2

; Calculate m3
        lea rcx,[rsp+OffsetM3]              ;rcx = m3 ptr
        lea rdx,[rsp+OffsetM2]              ;rdx = m2 ptr
        mov r8,[rbp+MI_OffsetHomeRDX]       ;r8 = m
        call Avx2Mat4x4MulF64_              ;calculate and save m3

; Calculate m4
        lea rcx,[rsp+OffsetM4]              ;rcx = m4 ptr
        lea rdx,[rsp+OffsetM3]              ;rdx = m3 ptr
        mov r8,[rbp+MI_OffsetHomeRDX]       ;r8 = m
        call Avx2Mat4x4MulF64_              ;calculate and save m4

; Calculate trace of m, m2, m3, and m4
        mov rcx,[rbp+MI_OffsetHomeRDX]
        call Avx2Mat4x4TraceF64_
        vmovsd xmm8,xmm8,xmm0               ;xmm8 = t1

        lea rcx,[rsp+OffsetM2]
        call Avx2Mat4x4TraceF64_
        vmovsd xmm9,xmm9,xmm0               ;xmm9 = t2
        
        lea rcx,[rsp+OffsetM3]
        call Avx2Mat4x4TraceF64_
        vmovsd xmm10,xmm10,xmm0             ;xmm10 = t3

        lea rcx,[rsp+OffsetM4]
        call Avx2Mat4x4TraceF64_
        vmovsd xmm11,xmm11,xmm0             ;xmm10 = t4

; Calculate the required coefficients
; c1 = -t1;
; c2 = -1.0f / 2.0f * (c1 * t1 + t2);
; c3 = -1.0f / 3.0f * (c2 * t1 + c1 * t2 + t3);
; c4 = -1.0f / 4.0f * (c3 * t1 + c2 * t2 + c1 * t3 + t4);
;
; Registers used:
;   t1-t4 = xmm8-xmm11
;   c1-c4 = xmm12-xmm15

        vxorpd xmm12,xmm8,real8 ptr [r8_SignBitMask]    ;xmm12 = c1

        vmulsd xmm13,xmm12,xmm8         ;c1 * t1
        vaddsd xmm13,xmm13,xmm9         ;c1 * t1 + t2
        vmulsd xmm13,xmm13,[r8_N0p5]    ;c2

        vmulsd xmm14,xmm13,xmm8         ;c2 * t1
        vmulsd xmm0,xmm12,xmm9          ;c1 * t2
        vaddsd xmm14,xmm14,xmm0         ;c2 * t1 + c1 * t2
        vaddsd xmm14,xmm14,xmm10        ;c2 * t1 + c1 * t2 + t3
        vmulsd xmm14,xmm14,[r8_N0p3333] ;c3

        vmulsd xmm15,xmm14,xmm8         ;c3 * t1
        vmulsd xmm0,xmm13,xmm9          ;c2 * t2
        vmulsd xmm1,xmm12,xmm10         ;c1 * t3
        vaddsd xmm2,xmm0,xmm1           ;c2 * t2 + c1 * t3
        vaddsd xmm15,xmm15,xmm2         ;c3 * t1 + c2 * t2 + c1 * t3
        vaddsd xmm15,xmm15,xmm11        ;c3 * t1 + c2 * t2 + c1 * t3 + t4
        vmulsd xmm15,xmm15,[r8_N0p25]   ;c4

; Make sure matrix is not singular
        vandpd xmm0,xmm15,[r8_AbsMask]                  ;compute fabs(c4)
        vmovsd xmm1,real8 ptr [rbp+MI_OffsetHomeR8]
        vcomisd xmm0,real8 ptr [rbp+MI_OffsetHomeR8]    ;compare against epsilon
        setp al                                         ;set al = if unordered
        setb ah                                         ;set ah = if fabs(c4) < epsilon
        or al,ah                                        ;al = is_singular
        mov rcx,[rbp+MI_OffsetHomeR9]                   ;rax = is_singular ptr
        mov [rcx],al                                    ;save is_singular state
        jnz Error                                       ;jump if singular

; Calculate m_inv = -1.0 / c4 * (m3 + c1 * m2 + c2 * m1 + c3 * I)
        vbroadcastsd ymm14,xmm14                        ;ymm14 = packed c3
        lea rcx,[Mat4x4I]                               ;rcx = I ptr
        vmulpd ymm0,ymm14,ymmword ptr [rcx]
        vmulpd ymm1,ymm14,ymmword ptr [rcx+32]
        vmulpd ymm2,ymm14,ymmword ptr [rcx+64]
        vmulpd ymm3,ymm14,ymmword ptr [rcx+96]          ;c3 * I

        vbroadcastsd ymm13,xmm13                        ;ymm13 = packed c2
        mov rcx,[rbp+MI_OffsetHomeRDX]                  ;rcx = m ptr
        vmulpd ymm4,ymm13,ymmword ptr [rcx]
        vmulpd ymm5,ymm13,ymmword ptr [rcx+32]
        vmulpd ymm6,ymm13,ymmword ptr [rcx+64]
        vmulpd ymm7,ymm13,ymmword ptr [rcx+96]          ;c2 * m1
        vaddpd ymm0,ymm0,ymm4
        vaddpd ymm1,ymm1,ymm5
        vaddpd ymm2,ymm2,ymm6
        vaddpd ymm3,ymm3,ymm7                           ;c2 * m1 + c3 * I

        vbroadcastsd ymm12,xmm12                        ;ymm12 = packed c1
        lea rcx,[rsp+OffsetM2]                          ;rcx = m2 ptr
        vmulpd ymm4,ymm12,ymmword ptr [rcx]
        vmulpd ymm5,ymm12,ymmword ptr [rcx+32]
        vmulpd ymm6,ymm12,ymmword ptr [rcx+64]
        vmulpd ymm7,ymm12,ymmword ptr [rcx+96]          ;c1 * m2
        vaddpd ymm0,ymm0,ymm4
        vaddpd ymm1,ymm1,ymm5
        vaddpd ymm2,ymm2,ymm6
        vaddpd ymm3,ymm3,ymm7                           ;c1 * m2 + c2 * m1 + c3 * I

        lea rcx,[rsp+OffsetM3]                          ;rcx = m3 ptr
        vaddpd ymm0,ymm0,ymmword ptr [rcx]
        vaddpd ymm1,ymm1,ymmword ptr [rcx+32]
        vaddpd ymm2,ymm2,ymmword ptr [rcx+64]
        vaddpd ymm3,ymm3,ymmword ptr [rcx+96]           ;m3 + c1 * m2 + c2 * m1 + c3 * I

        vmovsd xmm4,[r8_N1p0]
        vdivsd xmm4,xmm4,xmm15              ;xmm4 = -1.0 / c4
        vbroadcastsd ymm4,xmm4
        vmulpd ymm0,ymm0,ymm4
        vmulpd ymm1,ymm1,ymm4
        vmulpd ymm2,ymm2,ymm4
        vmulpd ymm3,ymm3,ymm4               ;ymm3:ymm0 = m_inv

; Save m_inv
        mov rcx,[rbp+MI_OffsetHomeRCX]
        vmovapd ymmword ptr [rcx],ymm0
        vmovapd ymmword ptr [rcx+32],ymm1
        vmovapd ymmword ptr [rcx+64],ymm2
        vmovapd ymmword ptr [rcx+96],ymm3
        mov eax,1                           ;set success return code

Done:    vzeroupper
        _RestoreXmmRegs xmm6,xmm7,xmm8,xmm9,xmm10,xmm11,xmm12,xmm13,xmm14,xmm15
        _DeleteFrame
        ret

Error:  xor eax,eax
        jmp Done

Avx2Mat4x4InvF64_ endp
        end
