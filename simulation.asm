section .bss

    matrix resb 8           ; matrix pointer
    columns resb 4          ; columns value
    rows resb 4             ; rows value
    w resb 4                ; coefficient value
    buf resb 16             ; buffor for floats

section .text

global start
start:
    mov [columns], edi      ; save the columns 
    mov [rows], esi         ; save the rows
    mov [matrix], rdx       ; save the pointer to the matrix
    movss [w], xmm0            ; save the coefficient value
    ; disregard the RCX and R8 registers
    ; boundaries are already in the matrix
    ret

global step
step:
    mov r8, [matrix]        ; matrix pointer
    mov r9, 1               ; i counter - iteration over rows
   
    mov r11d, [columns]     ; mov columns value

    mov rax, 8              ; put 8
    mul r11d                ; mul by the columns value
    add r8, rax             ; add to the pointer -> skip first row
    mov rdx, rax            ; store the (columns * 8) multiplication value

    mov edi, [rows]         ; mov rows value
    dec edi                 ; dec rows value - last row exception
    dec r11d                ; dec columns value - last column exception

_main_loop:                 ; loop over rows
    
    add r8, 8               ; skip first column
    cmp r9, rdi             ; check if last row - rdi == rows - 1 (rdi)
    je _save_values
    mov r10, 1              ; j counter - iteration over columns

_inner_loop:                ; loop over columns
    
    ; calculate new value
    pxor xmm0, xmm0         ; zero register

    ; get the right value
    mov esi, [r8 + 8]        ; 8 bits to the right
    mov [buf], esi

    ; get the left value
    mov esi, [r8 - 8]       ; 8 bits to the left
    mov [buf + 4], esi      

    ; get the upper value
    mov rcx, r8             ; save the current pointer
    sub rcx, rdx            ; jump back one row
    mov esi, [rcx]          ; obtain the value
    mov [buf + 8], esi

    ; get the bottom value
    mov rcx, r8             ; save the current pointer
    add rcx, rdx            ; jump forward one row
    mov esi, [rcx]          ; obtain the value
    mov [buf + 12], esi     ; put it in the buffer

_temperature_calculation:
    movups xmm0, [buf]      ; mov 4 floats (neighbours) to the xmm1
    
    movss xmm1, [r8]        ; get the current temperature value
    shufps xmm1, xmm1, 0h   ; populate the vector with the single value

    subps xmm0, xmm1        ; calculate the differences
    haddps xmm0, xmm0       ; get half sums
    haddps xmm0, xmm0       ; get the full sum (stored in the first 4 bytes)
    
    movss xmm2, [w]         ; store the coefficient
    mulss xmm0, xmm2        ; multiply by the coefficient

    movss xmm1, [r8]        ; put the current temperature
    addss xmm0, xmm1        ; add the delta

    movss [r8 + 4], xmm0    ; get the new temperature value

    inc r10                 ; inc j - column counter
    add r8, 8               ; increment the pointer by 8 bits

    cmp r10, r11            ; check is last column -> r11 == columns - 1 (r10)
    jne _inner_loop         ; jump (not eq) to the next column

    inc r9                  ; inc i - row counter
    add r8, 8               ; increment the matrix pointer -> skip the last column
    jmp _main_loop          ; jump to the next row


_save_values:

    mov r8, [matrix]        ; store the pointer to the matrix
    xor r9, r9              ; zero the counter
    xor rsi, rsi
    mov r10d, [rows]        ; store the rows value
    mov eax, [columns]      ; store the columns value

    ; multiply r10 times rax in order to get the total number of elements
    ; iterate exactly rax times
    mul r10                 

    ; iterate over all elements of the matrix
_loop:
 
    ; mov the newly calculated temperature to the correct place
    mov esi, [r8 + 4] 
    mov [r8], esi

    inc r9                  ; increment the counter
    add r8, 8               ; increment the pointer by 8 (2 floats)
    cmp r9d, eax            ; check if iteration is over
    je _end                 ; if eq jump to the end
    jmp _loop               ; continue the loop

_end:
    ret 

