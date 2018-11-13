;-------------------------------------------------
;               Ch11_01_.asm
;-------------------------------------------------

        include <MacrosX86-64-AVX.asmh>
        extern c_NumPtsMin:dword
        extern c_NumPtsMax:dword
        extern c_KernelSizeMin:dword
        extern c_KernelSizeMax:dword

; extern "C" bool Convolve1_(float* y, const float* x, int num_pts, const float* kernel, int kernel_size)

        .code
Convolve1_ proc frame
        _CreateFrame CV_,0,0,rbx,rsi
        _EndProlog

; Verify argument values
        xor eax,eax                         ;set error code (rax is also loop index var)

        mov r10d,dword ptr [rbp+CV_OffsetStackArgs]
        test r10d,1
        jz Done                             ;jump if kernel_size is even
        cmp r10d,[c_KernelSizeMin]
        jl Done                             ;jump if kernel_size too small
        cmp r10d,[c_KernelSizeMax]
        jg Done                             ;jump if kernel_size too big

        cmp r8d,[c_NumPtsMin]
        jl Done                             ;jump if num_pts too small
        cmp r8d,[c_NumPtsMax]
        jg Done                             ;jump if num_pts too big

; Perform required initializations
        mov r8d,r8d                         ;r8 = num_pts
        shr r10d,1                          ;ks2 = ks / 2
        lea rdx,[rdx+r10*4]                 ;rdx = x + ks2 (first data point)

; Perform convolution
LP1:    vxorps xmm5,xmm5,xmm5               ;sum = 0.0;
        mov r11,r10
        neg r11                             ;k = -ks2

LP2:    mov rbx,rax
        sub rbx,r11                         ;rbx = i - k
        vmovss xmm0,real4 ptr [rdx+rbx*4]   ;xmm0 = x[i - k]
        mov rsi,r11
        add rsi,r10                         ;rsi = k + ks2
        vfmadd231ss xmm5,xmm0,[r9+rsi*4]    ;sum += x[i - k] * kernel[k + ks2]

        add r11,1                           ;k++
        cmp r11,r10
        jle LP2                             ;jump if k <= ks2

        vmovss real4 ptr [rcx+rax*4],xmm5   ;y[i] = sum

        add rax,1                           ;i += 1
        cmp rax,r8
        jl LP1                              ;jump if i < num_pts

        mov eax,1                           ;set success return code

Done:   vzeroupper
        _DeleteFrame rbx,rsi
        ret
Convolve1_ endp

; extern "C" bool Convolve1Ks5_(float* y, const float* x, int num_pts, const float* kernel, int kernel_size)

Convolve1Ks5_ proc
; Verify argument values
        xor eax,eax                         ;set error code (rax is also loop index var)

        cmp dword ptr [rsp+40],5
        jne Done                            ;jump if kernel_size is not 5

        cmp r8d,[c_NumPtsMin]
        jl Done                             ;jump if num_pts too small
        cmp r8d,[c_NumPtsMax]
        jg Done                             ;jump if num_pts too big

; Perform required initializations
        mov r8d,r8d                         ;r8 = num_pts
        add rdx,8                           ;x += 2

; Perform convolution
@@:     vxorps xmm4,xmm4,xmm4                   ;initialize sum vars
        vxorps xmm5,xmm5,xmm5
        mov r11,rax
        add r11,2                               ;j = i + ks2

        vmovss xmm0,real4 ptr [rdx+r11*4]       ;xmm0 = x[j]
        vfmadd231ss xmm4,xmm0,[r9]              ;xmm4 += x[j] * kernel[0]

        vmovss xmm1,real4 ptr [rdx+r11*4-4]     ;xmm1 = x[j - 1]
        vfmadd231ss xmm5,xmm1,[r9+4]            ;xmm5 += x[j - 1] * kernel[1]

        vmovss xmm0,real4 ptr [rdx+r11*4-8]     ;xmm0 = x[j - 2]
        vfmadd231ss xmm4,xmm0,[r9+8]            ;xmm4 += x[j - 2] * kernel[2]

        vmovss xmm1,real4 ptr [rdx+r11*4-12]    ;xmm1 = x[j - 3]
        vfmadd231ss xmm5,xmm1,[r9+12]           ;xmm5 += x[j - 3] * kernel[3]

        vmovss xmm0,real4 ptr [rdx+r11*4-16]    ;xmm0 = x[j - 4]
        vfmadd231ss xmm4,xmm0,[r9+16]           ;xmm4 += x[j - 4] * kernel[4]

        vaddps xmm4,xmm4,xmm5
        vmovss real4 ptr [rcx+rax*4],xmm4       ;save y[i]

        inc rax                                 ;i += 1
        cmp rax,r8
        jl @B                                   ;jump if i < num_pts

        mov eax,1                               ;set success return code

Done:   vzeroupper
        ret
Convolve1Ks5_ endp
        end
