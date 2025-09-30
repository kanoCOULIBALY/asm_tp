section .bss
    buffer resb 128    ; Buffer pour stocker l'entrée

section .data
    newline db 10      ; Caractère de nouvelle ligne

section .text
    global _start

_start:
    ; Lire l'entrée depuis stdin
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, buffer     ; Stocker dans buffer
    mov rdx, 128        ; Nombre max de caractères
    syscall

    ; RAX contient le nombre de caractères lus
    cmp rax, 1
    jle exit_success    ; Si entrée vide ou juste un retour à la ligne, sortir

    dec rax             ; Ne pas inclure le '\n' dans l'inversion
    mov rcx, rax        ; Longueur de la chaîne
    mov rsi, buffer     ; Début de la chaîne
    lea rdi, [buffer + rcx - 1]  ; Fin de la chaîne

reverse:
    cmp rsi, rdi
    jge print_result    ; Si les indices se croisent, stop

    mov al, [rsi]
    mov bl, [rdi]
    mov [rsi], bl
    mov [rdi], al

    inc rsi
    dec rdi
    jmp reverse

print_result:
    ; Afficher la chaîne inversée
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, buffer     ; Adresse du buffer
    mov rdx, rcx        ; Longueur de la chaîne
    syscall

    ; Ajouter un retour à la ligne
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

exit_success:
    mov rax, 60
    xor rdi, rdi
    syscall
