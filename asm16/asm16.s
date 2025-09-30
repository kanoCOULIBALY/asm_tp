section .data
    replace_str db "H4CK"  ; Nouvelle chaîne
    str_len equ 4          ; Taille des chaînes

    error_msg db "Usage: ./asm16 <filename>", 10
    error_len equ $ - error_msg

section .bss
    buffer resb 1024  ; Buffer pour lire le fichier

section .text
    global _start

_start:
    ; Vérifier le nombre d'arguments
    pop rax
    cmp rax, 2
    jne print_usage

    pop rdi             ; Ignorer le nom du programme
    pop rdi             ; Récupérer le fichier cible

    ; Ouvrir le fichier en lecture/écriture (sys_open)
    mov rax, 2          ; sys_open
    mov rsi, 2          ; O_RDWR (lecture et écriture)
    mov rdx, 0          ; Pas de flags supplémentaires
    syscall

    cmp rax, 0
    jl exit_error       ; Si erreur, quitter

    mov rdi, rax        ; Sauvegarder le descripteur de fichier

    ; Aller directement à l'offset 0x2000 (8192 en décimal)
    mov rax, 8          ; sys_lseek
    mov rsi, 8192       ; Offset = 0x2000
    mov rdx, 0          ; SEEK_SET
    syscall

    ; Écrire "H4CK" à cet emplacement
    mov rax, 1          ; sys_write
    mov rsi, replace_str
    mov rdx, str_len
    syscall

    ; Fermer le fichier
    mov rax, 3          ; sys_close
    syscall

    ; Sortie normale
    mov rax, 60
    xor rdi, rdi
    syscall

print_usage:
    mov rax, 1
    mov rdi, 1
    mov rsi, error_msg
    mov rdx, error_len
    syscall
    jmp exit_error

exit_error:
    mov rax, 60
    mov rdi, 1
    syscall
