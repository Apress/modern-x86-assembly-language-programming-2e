;-------------------------------------------------
;               Ch10_03.asm
;-------------------------------------------------

; extern "C" void Avx2ZeroExtU8_U16_(YmmVal*a, YmmVal b[2]);

        .code
Avx2ZeroExtU8_U16_ proc
        vpmovzxbw ymm0,xmmword ptr [rcx]        ;zero extend a[0] - a[15]
        vpmovzxbw ymm1,xmmword ptr [rcx+16]     ;zero extend a[16] - a[31]

        vmovdqa ymmword ptr [rdx],ymm0          ;save results
        vmovdqa ymmword ptr [rdx+32],ymm1

        vzeroupper
        ret
Avx2ZeroExtU8_U16_ endp

; extern "C" void Avx2ZeroExtU8_U32_(YmmVal*a, YmmVal b[4]);

Avx2ZeroExtU8_U32_ proc
        vpmovzxbd ymm0,qword ptr [rcx]          ;zero extend a[0] - a[7]
        vpmovzxbd ymm1,qword ptr [rcx+8]        ;zero extend a[8] - a[15]
        vpmovzxbd ymm2,qword ptr [rcx+16]       ;zero extend a[16] - a[23]
        vpmovzxbd ymm3,qword ptr [rcx+24]       ;zero extend a[24] - a[31]

        vmovdqa ymmword ptr [rdx],ymm0          ;save results
        vmovdqa ymmword ptr [rdx+32],ymm1
        vmovdqa ymmword ptr [rdx+64],ymm2
        vmovdqa ymmword ptr [rdx+96],ymm3

        vzeroupper
        ret
Avx2ZeroExtU8_U32_ endp

; extern "C" void Avx2SignExtI16_I32_(YmmVal*a, YmmVal b[2])

Avx2SignExtI16_I32_ proc
        vpmovsxwd ymm0,xmmword ptr [rcx]        ;sign extend a[0] - a[7]
        vpmovsxwd ymm1,xmmword ptr [rcx+16]     ;sign extend a[8] - a[15]

        vmovdqa ymmword ptr [rdx],ymm0          ;save results
        vmovdqa ymmword ptr [rdx+32],ymm1

        vzeroupper
        ret
Avx2SignExtI16_I32_ endp

; extern "C" void Avx2SignExtI16_I64_(YmmVal*a, YmmVal b[4])

Avx2SignExtI16_I64_ proc
        vpmovsxwq ymm0,qword ptr [rcx]          ;sign extend a[0] - a[3]
        vpmovsxwq ymm1,qword ptr [rcx+8]        ;sign extend a[4] - a[7]
        vpmovsxwq ymm2,qword ptr [rcx+16]       ;sign extend a[8] - a[11]
        vpmovsxwq ymm3,qword ptr [rcx+24]       ;sign extend a[12] - a[15]

        vmovdqa ymmword ptr [rdx],ymm0          ;save results
        vmovdqa ymmword ptr [rdx+32],ymm1
        vmovdqa ymmword ptr [rdx+64],ymm2
        vmovdqa ymmword ptr [rdx+96],ymm3

        vzeroupper
        ret
Avx2SignExtI16_I64_ endp
        end
