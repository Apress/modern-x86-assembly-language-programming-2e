;-------------------------------------------------
;               Ch13_09_.asm
;-------------------------------------------------

        include <MacrosX86-64-AVX.asmh>
        extern c_NumPtsMin:dword
        extern c_NumPtsMax:dword
        extern c_KernelSizeMin:dword
        extern c_KernelSizeMax:dword

; extern bool Avx512Convolve2_(float* y, const float* x, int num_pts, const float* kernel, int kernel_size)

        .code
Avx512Convolve2_ proc frame
        _CreateFrame CV2_,0,0,rbx
        _EndProlog

; Validate argument values
        xor eax,eax                         ;set error code

        mov r10d,dword ptr [rbp+CV2_OffsetStackArgs]
        test r10d,1
        jz Done                             ;kernel_size is even
        cmp r10d,[c_KernelSizeMin]
        jl Done                             ;kernel_size too small
        cmp r10d,[c_KernelSizeMax]
        jg Done                             ;kernel_size too big

        cmp r8d,[c_NumPtsMin]
        jl Done                             ;num_pts too small
        cmp r8d,[c_NumPtsMax]
        jg Done                             ;num_pts too big
        test r8d,15
        jnz Done                            ;num_pts not even multiple of 16

        test rcx,3fh
        jnz Done                            ;y is not properly aligned

; Initialize convolution loop variables
        shr r10d,1                          ;r10 = kernel_size / 2 (ks2)
        lea rdx,[rdx+r10*4]                 ;rdx = x + ks2 (first data point)
        xor ebx,ebx                         ;i = 0

; Perform convolution
LP1:    vxorps zmm0,zmm0,zmm0               ;packed sum = 0.0;
        mov r11,r10                         ;r11 = ks2
        neg r11                             ;k = -ks2

LP2:    mov rax,rbx                             ;rax = i
        sub rax,r11                             ;rax = i - k
        vmovups zmm1,zmmword ptr [rdx+rax*4]    ;load x[i - k]:x[i - k + 15]

        mov rax,r11
        add rax,r10                             ;rax = k + ks2
        vbroadcastss zmm2,real4 ptr [r9+rax*4]  ;zmm2 = kernel[k + ks2]
        vfmadd231ps zmm0,zmm1,zmm2              ;zmm0 += x[i-k]:x[i-k+15] * kernel[k+ks2]

        add r11,1                               ;k += 1
        cmp r11,r10
        jle LP2                                 ;repeat until k > ks2

        vmovaps zmmword ptr [rcx+rbx*4],zmm0    ;save y[i]:y[i + 15]

        add rbx,16                           ;i += 16
        cmp rbx,r8
        jl LP1                              ;repeat until done
        mov eax,1                           ;set success return code

Done:   vzeroupper
        _DeleteFrame rbx
        ret
Avx512Convolve2_ endp

; extern bool Avx512Convolve2Ks5_(float* y, const float* x, int num_pts, const float* kernel, int kernel_size)

Avx512Convolve2Ks5_ proc frame
        _CreateFrame CKS5_,0,48
        _SaveXmmRegs xmm6,xmm7,xmm8
        _EndProlog

; Validate argument values
        xor eax,eax                         ;set error code (rax is also loop index var)

        cmp dword ptr [rbp+CKS5_OffsetStackArgs],5
        jne Done                            ;jump if kernel_size is not 5

        cmp r8d,[c_NumPtsMin]
        jl Done                             ;jump if num_pts too small
        cmp r8d,[c_NumPtsMax]
        jg Done                             ;jump if num_pts too big
        test r8d,15
        jnz Done                            ;num_pts not even multiple of 15

        test rcx,3fh
        jnz Done                            ;y is not properly aligned

; Perform required initializations
        vbroadcastss zmm4,real4 ptr [r9]        ;kernel[0]
        vbroadcastss zmm5,real4 ptr [r9+4]      ;kernel[1]
        vbroadcastss zmm6,real4 ptr [r9+8]      ;kernel[2]
        vbroadcastss zmm7,real4 ptr [r9+12]     ;kernel[3]
        vbroadcastss zmm8,real4 ptr [r9+16]     ;kernel[4]

        mov r8d,r8d                             ;r8 = num_pts
        add rdx,8                               ;x += 2

; Perform convolution
@@:     vxorps zmm2,zmm2,zmm2                   ;initialize sum vars
        vxorps zmm3,zmm3,zmm3

        mov r11,rax
        add r11,2                               ;j = i + ks2

        vmovups zmm0,zmmword ptr [rdx+r11*4]    ;zmm0 = x[j]:x[j + 15]
        vfmadd231ps zmm2,zmm0,zmm4              ;zmm2 += x[j]:x[j + 15] * kernel[0]

        vmovups zmm1,zmmword ptr [rdx+r11*4-4]  ;zmm1 = x[j - 1]:x[j + 14]
        vfmadd231ps zmm3,zmm1,zmm5              ;zmm3 += x[j - 1]:x[j + 14] * kernel[1]

        vmovups zmm0,zmmword ptr [rdx+r11*4-8]  ;zmm0 = x[j - 2]:x[j + 13]
        vfmadd231ps zmm2,zmm0,zmm6              ;zmm2 += x[j - 2]:x[j + 13] * kernel[2]

        vmovups zmm1,zmmword ptr [rdx+r11*4-12] ;zmm1 = x[j - 3]:x[j + 12]
        vfmadd231ps zmm3,zmm1,zmm7              ;zmm3 += x[j - 3]:x[j + 12] * kernel[3]

        vmovups zmm0,zmmword ptr [rdx+r11*4-16] ;zmm0 = x[j - 4]:x[j + 11]
        vfmadd231ps zmm2,zmm0,zmm8              ;zmm2 += x[j - 4]:x[j + 11] * kernel[4]

        vaddps zmm0,zmm2,zmm3                   ;final values
        vmovaps zmmword ptr [rcx+rax*4],zmm0    ;save y[i]:y[i + 15]

        add rax,16                               ;i += 16
        cmp rax,r8
        jl @B                                   ;jump if i < num_pts
        mov eax,1                               ;set success return code

Done:   vzeroupper
        _RestoreXmmRegs xmm6,xmm7,xmm8
        _DeleteFrame
        ret
Avx512Convolve2Ks5_ endp
        end
