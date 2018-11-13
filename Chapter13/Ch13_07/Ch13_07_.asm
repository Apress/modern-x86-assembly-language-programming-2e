;-------------------------------------------------
;               Ch13_07.asm
;-------------------------------------------------

        include <MacrosX86-64-AVX.asmh>

; Indices for gather and scatter instructions
ConstVals   segment readonly align(64) 'const'
GS_X        qword 0, 3, 6,  9, 12, 15, 18, 21
GS_Y        qword 1, 4, 7, 10, 13, 16, 19, 22
GS_Z        qword 2, 5, 8, 11, 14, 17, 20, 23
ConstVals   ends

; extern "C" bool Avx512VcpAos_(Vector* c, const Vector* a, const Vector* b, size_t num_vectors);

        .code
Avx512VcpAos_ proc

; Make sure num_vec is valid
        xor eax,eax                         ;set error code (also i = 0)
        test r9,r9
        jz Done                             ;jump if num_vec is zero
        test r9,07h
        jnz Done                            ;jump if num_vec % 8 != 0 is true

; Load indices for gather and scatter operations
        vmovdqa64 zmm29,zmmword ptr [GS_X]  ;zmm29 = X component indices
        vmovdqa64 zmm30,zmmword ptr [GS_Y]  ;zmm30 = Y component indices
        vmovdqa64 zmm31,zmmword ptr [GS_Z]  ;zmm31 = Z component indices

; Load next 8 vectors
        align 16
@@:     kxnorb k1,k1,k1
        vgatherqpd zmm0{k1},[rdx+zmm29*8]       ;zmm0 = A.X values

        kxnorb k2,k2,k2
        vgatherqpd zmm1{k2},[rdx+zmm30*8]       ;zmm1 = A.Y values

        kxnorb k3,k3,k3
        vgatherqpd zmm2{k3},[rdx+zmm31*8]       ;zmm2 = A.Z values

        kxnorb k4,k4,k4
        vgatherqpd zmm3{k4},[r8+zmm29*8]        ;zmm3 = B.X values

        kxnorb k5,k5,k5
        vgatherqpd zmm4{k5},[r8+zmm30*8]        ;zmm4 = B.Y values

        kxnorb k6,k6,k6
        vgatherqpd zmm5{k6},[r8+zmm31*8]        ;zmm5 = B.Z values

; Calculate 8 vector cross products
        vmulpd zmm16,zmm1,zmm5
        vmulpd zmm17,zmm2,zmm4
        vsubpd zmm18,zmm16,zmm17                ;c.X = a.Y * b.Z - a.Z * b.Y

        vmulpd zmm19,zmm2,zmm3
        vmulpd zmm20,zmm0,zmm5
        vsubpd zmm21,zmm19,zmm20                ;c.Y = a.Z * b.X - a.X * b.Z

        vmulpd zmm22,zmm0,zmm4
        vmulpd zmm23,zmm1,zmm3
        vsubpd zmm24,zmm22,zmm23                ;c.Z = a.X * b.Y - a.Y * b.X

; Save calculated cross products
        kxnorb k4,k4,k4
        vscatterqpd [rcx+zmm29*8]{k4},zmm18     ;save C.X components

        kxnorb k5,k5,k5
        vscatterqpd [rcx+zmm30*8]{k5},zmm21     ;save C.Y components

        kxnorb k6,k6,k6
        vscatterqpd [rcx+zmm31*8]{k6},zmm24     ;save C.Z components

; Update pointers and counters
        add rcx,192                             ;c += 8
        add rdx,192                             ;a += 8
        add r8,192                              ;b += 8
        add rax,8                               ;i += 8
        cmp rax,r9
        jb @B

        mov eax,1                               ;set success return code

Done:   vzeroupper
        ret
Avx512VcpAos_ endp

; extern "C" bool Avx512VcpSoa_(VectorSoA* c, const VectorSoA* a, const VectorSoA* b, size_t num_vectors);

Avx512VcpSoa_ proc frame
        _CreateFrame CP2_,0,0,rbx,rsi,rdi,r12,r13,r14,r15
        _EndProlog

; Make sure num_vec is valid
        xor eax,eax
        test r9,r9
        jz Done                             ;jump if num_vec is zero
        test r9,07h
        jnz Done                            ;jump if num_vec % 8 != 0 is true

; Load vector array pointers and check for proper alignment
        mov r10,[rdx]                       ;r10 = a.X
        or rax,r10
        mov r11,[rdx+8]                     ;r11 = a.Y
        or rax,r11
        mov r12,[rdx+16]                    ;r12 = a.Z
        or rax,r12

        mov r13,[r8]                        ;r13 = b.X
        or rax,r13
        mov r14,[r8+8]                      ;r14 = b.Y
        or rax,r14
        mov r15,[r8+16]                     ;r15 = b.Z
        or rax,r15

        mov rbx,[rcx]                       ;rbx = c.X
        or rax,rbx
        mov rsi,[rcx+8]                     ;rsi = c.Y
        or rax,rsi
        mov rdi,[rcx+16]                    ;rdi = c.Z
        or rax,rdi

        and rax,3fh                         ;misaligned component array?
        mov eax,0                           ;error return code (also i = 0)
        jnz Done

; Load next block (8 vectors) from a and b
        align 16
@@:     vmovapd zmm0,zmmword ptr [r10+rax*8]    ;zmm0 = a.X values
        vmovapd zmm1,zmmword ptr [r11+rax*8]    ;zmm1 = a.Y values
        vmovapd zmm2,zmmword ptr [r12+rax*8]    ;zmm2 = a.Z values
        vmovapd zmm3,zmmword ptr [r13+rax*8]    ;zmm3 = b.X values
        vmovapd zmm4,zmmword ptr [r14+rax*8]    ;zmm4 = b.Y values
        vmovapd zmm5,zmmword ptr [r15+rax*8]    ;zmm5 = b.Z values

; Calculate cross products
        vmulpd zmm16,zmm1,zmm5
        vmulpd zmm17,zmm2,zmm4
        vsubpd zmm18,zmm16,zmm17                ;c.X = a.Y * b.Z - a.Z * b.Y

        vmulpd zmm19,zmm2,zmm3
        vmulpd zmm20,zmm0,zmm5
        vsubpd zmm21,zmm19,zmm20                ;c.Y = a.Z * b.X - a.X * b.Z

        vmulpd zmm22,zmm0,zmm4
        vmulpd zmm23,zmm1,zmm3
        vsubpd zmm24,zmm22,zmm23                ;c.Z = a.X * b.Y - a.Y * b.X

; Save calculated cross products
        vmovapd zmmword ptr [rbx+rax*8],zmm18   ;save C.X values
        vmovapd zmmword ptr [rsi+rax*8],zmm21   ;save C.Y values
        vmovapd zmmword ptr [rdi+rax*8],zmm24   ;save C.Z values

        add rax,8                               ;i += 8
        cmp rax,r9
        jb @B                                   ;repeat until done

Done:   vzeroupper
        _DeleteFrame rbx,rsi,rdi,r12,r13,r14,r15
        ret
Avx512VcpSoa_ endp
        end
