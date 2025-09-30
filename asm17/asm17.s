section .bss
    buffer resb 1024  ; Buffer pour lire l'entrée standard

section .data
    error_msg db "Usage: ./asm17 <shift>", 10
    error_len equ $ - error_msg

section .text
    global _start

_start:
    ; Vérifier le nombre d'arguments
    pop rax
    cmp rax, 2
    jne print_usage

    ; Récupérer le décalage (shift) passé en argument
    pop rdi             ; Ignorer le nom du programme
    pop rdi             ; Récupérer le décalage sous forme de chaîne
    call atoi           ; Convertir en entier (résultat dans RAX)
    mov r8, rax         ; Stocker le shift

    ; Lire l'entrée standard
    mov rax, 0          ; sys_read
    mov rdi, 0          ; STDIN
    mov rsi, buffer
    mov rdx, 1024
    syscall

    cmp rax, 0
    jle exit_error      ; Si erreur ou EOF, quitter

    ; Remplacement de '\n' par '\0'
    mov rbx, buffer
    add rbx, rax
    dec rbx
    cmp byte [rbx], 10  ; Vérifier si dernier caractère == '\n'
    jne encrypt_loop
    mov byte [rbx], 0   ; Remplacer par '\0'

encrypt_loop:
    mov rsi, buffer
encrypt_char:
    mov al, [rsi]
    test al, al
    jz print_result     ; Si caractère nul, fin

    cmp al, 'a'
    jb check_uppercase
    cmp al, 'z'
    ja check_uppercase

    ; Chiffrement des lettres minuscules
    sub al, 'a'
    add al, r8b
    cmp al, 26
    jb store_char
    sub al, 26

store_char:
    add al, 'a'
    mov [rsi], al
    jmp next_char

check_uppercase:
    cmp al, 'A'
    jb next_char
    cmp al, 'Z'
    ja next_char

    ; Chiffrement des lettres majuscules
    sub al, 'A'
    add al, r8b
    cmp al, 26
    jb store_upper
    sub al, 26

store_upper:
    add al, 'A'
    mov [rsi], al

next_char:
    inc rsi
    jmp encrypt_char

print_result:
    ; Afficher la sortie
    mov rax, 1          ; sys_write
    mov rdi, 1          ; STDOUT
    mov rsi, buffer
    mov rdx, 1024
    syscall

    ; Sortir proprement
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

; Convertir une chaîne ASCII en entier
atoi:
    xor rax, rax
    xor rcx, rcx
    xor rdx, rdx

atoi_loop:
    movzx rdx, byte [rdi+rcx]
    test rdx, rdx
    jz atoi_done
    sub rdx, '0'
    cmp rdx, 9
    ja atoi_done
    imul rax, rax, 10
    add rax, rdx
    inc rcx
    jmp atoi_loop

atoi_done:
    ret
