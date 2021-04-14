%include "rw32-2018.inc"

extern _malloc

section .data
    task21A dd 3072,-256,-2816,1536,-1792,2560,-15360,-15360
    task21B dd 1901389365,-547517889,-1101700870,2061644832,-1305033724,-1434240036,632492347,832600223
    task22A dw 192,-16,-176,96,-112,160,-960,-960
    task22B dw -2736,-22573,24894,-23956,5749,2885,2111,23979
    task23A dw 384,176,16,288,80,352,-768,-768

section .text
CMAIN:
    push ebp
    mov ebp,esp
    
    mov eax, task21A
    mov ebx, -256
    mov ecx, 8
    call task21
    
    push dword 192
    push dword 8
    push dword task22A
    call task22
    add esp, 12
    
    call task23

    pop ebp
    ret    
    
;--- Task 1 ---
;
; Create a function 'task21' to find a value in an array of the 32bit signed values.  
; Pointer to the array is in the register EAX, the value to be found is in the register EBX 
; and the count of the elements of the array is in the register ECX.
;
; Function parameters:
;   EAX = pointer to the array of the 32bit signed values (EAX is always a valid pointer)
;   EBX = 32bit signed value to be found
;   ECX = count of the elements of the array (ECX is an unsigned 32bit value, always greater than 0)
;
; Return values:
;   EAX = 1, if the value has been found in the array, otherwise EAX = 0
;
; Important:
;   - the function does not have to preserve content of any register
;
task21:
  l:
    cmp     [eax],  ebx
    je      true
    add     eax,    4
    loop    l
    
    mov     eax,    0
    jmp     end
        
  true:
    mov     eax,    1
  end:    
    ret

;--- Task 2 ---
;
; Create a function: void* task22(const short *pA, int N, short x) to search an array pA of N 16bit signed 
; values for the last occurrence of the value x. The function returns pointer to the value in the array.
; The parameters are passed, the stack is cleaned and the result is returned according to the CDECL calling convention.
;
; Function parameters:
;   pA: pointer to the array A to search in 
;    N: length of the array A
;    x: value to be searched for
;
; Return values:
;   EAX = 0 if the pointer pA is invalid (pA == 0) or N <= 0 or the value x has not been found in the array
;   EAX = pointer to the value x in the array (the array elements are indexed from 0)
;
; Important:
;   - the function MUST preserve content of all the registers except for the EAX and flags registers.
;

; pA - [ebp + 8]
; N  - [ebp + 12]
; x  - [ebp + 16]

task22:
    push    ebp
    mov     ebp,    esp
    ; Check input 
    mov     eax,    0
    
    cmp     word[ebp + 8],  0    ; pA == 0
    je      stop
    cmp     dword[ebp + 12], 0    ; N <= 0
    jle     stop
    
    ; Save registers
    push    ebx
    push    ecx
    push    edx
     
    ; Logic 
    mov     ecx, [ebp + 12]
    mov     eax, [ebp + 8]
    mov     edx, 0
  lp:
    mov     bx, [eax]
    cmp     bx, [ebp + 16]
    jne     continue
    mov     edx, eax            
  continue:
    add     eax, 2
    loop    lp
    
    mov     eax, edx        
    
    pop     edx
    pop     ecx
    pop     ebx
  stop:
    pop     ebp
    ret
    
;
;--- Task 3 ---
;
; Create a function 'task23' to allocate and fill an array of the 16bit unsigned elements by the
; Fibonacci numbers F(0), F(1), ... , F(N-1). Requested count of the Fibonacci numbers is 
; in the register ECX (32bit signed integer) and the function returns a pointer to the array  
; allocated using the 'malloc' function from the standard C library in the register EAX.
;
; Fibonacci numbers are defined as follows:
;
;   F(0) = 0
;   F(1) = 1
;   F(n) = F(n-1) + F(n-2)
;
; Function parameters:
;   ECX = requested count of the Fibonacci numbers (32bit signed integer).
;
; Return values:
;   EAX = 0, if ECX <= 0, do not allocate any memory and return value 0 (NULL),
;   EAX = 0, if memory allocation by the 'malloc' function fails ('malloc' returns 0),
;   EAX = pointer to the array of N 16bit unsigned integer elements of the Fibonacci sequence.
;
; Important:
;   - the function MUST preserve content of all the registers except for the EAX and flags registers,
;   - the 'malloc' function may change the content of the ECX and EDX registers.
;
; The 'malloc' function is defined as follows: 
;
;   void* malloc(size_t N)
;     N: count of bytes to be allocated (32bit unsigned integer),
;     - in the EAX register it returns the pointer to the allocated memory,
;     - in the EAX register it returns 0 (NULL) in case of a memory allocation error,
;     - the function may change the content of the ECX and EDX registers.
task23:
    push    ebp
    mov     ebp,        esp
    sub     esp,        16
    mov     dword [ebp - 4],  0 ; t1
    mov     dword [ebp - 8],  1 ; t2
    mov     dword [ebp - 12], 0 ; next
    
    push    ebx
    push    ecx
    push    edx
    
    cmp     ecx,    0
    jle     stop_error
    
    mov     eax,    ecx
    mov     edx,    2
    mul     edx
    push    eax         
    mov     ebx,    ecx ; store ecx, as it can be changed by malloc
    
    call    _malloc  
    add     esp,    4  
    cmp     eax,    0
    je      stop_error
      
    mov     ecx,    ebx
    
    mov     [ebp - 16], eax ; address of the first element
    mov     edx,    1
  lp1:
    cmp     edx,    ecx
    jg      cycle_end
    mov     bx,    [ebp - 4] ; ebx = t1
    mov     [eax],  bx       ; ! *eax = t1
    add     eax,    2         ; eax += 2 bytes
    
    add     bx,    [ebp - 8] ; ebx = t1 + t2
    mov     [ebp - 12], bx   ; ! next = t1 + t2
    mov     bx,    [ebp - 8] ; ebx = t2
    mov     [ebp - 4],  bx   ; ! t1 = t2
    mov     bx,    [ebp - 12]; ebx = next
    mov     [ebp - 8],  bx   ; ! t2 = next
            
    inc     edx
    jmp     lp1
    
  cycle_end:
    mov     eax,    [ebp - 16] 
    jmp     stop1
    
  stop_error:
    mov     eax,    0                              
  stop1:
    pop     edx
    pop     ecx
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret   
