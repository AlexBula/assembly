section .text

global convert

convert:
    push rbx ; save rbx
    push r12 ; save r12

    ; rsi - columns
    ; rdx - rows

    mov r8, 0x4D ; 77
    mov r9, 0x97 ; 151
    mov r10, 0x1C ; 28

    sub rdi, 0x8

_image_loop:
    dec rdx ; decrement remaining rows
    add rdi, 0x8 ; jump to next pointer
    
    cmp rdx, 0 
    jl _end ; <= 0 - iteration is over

    mov rbx, rsi ; save columns value
    mov r12, [rdi] ; input pointer
    mov rcx, [rdi] ; result pointer
_inner_loop:
    cmp rbx, 0
    je _image_loop ; visited all columns

    xor r11, r11 ; color average

    mov al, byte [r12] ; red
    mul r8b ; mul by 77
    add r11w, ax ; add result to r11
    
    mov al, byte [r12 + 4] ; green
    mul r9b ; mul by 151
    add r11w, ax ; add result to r11

    mov al, byte [r12 + 8] ; blue
    mul r10b ; mul by 28
    add r11w, ax ; add result to r11

    shr r11w, 0x8 ; shift r11 by 8 -> divide by 256
    mov [rcx], r11d ; put 4 bytes in the result array
    
    add rcx, 0x4 ; add 4 bytes - now points to the new column
    add r12, 0xC ; add 12 bytes - now points to the new column
    dec rbx ; decrement column counter
    jmp _inner_loop

_end:
    pop r12 ; return registers to initial state
    pop rbx
    ret 