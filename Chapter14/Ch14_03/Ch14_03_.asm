;-------------------------------------------------
;               Ch14_03.asm
;-------------------------------------------------

        include <cmpequ.asmh>
        extern c_NumPixelsMax:qword

; Macro CmpPixels

_CmpPixels macro CmpOp
        align 16
@@:     vmovdqa64 zmm0,zmmword ptr [rdx+rax]    ;load next block of 64 pixels
        vpcmpub k1,zmm0,zmm4,CmpOp              ;perform compare operation
        vmovdqu8 zmm1{k1}{z},zmm5               ;set mask pixels to 0 or 255 using opmask
        vmovdqa64 zmmword ptr [rcx+rax],zmm1    ;save mask pixels

        add rax,64                              ;update offset
        sub r8,64
        jnz @B                                  ;repeat until done
        mov eax,1                               ;set success return code
        vzeroupper
        ret
        endm

; extern "C" bool Avx512ComparePixels_(uint8_t* des, const uint8_t* src,
;   size_t num_pixels, CmpOp cmp_op, uint8_t cmp_val);

        .code
Avx512ComparePixels_ proc

; Make sure num_pixels is valid and pixel buffers are properly aligned
        xor eax,eax                         ;set error code (also array offset)

        or r8,r8
        jz Done                             ;jump if num_pixels is zero
        cmp r8,[c_NumPixelsMax]
        ja Done                             ;jump if num_pixels too big
        test r8,3fh
        jnz Done                            ;jump if num_pixels % 64 != 0

        test rcx,3fh
        jnz Done                            ;jump if des not aligned
        test rdx,3fh
        jnz Done                            ;jump if src not aligned

; Perform required initializations
        vpbroadcastb zmm4,byte ptr [rsp+40] ;zmm4 = packed cmp_val
        mov r10d,255
        vpbroadcastb zmm5,r10d              ;zmm5 = packed 255

; Perform specified compare operation
        cmp r9d,0
        jne LB_NE
        _CmpPixels CMP_EQ                   ;CmpOp::EQ

LB_NE:  cmp r9d,1
        jne LB_LT
        _CmpPixels CMP_NEQ                  ;CmpOp::NE

LB_LT:  cmp r9d,2
        jne LB_LE
        _CmpPixels CMP_LT                   ;CmpOp::LT

LB_LE:  cmp r9d,3
        jne LB_GT
        _CmpPixels CMP_LE                   ;CmpOp::LE

LB_GT:  cmp r9d,4
        jne LB_GE
        _CmpPixels CMP_NLE                  ;CmpOp::GT

LB_GE:  cmp r9d,5
        jne Done
        _CmpPixels CMP_NLT                  ;CmpOp::GE

Done:   vzeroupper
        ret
Avx512ComparePixels_ endp
        end
