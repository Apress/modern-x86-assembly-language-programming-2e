;-------------------------------------------------
;               CpuidInfo_.asm
;-------------------------------------------------

; The following structures must agree with the CpuidRegs structure
; that's defined in CpuidInfo.h

CpuidRegs   struct
RegEAX      dword ?
RegEBX      dword ?
RegECX      dword ?
RegEDX      dword ?
CpuidRegs   ends

; extern "C" uint32_t Cpuid_(uint32_t r_eax, uint32_t r_ecx, CpuidRegs* r_out);
;
; Returns:      eax == 0     Unsupported CPUID leaf
;               eax != 0     Supported CPUID leaf
;
;               Note: the return code is valid only if r_eax <= MaxEAX.

        .code
Cpuid_  proc frame
        push rbx
        .pushreg rbx
        .endprolog

; Load eax and ecx
        mov eax,ecx
        mov ecx,edx

; Get cpuid info & save results
        cpuid
        mov dword ptr [r8+CpuidRegs.RegEAX],eax
        mov dword ptr [r8+CpuidRegs.RegEBX],ebx
        mov dword ptr [r8+CpuidRegs.RegECX],ecx
        mov dword ptr [r8+CpuidRegs.RegEDX],edx

; Test for unsupported CPUID leaf
        or eax,ebx
        or ecx,edx
        or eax,ecx                          ;eax = return code

        pop rbx
        ret
Cpuid_  endp

; extern "C" void Xgetbv_(uint32_t r_ecx, uint32_t* r_eax, uint32_t* r_edx);

Xgetbv_ proc
        mov r9,rdx                          ;r9 = r_eax ptr
        xgetbv

        mov dword ptr [r9],eax              ;save low word result
        mov dword ptr [r8],edx              ;save high word result
        ret
Xgetbv_ endp
        end

