;-------------------------------------------------
;               Ch16_04_.asm
;-------------------------------------------------

        include <MacrosX86-64-AVX.asmh>

CalcInfo struct
    X1 qword ?
    X2 qword ?
    Y1 qword ?
    Y2 qword ?
    Z1 qword ?
    Z2 qword ?
    Result qword ?
    Index0 qword ?
    Index1 qword ?
    Status dword ?
CalcInfo ends

        .const
r8_1p0  real8 1.0

; extern "C" void CalcResult_(CalcInfo* ci)

        .code
CalcResult_ proc frame
        _CreateFrame CR,0,16,r12,r13,r14,r15
        _SaveXmmRegs xmm6
        _EndProlog

        mov dword ptr [rcx+CalcInfo.Status],0

; Make sure num_elements is valid
        mov rax,[rcx+CalcInfo.Index0]       ;rax = start index
        mov rdx,[rcx+CalcInfo.Index1]       ;rdx = stop index
        sub rdx,rax
        add rdx,1                           ;rdx = num_elements
        test rdx,rdx
        jz Done                             ;jump if num_elements == 0
        test rdx,7
        jnz Done                            ;jump if num_elements % 8 != 0

; Make sure all arrays are properly aligned
        mov r8d,1fh
        mov r9,[rcx+CalcInfo.Result]
        test r9,r8
        jnz Done

        mov r10,[rcx+CalcInfo.X1]
        test r10,r8
        jnz Done
        mov r11,[rcx+CalcInfo.X2]
        test r11,r8
        jnz Done

        mov r12,[rcx+CalcInfo.Y1]
        test r12,r8
        jnz Done
        mov r13,[rcx+CalcInfo.Y2]
        test r13,r8
        jnz Done

        mov r14,[rcx+CalcInfo.Z1]
        test r14,r8
        jnz Done
        mov r15,[rcx+CalcInfo.Z2]
        test r15,r8
        jnz Done

        vbroadcastsd ymm6,real8 ptr [r8_1p0]        ;ymm6 = packed 1.0 (DPFP)

; Perform simulated calculation
        align 16
LP1:    vmovapd ymm0,ymmword ptr [r10+rax*8]
        vmovapd ymm1,ymmword ptr [r12+rax*8]
        vmovapd ymm2,ymmword ptr [r14+rax*8]
        vsubpd ymm0,ymm0,ymmword ptr [r11+rax*8]
        vsubpd ymm1,ymm1,ymmword ptr [r13+rax*8]
        vsubpd ymm2,ymm2,ymmword ptr [r15+rax*8]
        vmulpd ymm3,ymm0,ymm0
        vmulpd ymm4,ymm1,ymm1
        vmulpd ymm5,ymm2,ymm2
        vaddpd ymm0,ymm3,ymm4
        vaddpd ymm1,ymm0,ymm5
        vsqrtpd ymm2,ymm1
        vdivpd ymm3,ymm6,ymm2
        vsqrtpd ymm4,ymm3
        vmovntpd ymmword ptr [r9+rax*8],ymm4

        add rax,4

        vmovapd ymm0,ymmword ptr [r10+rax*8]
        vmovapd ymm1,ymmword ptr [r12+rax*8]
        vmovapd ymm2,ymmword ptr [r14+rax*8]
        vsubpd ymm0,ymm0,ymmword ptr [r11+rax*8]
        vsubpd ymm1,ymm1,ymmword ptr [r13+rax*8]
        vsubpd ymm2,ymm2,ymmword ptr [r15+rax*8]
        vmulpd ymm3,ymm0,ymm0
        vmulpd ymm4,ymm1,ymm1
        vmulpd ymm5,ymm2,ymm2
        vaddpd ymm0,ymm3,ymm4
        vaddpd ymm1,ymm0,ymm5
        vsqrtpd ymm2,ymm1
        vdivpd ymm3,ymm6,ymm2
        vsqrtpd ymm4,ymm3
        vmovntpd ymmword ptr [r9+rax*8],ymm4

        add rax,4
        sub rdx,8
        jnz LP1

        mov dword ptr [rcx+CalcInfo.Status],1

Done:   vzeroupper
        _RestoreXmmRegs xmm6
        _DeleteFrame r12,r13,r14,r15
        ret
CalcResult_ endp
        end
