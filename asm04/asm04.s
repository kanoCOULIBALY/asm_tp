section .bss
    buffer resb 16

section .text
    global _start

_start:
    ; Lire l'entrée standard
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, buffer     ; buffer
    mov edx, 16         ; taille max
    int 0x80
    
    ; Convertir ASCII en nombre
    xor ebx, ebx        ; ebx = 0 (résultat)
    xor esi, esi        ; esi = 0 (index)
    
convert_loop:
    movzx eax, byte [buffer + esi]
    cmp al, 10          ; newline?
    je done_convert
    cmp al, 0           ; null?
    je done_convert
    cmp al, '0'
    jb done_convert
    cmp al, '9'
    ja done_convert
    
    sub al, '0'         ; convertir en chiffre
    imul ebx, ebx, 10   ; ebx *= 10
    add ebx, eax        ; ebx += chiffre
    inc esi
    jmp convert_loop
    
done_convert:
    ; Tester si pair (bit 0 = 0) ou impair (bit 0 = 1)
    mov eax, ebx
    and eax, 1          ; garder seulement le bit de poids faible
    
    ; Sortir avec le code approprié
    mov ebx, eax        ; code de sortie (0 si pair, 1 si impair)
    mov eax, 1          ; sys_exit
    int 0x80

