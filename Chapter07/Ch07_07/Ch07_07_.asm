;-------------------------------------------------
;               Ch07_07.asm
;-------------------------------------------------

        include <MacrosX86-64-AVX.asmh>

; extern bool AvxBuildImageHistogram_(uint32_t* histo, const uint8_t* pixel_buff, uint32_t num_pixels)
;
; Returns:      0 = invalid argument value, 1 = success

        .code
        extern c_NumPixelsMax:dword

AvxBuildImageHistogram_ proc frame
        _CreateFrame BIH_,1024,0,rbx,rsi,rdi
        _EndProlog

; Make sure num_pixels is valid
        xor eax,eax                         ;set error code
        test r8d,r8d
        jz Done                             ;jump if num_pixels is zero
        cmp r8d,[c_NumPixelsMax]
        ja Done                             ;jump if num_pixels too big
        test r8d,1fh
        jnz Done                            ;jump if num_pixels % 32 != 0

; Make sure histo & pixel_buff are properly aligned
        mov rsi,rcx                         ;rsi = ptr to histo
        test rsi,0fh
        jnz Done                            ;jump if histo misaligned
        mov r9,rdx
        test r9,0fh
        jnz Done                            ;jump if pixel_buff misaligned

; Initialize local histogram buffers (set all entries to zero)
        xor eax,eax
        mov rdi,rsi                         ;rdi = ptr to histo
        mov rcx,128                         ;rcx = size in qwords
        rep stosq                           ;zero histo
        mov rdi,rbp                         ;rdi = ptr to histo2
        mov rcx,128                         ;rcx = size in qwords
        rep stosq                           ;zero histo2

; Perform processing loop initializations
        shr r8d,5                           ;number of pixel blocks (32 pixels/block)
        mov rdi,rbp                         ;ptr to histo2

; Build the histograms
        align 16                            ;align jump target
@@:     vmovdqa xmm0,xmmword ptr [r9]       ;load pixel block
        vmovdqa xmm1,xmmword ptr [r9+16]    ;load pixel block

; Process pixels 0 - 3
        vpextrb rax,xmm0,0
        add dword ptr [rsi+rax*4],1         ;count pixel 0
        vpextrb rbx,xmm0,1
        add dword ptr [rdi+rbx*4],1         ;count pixel 1
        vpextrb rcx,xmm0,2
        add dword ptr [rsi+rcx*4],1         ;count pixel 2
        vpextrb rdx,xmm0,3
        add dword ptr [rdi+rdx*4],1         ;count pixel 3

; Process pixels 4 - 7
        vpextrb rax,xmm0,4
        add dword ptr [rsi+rax*4],1         ;count pixel 4
        vpextrb rbx,xmm0,5
        add dword ptr [rdi+rbx*4],1         ;count pixel 5
        vpextrb rcx,xmm0,6
        add dword ptr [rsi+rcx*4],1         ;count pixel 6
        vpextrb rdx,xmm0,7
        add dword ptr [rdi+rdx*4],1         ;count pixel 7

; Process pixels 8 - 11
        vpextrb rax,xmm0,8
        add dword ptr [rsi+rax*4],1         ;count pixel 8
        vpextrb rbx,xmm0,9
        add dword ptr [rdi+rbx*4],1         ;count pixel 9
        vpextrb rcx,xmm0,10
        add dword ptr [rsi+rcx*4],1         ;count pixel 10
        vpextrb rdx,xmm0,11
        add dword ptr [rdi+rdx*4],1         ;count pixel 11

; Process pixels 12 - 15
        vpextrb rax,xmm0,12
        add dword ptr [rsi+rax*4],1         ;count pixel 12
        vpextrb rbx,xmm0,13
        add dword ptr [rdi+rbx*4],1         ;count pixel 13
        vpextrb rcx,xmm0,14
        add dword ptr [rsi+rcx*4],1         ;count pixel 14
        vpextrb rdx,xmm0,15
        add dword ptr [rdi+rdx*4],1         ;count pixel 15

; Process pixels 16 - 19
        vpextrb rax,xmm1,0
        add dword ptr [rsi+rax*4],1         ;count pixel 16
        vpextrb rbx,xmm1,1
        add dword ptr [rdi+rbx*4],1         ;count pixel 17
        vpextrb rcx,xmm1,2
        add dword ptr [rsi+rcx*4],1         ;count pixel 18
        vpextrb rdx,xmm1,3
        add dword ptr [rdi+rdx*4],1         ;count pixel 19

; Process pixels 20 - 23
        vpextrb rax,xmm1,4
        add dword ptr [rsi+rax*4],1         ;count pixel 20
        vpextrb rbx,xmm1,5
        add dword ptr [rdi+rbx*4],1         ;count pixel 21
        vpextrb rcx,xmm1,6
        add dword ptr [rsi+rcx*4],1         ;count pixel 22
        vpextrb rdx,xmm1,7
        add dword ptr [rdi+rdx*4],1         ;count pixel 23

; Process pixels 24 - 27
        vpextrb rax,xmm1,8
        add dword ptr [rsi+rax*4],1         ;count pixel 24
        vpextrb rbx,xmm1,9
        add dword ptr [rdi+rbx*4],1         ;count pixel 25
        vpextrb rcx,xmm1,10
        add dword ptr [rsi+rcx*4],1         ;count pixel 26
        vpextrb rdx,xmm1,11
        add dword ptr [rdi+rdx*4],1         ;count pixel 27

; Process pixels 28 - 31
        vpextrb rax,xmm1,12
        add dword ptr [rsi+rax*4],1         ;count pixel 28
        vpextrb rbx,xmm1,13
        add dword ptr [rdi+rbx*4],1         ;count pixel 29
        vpextrb rcx,xmm1,14
        add dword ptr [rsi+rcx*4],1         ;count pixel 30
        vpextrb rdx,xmm1,15
        add dword ptr [rdi+rdx*4],1         ;count pixel 31

        add r9,32                           ;r9  = next pixel block
        sub r8d,1
        jnz @B                              ;repeat loop if not done

; Merge intermediate histograms into final histogram
        mov ecx,32                          ;ecx = num iterations
        xor eax,eax                         ;rax = common offset

@@:     vmovdqa xmm0,xmmword ptr [rsi+rax]          ;load histo counts
        vmovdqa xmm1,xmmword ptr [rsi+rax+16]
        vpaddd xmm0,xmm0,xmmword ptr [rdi+rax]      ;add counts from histo2
        vpaddd xmm1,xmm1,xmmword ptr [rdi+rax+16]
        vmovdqa xmmword ptr [rsi+rax],xmm0          ;save final result
        vmovdqa xmmword ptr [rsi+rax+16],xmm1

        add rax,32
        sub ecx,1
        jnz @B
        mov eax,1                           ;set success return code

Done:  _DeleteFrame rbx,rsi,rdi
        ret
AvxBuildImageHistogram_ endp
        end
