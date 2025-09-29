section .data
    msg db "1337", 10      ; "1337" + newline
    len equ $ - msg        ; longueur du message

section .bss
    input resb 10          ; buffer pour l'entrée

section .text
    global _start

_start:
    ; Lire depuis stdin
    mov rax, 0             ; syscall read
    mov rdi, 0             ; stdin
    mov rsi, input         ; buffer pour stocker l'entrée
    mov rdx, 10            ; nombre max de bytes à lire
    syscall

    ; Vérifier si l'entrée est "42"
    ; Comparer le premier caractère avec '4'
    mov al, [input]
    cmp al, '4'
    jne exit_error         ; si différent, sortir avec erreur
    
    ; Comparer le deuxième caractère avec '2'
    mov al, [input + 1]
    cmp al, '2'
    jne exit_error         ; si différent, sortir avec erreur
    
    ; Vérifier que le 3ème caractère est newline ou null
    mov al, [input + 2]
    cmp al, 10             ; newline
    je print_1337
    cmp al, 0              ; null
    je print_1337
    jmp exit_error

print_1337:
    ; Afficher "1337"
    mov rax, 1             ; syscall write
    mov rdi, 1             ; stdout
    mov rsi, msg           ; adresse du message
    mov rdx, len           ; longueur
    syscall
    
    ; Sortir avec succès (code 0)
    mov rax, 60            ; syscall exit
    mov rdi, 0             ; code de sortie 0
    syscall

exit_error:
    ; Sortir avec erreur (code 1)
    mov rax, 60            ; syscall exit
    mov rdi, 1             ; code de sortie 1
    syscall
