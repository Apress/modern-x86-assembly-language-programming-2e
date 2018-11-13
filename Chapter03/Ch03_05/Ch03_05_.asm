;-------------------------------------------------
;               Ch03_05.asm
;-------------------------------------------------

TestStruct struct
Val8    byte ?
Pad8    byte ?
Val16   word ?
Val32   dword ?
Val64   qword ?
TestStruct ends

; extern "C" int64_t CalcTestStructSum_(const TestStruct* ts);
;
; Returns:      Sum of structure's values as a 64-bit integer.

        .code
CalcTestStructSum_ proc

; Compute ts->Val8 + ts->Val16, note sign extension to 32-bits
        movsx eax,byte ptr [rcx+TestStruct.Val8]
        movsx edx,word ptr [rcx+TestStruct.Val16]
        add eax,edx

; Sign extend previous result to 64 bits
        movsxd rax,eax

; Add ts->Val32 to sum
        movsxd rdx,[rcx+TestStruct.Val32]
        add rax,rdx

; Add ts->Val64 to sum
        add rax,[rcx+TestStruct.Val64]
        ret

CalcTestStructSum_ endp
        end
