;-------------------------------------------------
;               Ch13_01.asm
;-------------------------------------------------

            include <cmpequ.asmh>
            .const
r8_three    real8 3.0
r8_four     real8 4.0

            extern g_PI:real8

; extern "C" bool Avx512CalcSphereAreaVol_(double* sa, double* v, double r, double error_val);
;
; Returns:  false = invalid radius, true = valid radius

        .code
Avx512CalcSphereAreaVol_ proc

; Test radius for value >= 0.0
        vmovsd xmm0,xmm0,xmm2               ;xmm0 = radius
        vxorpd xmm5,xmm5,xmm5               ;xmm5 = 0.0
        vmovsd xmm16,xmm16,xmm3             ;xmm16 = error_val
        vcmpsd k1,xmm0,xmm5,CMP_GE          ;k1[0] = 1 if radius >= 0.0

; Calculate surface area and volume using mask from compare
        vmulsd xmm1{k1},xmm0,xmm0           ;xmm1 = r * r
        vmulsd xmm2{k1},xmm1,[r8_four]      ;xmm2 = 4 * r * r
        vmulsd xmm3{k1},xmm2,[g_PI]         ;xmm3 = 4 * PI * r * r (sa)
        vmulsd xmm4{k1},xmm3,xmm0           ;xmm4 = 4 * PI * r * r * r
        vdivsd xmm5{k1},xmm4,[r8_three]     ;xmm5 = 4 * PI * r * r * r / 3 (vol)

; Set surface area and volume to error_val if radius < 0.0 is true
        knotw k2,k1                         ;k2[0] = 1 if radius < 0.0
        vmovsd xmm3{k2},xmm3,xmm16          ;xmm3 = error_val if radius < 0.0
        vmovsd xmm5{k2},xmm5,xmm16          ;xmm5 = error_val if radius < 0.0

; Save results
        vmovsd real8 ptr [rcx],xmm3         ;save surface area
        vmovsd real8 ptr [rdx],xmm5         ;save volume

        kmovw eax,k1                        ;eax = return code
        ret
Avx512CalcSphereAreaVol_ endp
        end
