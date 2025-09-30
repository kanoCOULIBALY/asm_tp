section .data
    elf_magic db 0x7F, "ELF"    ; Magie ELF
    elf_len equ 4               ; Longueur de l'en-tête ELF à vérifier
    error_msg db "Usage: ./asm15 <filename>", 10
    error_len equ $ - error_msg

section .bss
    buffer resb 4  ; Buffer pour lire les premiers octets du fichier

section .text
    global _start

_start:
    ; Vérifier le nombre d'arguments
    pop rax             ; Nombre d'arguments
    cmp rax, 2
    jne print_usage     ; Si != 2 (programme + fichier), afficher l'erreur

    pop rdi             ; Ignorer le nom du programme
    pop rdi             ; Récupérer le nom du fichier

    ; Ouvrir le fichier (sys_open)
    mov rax, 2          ; sys_open
    xor rsi, rsi        ; O_RDONLY
    syscall

    ; Vérifier si l'ouverture a échoué
    cmp rax, 0
    jl exit_error

    ; Sauvegarder le descripteur de fichier
    mov rdi, rax

    ; Lire les 4 premiers octets (sys_read)
    mov rax, 0          ; sys_read
    mov rsi, buffer     ; Stocker dans buffer
    mov rdx, elf_len    ; Lire 4 octets
    syscall

    ; Fermer le fichier (sys_close)
    mov rax, 3          ; sys_close
    syscall

    ; Comparer avec la magie ELF
    mov rsi, buffer
    mov rdi, elf_magic
    mov rcx, elf_len

compare_loop:
    mov al, [rsi]
    cmp al, [rdi]
    jne not_elf
    inc rsi
    inc rdi
    loop compare_loop

    ; Si tout est bon, retourner 0 (ELF détecté)
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; exit(0)
    syscall

not_elf:
    ; Sinon, retourner 1
    mov rax, 60
    mov rdi, 1          ; exit(1)
    syscall

print_usage:
    ; Afficher message d'erreur
    mov rax, 1
    mov rdi, 1          ; stdout
    mov rsi, error_msg
    mov rdx, error_len
    syscall
    jmp not_elf         ; Quitter avec erreur

exit_error:
    mov rax, 60
    mov rdi, 1
    syscall
