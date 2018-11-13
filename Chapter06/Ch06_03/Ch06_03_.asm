;-------------------------------------------------
;               Ch06_03.asm
;-------------------------------------------------

; extern "C" bool AvxPackedConvertFP_(const XmmVal& a, XmmVal& b, CvtOp cvt_op);
;
; Note:         This function requires linker option /LARGEADDRESSAWARE:NO
;               to be explicitly set.

        .code
AvxPackedConvertFP_ proc

; Make sure cvt_op is valid
        mov r9d,r8d                         ;r9 = cvt_op (zero extended)
        cmp r9,CvtOpTableCount              ;is cvt_op valid?
        jae InvalidCvtOp                    ;jmp if cvt_op is invalid

        mov eax,1                           ;set valid cvt_op return code
        jmp [CvtOpTable+r9*8]               ;jump to specified conversion

; Convert packed signed doubleword integers to packed SPFP values
I32_F32:
        vmovdqa xmm0,xmmword ptr [rcx]
        vcvtdq2ps xmm1,xmm0
        vmovaps xmmword ptr [rdx],xmm1
        ret

; Convert packed SPFP values to packed signed doubleword integers
F32_I32:
        vmovaps xmm0,xmmword ptr [rcx]
        vcvtps2dq xmm1,xmm0
        vmovdqa xmmword ptr [rdx],xmm1
        ret

; Convert packed signed doubleword integers to packed DPFP values
I32_F64:
        vmovdqa xmm0,xmmword ptr [rcx]
        vcvtdq2pd xmm1,xmm0
        vmovapd xmmword ptr [rdx],xmm1
        ret

; Convert packed DPFP values to packed signed doubleword integers
F64_I32:
        vmovapd xmm0,xmmword ptr [rcx]
        vcvtpd2dq xmm1,xmm0
        vmovdqa xmmword ptr [rdx],xmm1
        ret

; Convert packed SPFP to packed DPFP
F32_F64:
        vmovaps xmm0,xmmword ptr [rcx]
        vcvtps2pd xmm1,xmm0
        vmovapd xmmword ptr [rdx],xmm1
        ret

; Convert packed DPFP to packed SPFP
F64_F32:
        vmovapd xmm0,xmmword ptr [rcx]
        vcvtpd2ps xmm1,xmm0
        vmovaps xmmword ptr [rdx],xmm1
        ret

InvalidCvtOp:
        xor eax,eax                         ;set invalid cvt_op return code
        ret

; The order of values in the following table must match the enum CvtOp
; that's defined in Ch06_03.cpp.

            align 8
CvtOpTable  qword I32_F32, F32_I32
            qword I32_F64, F64_I32
            qword F32_F64, F64_F32
CvtOpTableCount equ ($ - CvtOpTable) / size qword

AvxPackedConvertFP_ endp
        end
