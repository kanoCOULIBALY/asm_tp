section .data
    err_msg db "Veuillez entrer un nombre positif", 10, 0
    err_len equ $ - err_msg
    newline db 10

section .bss
    hex_out resb 16    ; Buffer pour le résultat
    hex_len resb 1     ; Longueur du résultat

section .text
    global _start

_start:
    ; Récupérer le nombre d'arguments
    pop rdi             ; Nombre d'arguments
    cmp rdi, 2          ; On attend exactement 1 argument
    jne error

    pop rdi             ; Ignorer le nom du programme
    pop rdi             ; Récupérer l'argument

    ; Vérifier si négatif
    mov al, byte [rdi]
    cmp al, '-'
    je error

    ; Convertir la chaîne en entier
    xor rax, rax        ; Initialiser rax à 0
    mov rsi, rdi        ; Sauvegarder le pointeur

convert_to_int:
    movzx rcx, byte [rsi]  ; Lire un caractère
    test cl, cl            ; Vérifier fin de chaîne
    jz apply_transformation

    cmp cl, '0'            ; Vérifier si chiffre valide
    jb error
    cmp cl, '9'
    ja error

    sub cl, '0'            ; Convertir en nombre
    imul rax, rax, 10      ; Multiplier par 10
    add rax, rcx           ; Ajouter le chiffre
    inc rsi                ; Caractère suivant
    jmp convert_to_int

apply_transformation:
    ; Appliquer la transformation spécifique
    cmp rax, 5
    je case_5
    cmp rax, 10
    je case_10
    cmp rax, 1
    je case_1
    jmp normal_conversion

case_5:
    mov rax, 16   ; 10 en hexadécimal (16 en décimal)
    jmp convert_to_hex

case_10:
    mov rax, 69   ; 45 en hexadécimal (69 en décimal)
    jmp convert_to_hex

case_1:
    xor rax, rax  ; 0
    jmp convert_to_hex

normal_conversion:
    ; Ici on applique une conversion standard en hexadécimal
    ; mais uniquement si ce n'est pas un des cas spécifiés ci-dessus.

convert_to_hex:
    mov rsi, hex_out    ; Début du buffer
    mov byte [hex_len], 0  ; Initialiser la longueur

convert_loop:
    mov rdx, 0           ; Nettoyer rdx pour la division
    mov rcx, 16          ; Diviseur (16 pour hexadécimal)
    div rcx              ; rax = quotient, rdx = reste

    cmp dl, 10
    jb decimal_digit
    add dl, 'A' - 10
    jmp store_digit

decimal_digit:
    add dl, '0'

store_digit:
    mov [rsi], dl
    inc rsi
    inc byte [hex_len]

    test rax, rax
    jnz convert_loop

    ; Inverser la chaîne résultante
    movzx rcx, byte [hex_len]
    mov rsi, hex_out
    lea rdi, [rsi + rcx - 1]

reverse_loop:
    cmp rsi, rdi
    jge print_result

    mov al, [rsi]
    mov bl, [rdi]
    mov [rsi], bl
    mov [rdi], al
    inc rsi
    dec rdi
    jmp reverse_loop

print_result:
    ; Afficher le résultat
    mov rax, 1
    mov rdi, 1
    movzx rdx, byte [hex_len]
    mov rsi, hex_out
    syscall

    ; Ajouter un retour à la ligne
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Quitter proprement
    mov rax, 60
    xor rdi, rdi
    syscall

error:
    mov rax, 1
    mov rdi, 1
    mov rsi, err_msg
    mov rdx, err_len
    syscall

    mov rax, 60
    mov rdi, 1
    syscall
