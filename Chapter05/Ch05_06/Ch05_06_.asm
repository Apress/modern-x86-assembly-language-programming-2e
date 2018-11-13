;-------------------------------------------------
;               Ch05_06.asm
;-------------------------------------------------

MxcsrRcMask equ 9fffh                       ;bit pattern for MXCSR.RC
MxcsrRcShift equ 13                         ;shift count for MXCSR.RC

; extern "C" RoundingMode GetMxcsrRoundingMode_(void);
;
; Description:  The following function obtains the current
;               floating-point rounding mode from MXCSR.RC.
;
; Returns:      Current MXCSR.RC rounding mode.

        .code
GetMxcsrRoundingMode_ proc
        vstmxcsr dword ptr [rsp+8]          ;save mxcsr register
        mov eax,[rsp+8]
        shr eax,MxcsrRcShift                ;eax[1:0] = MXCSR.RC bits
        and eax,3                           ;masked out unwanted bits
        ret
GetMxcsrRoundingMode_ endp

;extern "C" void SetMxcsrRoundingMode_(RoundingMode rm);
;
; Description:  The following function updates the rounding mode
;               value in MXCSR.RC.

SetMxcsrRoundingMode_ proc
        and ecx,3                           ;masked out unwanted bits
        shl ecx,MxcsrRcShift                ;ecx[14:13] = rm

        vstmxcsr dword ptr [rsp+8]          ;save current MXCSR
        mov eax,[rsp+8]
        and eax,MxcsrRcMask                 ;masked out old MXCSR.RC bits
        or eax,ecx                          ;insert new MXCSR.RC bits
        mov [rsp+8],eax
        vldmxcsr dword ptr [rsp+8]          ;load updated MXCSR
        ret
SetMxcsrRoundingMode_ endp

; extern "C" bool ConvertScalar_(Uval* des, const Uval* src, CvtOp cvt_op)
;
; Note:         This function requires linker option /LARGEADDRESSAWARE:NO
;               to be explicitly set.

ConvertScalar_ proc

; Make sure cvt_op is valid, then jump to target conversion code
        mov eax,r8d                         ;eax = CvtOp
        cmp eax,CvtOpTableCount
        jae BadCvtOp                        ;jump if cvt_op is invalid
        jmp [CvtOpTable+rax*8]              ;jump to specified conversion

; Conversions between int32_t and float/double

I32_F32:
        mov eax,[rdx]                       ;load integer value
        vcvtsi2ss xmm0,xmm0,eax             ;convert to float
        vmovss real4 ptr [rcx],xmm0         ;save result
        mov eax,1
        ret

F32_I32:
        vmovss xmm0,real4 ptr [rdx]         ;load float value
        vcvtss2si eax,xmm0                  ;convert to integer
        mov [rcx],eax                       ;save result
        mov eax,1
        ret

I32_F64:
        mov eax,[rdx]                       ;load integer value
        vcvtsi2sd xmm0,xmm0,eax             ;convert to double
        vmovsd real8 ptr [rcx],xmm0         ;save result
        mov eax,1
        ret

F64_I32:
        vmovsd xmm0,real8 ptr [rdx]         ;load double value
        vcvtsd2si eax,xmm0                  ;convert to integer
        mov [rcx],eax                       ;save result
        mov eax,1
        ret

; Conversions between int64_t and float/double

I64_F32:
        mov rax,[rdx]                       ;load integer value
        vcvtsi2ss xmm0,xmm0,rax             ;convert to float
        vmovss real4 ptr [rcx],xmm0         ;save result
        mov eax,1
        ret

F32_I64:
        vmovss xmm0,real4 ptr [rdx]         ;load float value
        vcvtss2si rax,xmm0                  ;convert to integer
        mov [rcx],rax                       ;save result
        mov eax,1
        ret

I64_F64:
        mov rax,[rdx]                       ;load integer value
        vcvtsi2sd xmm0,xmm0,rax             ;convert to double
        vmovsd real8 ptr [rcx],xmm0         ;save result
        mov eax,1
        ret

F64_I64:
        vmovsd xmm0,real8 ptr [rdx]         ;load double value
        vcvtsd2si rax,xmm0                  ;convert to integer
        mov [rcx],rax                       ;save result
        mov eax,1
        ret

; Conversions between float and double

F32_F64:
        vmovss xmm0,real4 ptr [rdx]         ;load float value
        vcvtss2sd xmm1,xmm1,xmm0            ;convert to double
        vmovsd real8 ptr [rcx],xmm1         ;save result
        mov eax,1
        ret

F64_F32:
        vmovsd xmm0,real8 ptr [rdx]         ;load double value
        vcvtsd2ss xmm1,xmm1,xmm0            ;convert to float
        vmovss real4 ptr [rcx],xmm1         ;save result
        mov eax,1
        ret

BadCvtOp:
        xor eax,eax                         ;set error return code
        ret

; The order of values in following table must match the enum CvtOp
; that's defined in the .cpp file.

        align 8
CvtOpTable equ $
        qword I32_F32, F32_I32
        qword I32_F64, F64_I32
        qword I64_F32, F32_I64
        qword I64_F64, F64_I64
        qword F32_F64, F64_F32
CvtOpTableCount equ ($ - CvtOpTable) / size qword

ConvertScalar_ endp
        end
