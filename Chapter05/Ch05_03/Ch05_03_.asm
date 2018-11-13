;-------------------------------------------------
;               Ch05_03.asm
;-------------------------------------------------

; extern "C" double CalcDistance_(double x1, double y1, double z1, double x2, double y2, double z2)

        .code
CalcDistance_ proc
; Load arguments from stack
        vmovsd xmm4,real8 ptr [rsp+40]      ;xmm4 = y2
        vmovsd xmm5,real8 ptr [rsp+48]      ;xmm5 = z2

; Calculate squares of coordinate distances
        vsubsd xmm0,xmm3,xmm0               ;xmm0 = x2 - x1
        vmulsd xmm0,xmm0,xmm0               ;xmm0 = (x2 - x1) * (x2 - x1)

        vsubsd xmm1,xmm4,xmm1               ;xmm1 = y2 - y1
        vmulsd xmm1,xmm1,xmm1               ;xmm1 = (y2 - y1) * (y2 - y1)
                
        vsubsd xmm2,xmm5,xmm2               ;xmm2 = z2 - z1
        vmulsd xmm2,xmm2,xmm2               ;xmm2 = (z2 - z1) * (z2 - z1)

; Calculate final distance
        vaddsd xmm3,xmm0,xmm1
        vaddsd xmm4,xmm2,xmm3               ;xmm4 = sum of squares
        vsqrtsd xmm0,xmm0,xmm4              ;xmm0 = final distance value
        ret
CalcDistance_ endp
        end
