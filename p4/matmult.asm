; Hannah Gulle
; CSC 322 Prog 4
; 10/30/18
; Matrix Multiplication without MUL Command

; ------------- TEST CASE 1 ---------------------
;X      equ 3
;Y      equ 2
;Z      equ 4
;
;section.data
;M1     dd      1, 2
;       dd      3, 4
;       dd      5, 6
;
;M2     dd      2, 3, 4, 5
;       dd      1, 2, 3, 4
;
; Should Produce: {4, 7, 10, 13, 10, 17, 24, 31, 16, 27, 38, 49}
; ----------------------------------------------

; ------------- TEST CASE 2 ---------------------
;X      equ 2
;Y      equ 4
;Z      equ 2
;
;section.data
;M1     dd      1, 2, 1, 2
;       dd      2, 1, 2, 1
;
;M2     dd      1, 2
;       dd      2, 3
;       dd      3, 4
;       dd      4, 5
; Should Product: {16, 22, 14, 20}
; -----------------------------------------------


; Constant Data
X       equ 4                                   ; Rows for M1 and Results
Y       equ 3                                   ; Cols for M1 and Rows for M2
Z       equ 2                                   ; Cols for M2 and Results

section .data
M1      dd      1, 2, 2                         ; Matrix 1 (Left hand Matrix)
        dd      3, 2, 1
        dd      1, 2, 3
        dd      2, 2, 2

M2      dd      2, 4                            ; Matrix 2 (Right Hand Matrix)
        dd      3, 3
        dd      4, 6

xindex  dd      0                               ; Row Index of M2 and Results 
y1index dd      0                               ; Column Index of M1 Matrix
y2index dd      0                               ; Row Index of Results Matrix
zindex  dd      0                               ; Column Index of M2
rindex  dd      0                               ; Element Index of Results

rsum    dd      0                               ; Current Sum of the M1M2 Prod

xoffset dd      0                               ; DataSize Offset M1 Row Index
y1offset dd     0                               ; DataSize Offset M1 Col Index
y2offset dd     0                               ; DataSize Offset M2 Row Index
roffset dd      0                               ; DataSize Offset Results Index

section .bss
Results resd    X*Z                             ; Reserve Memory for the Double
                                                ; Results Matrix

section .text
global _main


_main:

xor eax, eax                                    ; Clear Registers
xor ebx, ebx
xor ecx, ecx
xor edx, edx
zero:

mov DWORD eax, 4                                ; Set the xoffset to
mov DWORD ebx, Y                                ; (Datasize)*(Y)
mul DWORD ebx
mov DWORD [xoffset], eax

mov DWORD eax, 4                                ; Set the y2offset to 
mov DWORD ebx, Z                                ; (Datasize)*(Z)
mul DWORD ebx
mov DWORD [y2offset], eax

mov DWORD [Results], 0                          ; Initialize the Results to 0

mov DWORD eax, 4                                ; Set the y1offset and roffset 
mov DWORD [y1offset], eax                       ; to (Datasize)
mov DWORD [roffset], eax

mov DWORD ecx, X                                ; Loop over M1 and Results Rows
M1Loop:

        push ecx                                ; Move the loop counter
        mov DWORD ecx, Z                        ; To the stack so the next
        M2Loop:                                 ; Loop can use ECX

                                                ; Loop over M2 and Results Cols
                push ecx                        ; Move the loop counter
                mov DWORD ecx, Y                ; to the stack so the next
                                                ; Loop can use ECX

                mov DWORD ebx, 0                ; Zero the y index value for b
                mov DWORD [y1index], ebx        ; both M1 and M2
                mov DWORD [y2index], ebx
                MulLoop:

                                                ; Retrieve the current M1 Value
                mov DWORD ebx, [xindex]
                add DWORD ebx, [y1index]        ; X[x,y]
                mov DWORD edx, [M1 + ebx]
                x:

                                                ; Retrieve the current M2 Value
                mov DWORD ebx, [y2index]
                mov DWORD eax, [zindex]
                add DWORD ebx, eax              ; Y[y,z]
                mov DWORD eax, [M2 + ebx]
                y:

; --------------------------------------------------------------------------
; Multiplication without the MUL Command
; mul edx <-- X[x,y]Y[y,z]
                mov DWORD ebx, 0                ; Zero the rsum register (ebx)
                push ecx
                mov DWORD ecx, edx
                loopX:                          ; Loop for the current M1 Value
                        push ecx
                        mov DWORD ecx, eax
                        loopY:                  ; Loop for the current M2 Value

                                inc ebx         ; INC used instead of MUL

                        dec ecx
                        jnz loopY
                        pop ecx
                dec ecx
                jnz loopX
                pop ecx
; End Multiplication without the MUL Command
; ---------------------------------------------------------------------------
                add DWORD [rsum], ebx           ; R[x,z] += X[x,y]Y[y,z]
                                                ; Add the current Element Prod
                                                ; to the rsum Value

                mov DWORD ebx, Results          ; Increment the Results Address
                mov DWORD eax, [rindex]         ; by the current index value
                add DWORD ebx, eax              ; R @ Rindex with Offset

                mov DWORD eax, [rsum]
                mov DWORD [ebx], eax            ; Insert rsum value into Results

                mov DWORD ebx, [y1index]        ; Increment y1index by y1offset
                add DWORD ebx, [y1offset]
                mov DWORD [y1index], ebx

                mov DWORD ebx, [y2index]        ; Increment y2index by y2offset
                add DWORD ebx, [y2offset]
                mov DWORD [y2index], ebx

                loop MulLoop


                mov DWORD eax, [rindex]         ; Increment rindex by roffset
                mov DWORD ebx, [roffset]
                add DWORD eax, ebx
                mov DWORD [rindex], eax


                mov DWORD edx, 0
                mov DWORD [rsum], edx           ; Clears Rsum for the next R val
                pop ecx                         ; Return the previous counter
                                                ; from the stack to ECX

                mov DWORD eax, [zindex]         ; Increment zindex starting
                add DWORD eax, 4                ; at 0 by data size (4)
                mov DWORD [zindex], eax
                zinc:
        dec ecx                                 ; Used instead of LOOP because 
        jnz M2Loop                              ; the jump was too long

        pop ecx                                 ; Return the previous counter
                                                ; from the stack to ECX

        mov DWORD eax, [zindex]                 ; Reset the zindex after the 
        mov DWORD ebx, 0                        ; end of the Z Loop
        mov DWORD [zindex], ebx

        mov DWORD eax, [y1index]                ; Reset the y1index after the 
        mov DWORD ebx, 0                        ; end of the Z Loop
        mov DWORD [y1index], ebx

        mov DWORD eax, [y2index]                ; Reset the y2index after the
        mov DWORD ebx, 0                        ; end of the Z loop
        mov DWORD [y2index], ebx

        mov DWORD eax, [xindex]                 ; Increment xindex by xoffset
        add DWORD eax, [xoffset]
        mov DWORD [xindex], eax

dec ecx                                         ; Used instead of LOOP because 
jnz M1Loop                                      ; the jump was too long

done:                                           ; Normal Termination
mov eax, 1
mov ebx, 0
int 80h
terminate: