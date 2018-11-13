;-------------------------------------------------
;               Ch15_01.asm
;-------------------------------------------------

        .const
r8_2p0  real8 2.0

; extern "C" int CalcResult_(double* y, const double* x, size_t n);

        .code
CalcResult_ proc

; Forward conditional jumps are used in this code block since
; the fall-through cases are more likely to occur
        test r8,r8
        jz Done                             ;jump if n == 0

        test r8,7h
        jnz Error                           ;jump if (n % 8) != 0
        test rcx,1fh
        jnz Error                           ;jump if y is not aligned to a 32b boundary
        test rdx,1fh
        jnz Error                           ;jump if x is not aligned to a 32b boundary

; Initialize
        xor eax,eax                             ;set array offset to zero
        vbroadcastsd ymm5,real8 ptr [r8_2p0]    ;packed 2.0

; Simple array processing loop
        align 16
@@:     vmovapd ymm0,ymmword ptr [rdx+rax]      ;load x[i+3]:x[i]
        vdivpd ymm1,ymm0,ymm5
        vsqrtpd ymm2,ymm1
        vmovapd ymmword ptr [rcx+rax],ymm2      ;save y[i+3]:y[i]

        vmovapd ymm0,ymmword ptr [rdx+rax+32]   ;load x[i+7]:x[i+4]
        vdivpd ymm1,ymm0,ymm5
        vsqrtpd ymm2,ymm1
        vmovapd ymmword ptr [rcx+rax+32],ymm2   ;save y[i+7]:y[i+4]

; A backward conditional jump is used in this code block since
; the fall-through case is less likely to occur
        add rax,64
        sub r8,8
        jnz @B

Done:   xor eax,eax                         ;set success return code
        vzeroupper
        ret

; Error handling code that's unlikely to execute

Error:  mov eax,1                           ;set error return code
        ret
CalcResult_ endp
        end
