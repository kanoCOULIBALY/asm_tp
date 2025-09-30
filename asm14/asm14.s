section .data
    message db "Hello Universe!", 10  ; Message avec saut de ligne
    msg_len equ $ - message           ; Longueur du message
    error_msg db "Usage: ./asm14 <filename>", 10
    error_len equ $ - error_msg

section .bss
    filename resb 128   ; Buffer pour stocker le nom du fichier

section .text
    global _start

_start:
    ; Vérifier le nombre d'arguments
    pop rax             ; Nombre d'arguments
    cmp rax, 2
    jne print_usage     ; Si différent de 2 (programme + fichier), afficher l'erreur

    pop rdi             ; Ignorer le nom du programme
    pop rdi             ; Récupérer le nom du fichier

    ; Ouvrir/créer le fichier (sys_open)
    mov rax, 2          ; sys_open
    mov rsi, 0x241      ; O_WRONLY | O_CREAT | O_TRUNC
    mov rdx, 0o644      ; Permissions (rw-r--r--)
    syscall

    ; Vérifier si l'ouverture a échoué
    cmp rax, 0
    jl exit_error

    ; Sauvegarder le descripteur de fichier
    mov rdi, rax

    ; Écrire le message dans le fichier (sys_write)
    mov rax, 1          ; sys_write
    mov rsi, message    ; Adresse du message
    mov rdx, msg_len    ; Taille du message
    syscall

    ; Fermer le fichier (sys_close)
    mov rax, 3          ; sys_close
    syscall

    ; Quitter proprement avec succès
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; exit(0)
    syscall

print_usage:
    ; Afficher message d'erreur
    mov rax, 1
    mov rdi, 1          ; stdout
    mov rsi, error_msg
    mov rdx, error_len
    syscall

exit_error:
    mov rax, 60         ; sys_exit
    mov rdi, 1          ; exit(1)
    syscall
