; Finds all 8-bit solutions for the equation a^3 = b^2 - 17

%include "rw32-2020.inc"

section .data
    ; zde budou vase data

section .text
_main:
    push ebp
    mov ebp, esp
    
    mov bl, 0 ; bl = [b]
    mov cl, 0 ; cl = [a]
    
for:
    mov al, cl
    cbw
    cwde
    mov edx, eax
    imul al ; ax = a^2
    cwde
    imul edx ; eax = a^3
    mov edx, eax ; save left part to edx
    
    mov al, bl
    imul al ; ax = b^2
    sub ax, 17 ; ax = b^2 - 17
    cwde
    
    cmp eax, edx
    jne continue ; if not a solution, jump to incrementing
    mov al, cl
    call WriteInt8
    mov al, 32
    call WriteChar
    mov al, bl
    call WriteInt8
    call WriteNewLine                 
    
continue:
    add bl, 1
    jnc for
    add cl, 1
    jnc for

    pop ebp
    ret