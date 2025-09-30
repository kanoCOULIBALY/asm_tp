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
    jle exit_success    ; Si entrée vide ou juste un retour à la ligne, considérer comme palindrome (code 0)

    dec rax             ; Ne pas inclure le '\n' dans la vérification
    mov rcx, rax        ; Longueur de la chaîne
    mov rsi, buffer     ; Début de la chaîne
    lea rdi, [buffer + rcx - 1]  ; Fin de la chaîne

check_palindrome:
    cmp rsi, rdi
    jge palindrome      ; Si les indices se croisent, c'est un palindrome

    mov al, [rsi]
    mov bl, [rdi]
    cmp al, bl
    jne not_palindrome  ; Si une différence est trouvée, ce n'est pas un palindrome

    inc rsi
    dec rdi
    jmp check_palindrome

palindrome:
    ; La chaîne est un palindrome, retourner 0
    mov rax, 60
    xor rdi, rdi        ; exit(0)
    syscall

not_palindrome:
    ; La chaîne n'est pas un palindrome, retourner 1
    mov rax, 60
    mov rdi, 1          ; exit(1)
    syscall

exit_success:
    mov rax, 60
    xor rdi, rdi
    syscall
