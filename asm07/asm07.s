section .data
    prompt db "Veuillez entrer un nombre: ", 0
    prompt_len equ $ - prompt
    error_msg db "Erreur: veuillez entrer un nombre entier positif", 10
    error_len equ $ - error_msg

section .bss
    num resb 20
    len resb 8

section .text
    global _start

_start:
    ; Afficher le prompt
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; Lire l'entrée
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, num
    mov rdx, 20
    syscall

    ; Sauvegarder la longueur lue
    mov [len], rax

    ; Convertir la chaîne en nombre
    mov rdi, num
    call atoi
    
    ; Si conversion échoue, sortir avec code 2
    cmp rax, -1
    je exit_format_error

    ; Vérifier si le nombre est premier
    mov rdi, rax
    call is_prime
    
    ; Sortir avec le code approprié
    test rax, rax
    jz exit_not_prime   ; Si pas premier, sortir avec 1
    jmp exit_prime      ; Si premier, sortir avec 0

atoi:
    xor rax, rax        ; Résultat
    xor rcx, rcx        ; Index
    
.process_char:
    movzx rdx, byte [rdi + rcx]  ; Charger le caractère
    
    ; Vérifier fin de ligne ou fin de chaîne
    cmp dl, 10
    je .done
    test dl, dl
    jz .done
    
    ; Vérifier si c'est un chiffre
    cmp dl, '0'
    jb .error
    cmp dl, '9'
    ja .error
    
    ; Convertir et ajouter le chiffre
    sub dl, '0'
    imul rax, 10
    add rax, rdx
    
    inc rcx
    cmp rcx, [len]
    jb .process_char
    
.done:
    ret

.error:
    mov rax, -1
    ret

is_prime:
    ; Cas spéciaux
    cmp rdi, 2
    je .is_prime
    
    cmp rdi, 2
    jl .not_prime
    
    test rdi, 1
    jz .not_prime   ; Si pair > 2, pas premier
    
    mov rcx, 3      ; Commencer à tester à partir de 3
    mov rax, rdi
    mov rbx, rax
    shr rbx, 1      ; rbx = n/2 (limite supérieure)
    
.check_loop:
    cmp rcx, rbx
    ja .is_prime
    
    mov rax, rdi
    xor rdx, rdx
    div rcx
    test rdx, rdx
    jz .not_prime   ; Si divisible, pas premier
    
    add rcx, 2      ; Tester seulement les nombres impairs
    jmp .check_loop
    
.not_prime:
    xor rax, rax    ; Retourner 0 (pas premier)
    ret
    
.is_prime:
    mov rax, 1      ; Retourner 1 (premier)
    ret

exit_format_error:
    ; Afficher message d'erreur
    mov rax, 1
    mov rdi, 1
    mov rsi, error_msg
    mov rdx, error_len
    syscall
    
    mov rax, 60     ; sys_exit
    mov rdi, 2      ; code 2 pour erreur de format
    syscall

exit_not_prime:
    mov rax, 60     ; sys_exit
    mov rdi, 1      ; code 1 pour non premier
    syscall

exit_prime:
    mov rax, 60     ; sys_exit
    xor rdi, rdi    ; code 0 pour premier
    syscall
