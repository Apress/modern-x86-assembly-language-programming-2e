;-------------------------------------------------
;               Ch05_07.asm
;-------------------------------------------------

; extern "C" bool CalcMeanStdev(double* mean, double* stdev, const double* a, int n);
;
; Returns:      0 = invalid n, 1 = valid n 

        .code
CalcMeanStdev_  proc

; Make sure 'n' is valid
        xor eax,eax                         ;set error return code (also i = 0)
        cmp r9d,2
        jl InvalidArg                       ;jump if n < 2

; Compute sample mean
        vxorpd xmm0,xmm0,xmm0               ;sum = 0.0

@@:     vaddsd xmm0,xmm0,real8 ptr [r8+rax*8]   ;sum += x[i]
        inc eax                                 ;i += 1
        cmp eax,r9d
        jl @B                                  ;jump if i < n

        vcvtsi2sd xmm1,xmm1,r9d             ;convert n to DPFP
        vdivsd xmm3,xmm0,xmm1               ;xmm3 = mean (sum / n)
        vmovsd real8 ptr [rcx],xmm3         ;save mean

; Compute sample stdev
        xor eax,eax                         ;i = 0
        vxorpd xmm0,xmm0,xmm0               ;sum2 = 0.0

@@:     vmovsd xmm1,real8 ptr [r8+rax*8]    ;xmm1 = x[i]
        vsubsd xmm2,xmm1,xmm3               ;xmm2 = x[i] - mean
        vmulsd xmm2,xmm2,xmm2               ;xmm2 = (x[i] - mean) ** 2
        vaddsd xmm0,xmm0,xmm2               ;sum2 += (x[i] - mean) ** 2
        inc eax                             ;i += 1
        cmp eax,r9d
        jl @B                               ;jump if i < n

        dec r9d                             ;r9d = n - 1
        vcvtsi2sd xmm1,xmm1,r9d             ;convert n - 1 to DPFP
        vdivsd xmm0,xmm0,xmm1               ;xmm0 = sum2 / (n - 1)
        vsqrtsd xmm0,xmm0,xmm0              ;xmm0 = stdev
        vmovsd real8 ptr [rdx],xmm0         ;save stdev

        mov eax,1                           ;set success return code

InvalidArg:
        ret
CalcMeanStdev_ endp
        end
