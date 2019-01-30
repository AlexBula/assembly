.bss

.balign 4
matrix:  .word 1    @ matrix pointer
.balign 4
columns: .word 1    @ columns value
.balign 4
rows: .word 1       @ rows value

.text

.global start
start:

    ldr r3, =matrix
    ldr r4, =columns
    ldr r5, =rows
    str r0, [r4]   @ save the columns 
    str r1, [r5]   @ save the rows
    str r2, [r3]   @ save the pointer to the matrix
    bx lr
    

.global step
step:
    push {r4, r5, r6, r7, r8, r9, r10, lr} @ save registers
    ldr r8, =matrix         @ load the pointer
    ldr r5, [r8]            @ load the value stored under matrix

    ldr r8, =columns        @ load the pointer
    ldr r4, [r8]            @ load the value stored under columns

    ldr r8, =rows           @ load the pointer
    ldr r3, [r8]            @ load the value stored under rows

    mov r1, #8              @ put 8
    mul r0, r1, r4          @ mul 8 by the columns value

    add r5, r5, r0          @ add to the matrix pointer -> skip first row
    mov r10, r0             @ store the (columns * 8) multiplication value

    sub r3, r3, #1          @ decrement the rows value - last row excection
    sub r4, r4, #1          @ decrement the columns value - last column exception

    mov r9, #1              @ i counter - iteration over rows

_main_loop:                 @ loop over rows
    
    add r5, r5, #8          @ skip first column
    cmp r9, r3              @ check if last row - r9 == rows - 1 (r3)
    beq _save_values
    mov r8, #1              @ j counter - iteration over columns

_inner_loop:                @ loop over columns
    
    mov r6, #1              @ load 1 to compare if alive cell
    eor r2, r2, r2          @ xor r2, r2 = number of alive neighbours

    mov r7, r5              @ save current pointer 
    sub r7, r7, r10         @ substract one row
    bl _check_neighbours    @ check upper row

    mov r7, r5              @ save current pointer
    add r7, r7, r10         @ add one row
    bl _check_neighbours    @ check lower row

    ldr r1, [r5, #-8]       @ left neighbour
    add r2, r2, r1          @ add neighbour value to r2
    ldr r1, [r5, #8]        @ right neighbour
    add r2, r2, r1          @ add neighbour value to r2

_determine_new_status:
    
    ldr r0, [r5]            @ check current cell
    cmp r0, r6              @ check if not dead
    bne _dead               @ r0 != 1 -> dead cell
   
    @ only alive cells
    mov r0, #2              @ load 2
    cmp r2, r0              @ check if has less than 2 alive neighbours
    blt _dies               @ r2 < r0 -> cell dies

    mov r0, #4              @ load 4
    cmp r2, r0              @ check if has 4 or more alive neighbours
    blt _loop_closure       @ 2 <= r2 < 4 -> cell stays alive

_dies:

    mov r1, #0              @ load 0 -> cell dies
    str r1, [r5, #4]        @ save the new state

_loop_closure:

    add r8, r8, #1          @ inc j - column counter
    add r5, #8              @ increment the pointer by 8 bits

    cmp r8, r4              @ check is last column -> r8 == columns - 1 (r4)
    bne _inner_loop         @ jump (not eq) to the next column

    add r9, r9, #1          @ inc i - row counter
    add r5, #8              @ increment the matrix pointer -> skip the last column
    b _main_loop            @ jump to the next row

_dead:

    mov r0, #3
    cmp r0, r2              @ check if dead cell has 3 alive neighbours

    moveq r1, #1            @ load 1 -> cell becomes alive
    streq r1, [r5, #4]      @ save the new state

    b _loop_closure         @ jump back to the loops

_check_neighbours:

    ldr r1, [r7, #-8]       @ left corner neighbour 
    add r2, r2, r1          @ add neighbour value to the r2

    ldr r1, [r7]            @ vertical neighbour
    add r2, r2, r1          @ add neighbour value to the r2 

    ldr r1, [r7, #8]        @ right corner neighbour
    add r2, r2, r1          @ add neighbour value to the r2 

    bx lr                   @ jump back to call location

_save_values:

    ldr r8, =matrix         @ store the pointer to the matrix
    ldr r5, [r8]            @ get the matrix
    ldr r8, =rows           @ store the rows pointer
    ldr r4, [r8]            @ get the rows value
    ldr r8, =columns        @ store the columns pointer
    ldr r3, [r8]            @ get the columns value
    eor r9, r9, r9          @ zero the counter

    @ multiply r3 times r4 in order to get the total number of elements
    @ iterate exactly r0 times
    mul r0, r3, r4                 

    @ iterate over all cells of the matrix
_loop:
 
    @ mov the newly calculated temperature to the correct place
    ldr r1, [r5, #4]        @ get the newly calculated state
    str r1, [r5]            @ save the new state as current

    add r9, r9, #1          @ increment the counter
    add r5, r5, #8          @ increment the pointer by 2 (2 chars)

    cmp r9, r0              @ check if we reached the last row
    beq _end                @ if eq jump to the end
    b _loop                 @ otherwise continue the loop

_end:
    pop {r4, r5, r6, r7, r8, r9, r10, lr}
    bx lr 

