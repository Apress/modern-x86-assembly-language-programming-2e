;-------------------------------------------------
;               Ch13_08.asm
;-------------------------------------------------

ConstVals   segment readonly align(64) 'const'
; Indices for matrix permutations
MatPerm0    dword 0, 4, 8, 12, 0, 4, 8, 12, 0, 4, 8, 12, 0, 4, 8, 12
MatPerm1    dword 1, 5, 9, 13, 1, 5, 9, 13, 1, 5, 9, 13, 1, 5, 9, 13
MatPerm2    dword 2, 6, 10, 14, 2, 6, 10, 14, 2, 6, 10, 14, 2, 6, 10, 14
MatPerm3    dword 3, 7, 11, 15, 3, 7, 11, 15, 3, 7, 11, 15, 3, 7, 11, 15

; Indices for vector permutations
VecPerm0    dword 0, 0, 0, 0, 4, 4, 4, 4, 8, 8, 8, 8, 12, 12, 12, 12
VecPerm1    dword 1, 1, 1, 1, 5, 5, 5, 5, 9, 9, 9, 9, 13, 13, 13, 13
VecPerm2    dword 2, 2, 2, 2, 6, 6, 6, 6, 10, 10, 10, 10, 14, 14, 14, 14
VecPerm3    dword 3, 3, 3, 3, 7, 7, 7, 7, 11, 11, 11, 11, 15, 15, 15, 15
ConstVals   ends

; extern "C" bool Avx512MatVecMulF32_(Vec4x1_F32* vec_b, float mat[4][4], Vec4x1_F32* vec_a, size_t num_vec);

        .code
Avx512MatVecMulF32_ proc
        xor eax,eax                         ;set error code (also i = 0)
        test r9,r9
        jz Done                             ;jump if num_vec is zero
        test r9,3
        jnz Done                            ;jump if n % 4 != 0

        test rcx,3fh
        jnz Done                            ;jump if vec_b is not properly aligned
        test rdx,3fh
        jnz Done                            ;jump if mat is not properly aligned
        test r8,3fh
        jnz Done                            ;jump if vec_a is not properly aligned

; Load permutation indices for matrix columns and vector elements
        vmovdqa32 zmm16,zmmword ptr [MatPerm0]  ;mat col 0 indices
        vmovdqa32 zmm17,zmmword ptr [MatPerm1]  ;mat col 1 indices
        vmovdqa32 zmm18,zmmword ptr [MatPerm2]  ;mat col 2 indices
        vmovdqa32 zmm19,zmmword ptr [MatPerm3]  ;mat col 3 indices

        vmovdqa32 zmm24,zmmword ptr [VecPerm0]  ;W component indices
        vmovdqa32 zmm25,zmmword ptr [VecPerm1]  ;X component indices
        vmovdqa32 zmm26,zmmword ptr [VecPerm2]  ;Y component indices
        vmovdqa32 zmm27,zmmword ptr [VecPerm3]  ;Z component indices

; Load source matrix and duplicate columns
        vmovaps zmm0,zmmword ptr [rdx]      ;zmm0 = mat

        vpermps zmm20,zmm16,zmm0            ;zmm20 = mat col 0 (4x)
        vpermps zmm21,zmm17,zmm0            ;zmm21 = mat col 1 (4x)
        vpermps zmm22,zmm18,zmm0            ;zmm22 = mat col 2 (4x)
        vpermps zmm23,zmm19,zmm0            ;zmm23 = mat col 3 (4x)

; Load the next 4 vectors
        align 16
@@:     vmovaps zmm4,zmmword ptr [r8+rax]   ;zmm4 = vec_a (4 vectors)

; Permute the vector elements for subsequent calculations
        vpermps zmm0,zmm24,zmm4             ;zmm0 = vec_a W components
        vpermps zmm1,zmm25,zmm4             ;zmm1 = vec_a X components
        vpermps zmm2,zmm26,zmm4             ;zmm2 = vec_a Y components
        vpermps zmm3,zmm27,zmm4             ;zmm3 = vec_a Z components

; Perform matrix-vector multiplications (4 vectors)
        vmulps zmm28,zmm20,zmm0
        vmulps zmm29,zmm21,zmm1
        vmulps zmm30,zmm22,zmm2
        vmulps zmm31,zmm23,zmm3
        vaddps zmm4,zmm28,zmm29
        vaddps zmm5,zmm30,zmm31
        vaddps zmm4,zmm4,zmm5               ;zmm4 = vec_b (4 vectors)

        vmovaps zmmword ptr [rcx+rax],zmm4  ;save result

        add rax,64                          ;rax = offset to next block of 4 vectors
        sub r9,4
        jnz @B                              ;repeat until done
      
        mov eax,1                           ;set success code

Done:   vzeroupper
        ret
Avx512MatVecMulF32_ endp
        end