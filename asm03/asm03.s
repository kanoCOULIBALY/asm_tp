section .data
    msg db "1337", 10      ; "1337" + newline
    len equ $ - msg        ; longueur du message

section .text
    global _start

_start:
    ; Au démarrage, la pile contient:
    ; [rsp] = argc (nombre d'arguments)
    ; [rsp + 8] = argv[0] (nom du programme)
    ; [rsp + 16] = argv[1] (premier argument)
    
    ; Vérifier qu'il y a au moins 2 arguments (programme + 1 arg)
    pop rdi                ; rdi = argc
    cmp rdi, 2
    jne exit_error         ; si argc != 2, erreur
    
    ; Sauter argv[0] (nom du programme)
    pop rdi                ; enlever argv[0]
    
    ; Récupérer argv[1]
    pop rdi                ; rdi = pointeur vers argv[1]
    
    ; Vérifier que argv[1] = "42"
    ; Comparer le premier caractère avec '4'
    mov al, [rdi]
    cmp al, '4'
    jne exit_error
    
    ; Comparer le deuxième caractère avec '2'
    mov al, [rdi + 1]
    cmp al, '2'
    jne exit_error
    
    ; Vérifier que le 3ème caractère est null (fin de chaîne)
    mov al, [rdi + 2]
    cmp al, 0
    jne exit_error

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
