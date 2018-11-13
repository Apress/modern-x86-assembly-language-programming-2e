;-------------------------------------------------
;               Ch05_02.asm
;-------------------------------------------------

        .const
r8_PI   real8 3.14159265358979323846
r8_4p0  real8 4.0
r8_3p0  real8 3.0

; extern "C" void CalcSphereAreaVolume_(double r, double* sa, double* vol);

        .code
CalcSphereAreaVolume_ proc

; Calculate surface area = 4 * PI * r * r
        vmulsd xmm1,xmm0,xmm0               ;xmm1 = r * r
        vmulsd xmm2,xmm1,[r8_PI]            ;xmm2 = r * r * PI
        vmulsd xmm3,xmm2,[r8_4p0]           ;xmm3 = r * r * PI * 4

; Calculate volume = sa * r / 3
        vmulsd xmm4,xmm3,xmm0               ;xmm4 = r * r * r * PI * 4
        vdivsd xmm5,xmm4,[r8_3p0]           ;xmm5 = r * r * r * PI * 4 / 3

; Save results
        vmovsd real8 ptr [rdx],xmm3         ;save surface area
        vmovsd real8 ptr [r8],xmm5          ;save volume
        ret
CalcSphereAreaVolume_ endp
        end
