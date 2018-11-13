;-------------------------------------------------
;               Ch10_02.asm
;-------------------------------------------------

; extern "C" YmmVal2 Avx2UnpackU32_U64_(const YmmVal& a, const YmmVal& b);

        .code
Avx2UnpackU32_U64_ proc

; Load argument values
        vmovdqa ymm0,ymmword ptr [rdx]      ;ymm0 = a
        vmovdqa ymm1,ymmword ptr [r8]       ;ymm1 = b

; Perform dword to qword unpacks
        vpunpckldq ymm2,ymm0,ymm1           ;unpack low doublewords
        vpunpckhdq ymm3,ymm0,ymm1           ;unpack high doublewords

; Save result to YmmVal2 buffer
        vmovdqa ymmword ptr [rcx],ymm2      ;save low result
        vmovdqa ymmword ptr [rcx+32],ymm3   ;save high result

        mov rax,rcx                         ;rax = ptr to YmmVal2

        vzeroupper
        ret
Avx2UnpackU32_U64_ endp

; extern "C" void Avx2PackI32_I16_(const YmmVal& a, const YmmVal& b, YmmVal* c);

Avx2PackI32_I16_ proc

; Load argument values
        vmovdqa ymm0,ymmword ptr [rcx]      ;ymm0 = a
        vmovdqa ymm1,ymmword ptr [rdx]      ;ymm1 = b

; Perform pack dword to word with signed saturation
        vpackssdw ymm2,ymm0,ymm1            ;ymm2 = packed words
        vmovdqa ymmword ptr [r8],ymm2       ;save result

        vzeroupper
        ret
Avx2PackI32_I16_ endp

Foo1_ proc
        ret
Foo1_ endp
        end
