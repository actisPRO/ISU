; Checks if an unsigned 16-bit input is a prime number

%include "rw32-2020.inc"

section .data
    Yes db "Is prime", 0
    No  db "Not prime", 0

section .text
_main:
    push ebp
    mov ebp, esp
    
    call ReadUInt16_Silent
    cmp ax, 1
    jle _no ; 0 or 1
    
    ;xor ebx, ebx   
    ;xor ecx, ecx
    
    mov cx, ax ; input value, as ax is changed after division
    mov bx, 2
_cycle:
    xor dx, dx ; dx must be 0 for division
    
    cmp bx, cx ; if bx reached input
    je _yes ;  ; then number can't be divided by any number
    
    div word bx
    cmp dx, 0
    je _no
    
    mov ax, cx 
    inc bx
    jmp _cycle
    
_no:
    mov esi, No
    jmp _ret
    
_yes:
    mov esi, Yes

_ret:
    call WriteString
    pop ebp
    ret